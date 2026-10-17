#!/usr/bin/env python3
"""Assemble the trained SEA-Nav navigation observation over ROS1.

This node deliberately does not run the neural network and does not command
motors. A policy runner publishes ``NavCommand`` locally; this node forwards it
to the motion host over TCP. The motion host sends gravity and the applied
previous navigation command back over the same connection.
"""

import collections
import json
import math
import socket
import threading
import time

import rospy
import tf
from geometry_msgs.msg import Pose2D, PoseStamped, PoseWithCovarianceStamped
from nav_msgs.msg import Odometry
from sensor_msgs.msg import LaserScan

from seanav_deploy_ros1.msg import Lite3State, NavCommand, SeaNavObservation


def _finite_vector(values, size):
    try:
        if len(values) != size:
            return None
    except (TypeError, ValueError):
        return None
    try:
        result = [float(value) for value in values]
    except (TypeError, ValueError):
        return None
    if not all(math.isfinite(value) for value in result):
        return None
    return result


class SeaNavInterface:
    """Build the exact 10 x 55 input expected by Lite3 SEA-Nav training."""

    def __init__(self):
        self.rays_topic = rospy.get_param("~rays_topic", "/rays")
        self.pose_topic = rospy.get_param("~pose_topic", "/pose")
        self.odom_topic = rospy.get_param("~odom_topic", "/pose_odom")
        self.goal_topic = rospy.get_param("~goal_topic", "/goal")
        self.goal_frame = rospy.get_param("~goal_frame", "odom").lstrip("/")
        self.require_goal = bool(rospy.get_param("~require_goal", True))
        self.goal_tolerance = float(rospy.get_param("~goal_tolerance", 0.3))
        self.goal_received = not self.require_goal
        self.has_goal = self.goal_received
        self.tf_listener = tf.TransformListener()
        self.nav_command_topic = rospy.get_param(
            "~nav_command_topic", "/sea_nav/nav_command")
        self.observation_topic = rospy.get_param(
            "~observation_topic", "/sea_nav/observation")
        self.motion_state_topic = rospy.get_param(
            "~motion_state_topic", "/sea_nav/motion_state")
        self.motion_host = rospy.get_param("~motion_host", "192.168.5.59")
        self.motion_port = int(rospy.get_param("~motion_port", 29001))
        tcp_enabled = rospy.get_param("~tcp_enabled", True)
        self.tcp_enabled = (tcp_enabled if isinstance(tcp_enabled, bool) else
                            str(tcp_enabled).lower() in ("1", "true", "yes", "on"))
        self.tcp_reconnect_s = float(rospy.get_param("~tcp_reconnect_s", 1.0))

        self.history_length = int(rospy.get_param("~history_length", 10))
        self.ray_count = int(rospy.get_param("~ray_count", 41))
        self.range_min = float(rospy.get_param("~range_min", 0.1))
        self.range_max = float(rospy.get_param("~range_max", 3.0))
        self.fresh_s = float(rospy.get_param("~fresh_s", 0.25))
        # Lite3 training uses dt=0.005 and decimation=4, so the navigation
        # observation/action period is 0.02 s (50 Hz).
        self.publish_hz = float(rospy.get_param("~publish_hz", 50.0))
        self.goal_x = float(rospy.get_param("~goal_x", 1.0))
        self.goal_y = float(rospy.get_param("~goal_y", 0.0))

        self.rays = None
        self.pose = None
        self.odom = None
        self.motion_state = None
        self.last_rays_time = rospy.Time(0)
        self.last_pose_time = rospy.Time(0)
        self.last_odom_time = rospy.Time(0)
        self.last_motion_time = rospy.Time(0)
        self.history = collections.deque(maxlen=self.history_length)
        self.warned = set()
        self.observation_lock = threading.RLock()
        # Subscribers and the TCP thread may run as soon as they are created.
        self.tcp_lock = threading.Lock()
        self.pending_command = None
        self.tcp_socket = None
        self.tcp_thread = None

        self.observation_pub = rospy.Publisher(
            self.observation_topic, SeaNavObservation, queue_size=10)
        self.motion_state_pub = rospy.Publisher(
            self.motion_state_topic, Lite3State, queue_size=10)
        self.current_goal_pub = rospy.Publisher(
            "/sea_nav/current_goal", PoseStamped, queue_size=1, latch=True)
        if self.goal_received:
            self.publish_current_goal()
        rospy.Subscriber(self.rays_topic, LaserScan, self.rays_callback, queue_size=1)
        rospy.Subscriber(self.pose_topic, Pose2D, self.pose_callback, queue_size=1)
        rospy.Subscriber(self.odom_topic, Odometry, self.odom_callback, queue_size=1)
        rospy.Subscriber(self.goal_topic, Pose2D, self.goal_callback, queue_size=1)
        rospy.Subscriber(rospy.get_param("~rviz_goal_topic", "/move_base_simple/goal"),
                         PoseStamped, self.rviz_goal_callback, queue_size=1)
        rospy.Subscriber(rospy.get_param("~rviz_pose_topic", "/initialpose"),
                         PoseWithCovarianceStamped, self.rviz_pose_callback, queue_size=1)
        rospy.Subscriber(self.nav_command_topic, NavCommand,
                         self.nav_command_callback, queue_size=1)

        if self.tcp_enabled:
            self.tcp_thread = threading.Thread(target=self.tcp_loop,
                                               name="sea_nav_tcp", daemon=True)
            self.tcp_thread.start()

        self.timer = rospy.Timer(rospy.Duration(1.0 / max(self.publish_hz, 1.0)),
                                 self.publish_observation)
        rospy.loginfo(
            "sea_nav_interface_ros1: tcp=%s:%d -> %s, history=%d, step=%d",
            self.motion_host, self.motion_port, self.observation_topic,
            self.history_length, self.step_size)
        rospy.loginfo("publishing motion host state on %s", self.motion_state_topic)

    @property
    def step_size(self):
        return 3 + 3 + 3 + 3 + self.ray_count + 2

    def rays_callback(self, msg):
        if len(msg.ranges) != self.ray_count:
            self._warn_once("rays_size", "expected %d rays, received %d",
                            self.ray_count, len(msg.ranges))
            return
        values = []
        for value in msg.ranges:
            value = float(value)
            if not math.isfinite(value) or value <= 0.0:
                value = self.range_max
            values.append(min(max(value, self.range_min), self.range_max))
        self.rays = values
        self.last_rays_time = rospy.Time.now()

    def pose_callback(self, msg):
        if not all(math.isfinite(float(value)) for value in
                   (msg.x, msg.y, msg.theta)):
            return
        self.pose = msg
        self.last_pose_time = rospy.Time.now()

    def odom_callback(self, msg):
        self.odom = msg
        self.last_odom_time = rospy.Time.now()

    def nav_command_callback(self, msg):
        packet = {
            "version": 1,
            "type": "nav_command",
            "stamp": time.time(),
            "vx": float(msg.vx),
            "vy": float(msg.vy),
            "vyaw": float(msg.vyaw),
            "enable": bool(msg.enable),
            "emergency_stop": bool(msg.emergency_stop),
        }
        if all(math.isfinite(packet[key]) for key in ("vx", "vy", "vyaw")):
            with self.tcp_lock:
                self.pending_command = packet

    def tcp_loop(self):
        """Bidirectional newline-delimited JSON link to the motion host."""
        receive_buffer = b""
        while not rospy.is_shutdown():
            sock = None
            try:
                rospy.loginfo("connecting SEA-Nav TCP to %s:%d",
                              self.motion_host, self.motion_port)
                sock = socket.create_connection(
                    (self.motion_host, self.motion_port), timeout=3.0)
                sock.settimeout(0.1)
                receive_buffer = b""
                with self.tcp_lock:
                    self.tcp_socket = sock
                    # Do not replay an action queued before reconnection.
                    self.pending_command = None
                rospy.loginfo("SEA-Nav TCP connected to motion host")
                while not rospy.is_shutdown():
                    with self.tcp_lock:
                        pending = self.pending_command
                        self.pending_command = None
                    if pending is not None:
                        sock.sendall((json.dumps(pending, separators=(",", ":")) + "\n").encode("utf-8"))
                    try:
                        chunk = sock.recv(4096)
                        if not chunk:
                            raise ConnectionError("motion host closed TCP connection")
                        receive_buffer += chunk
                        while b"\n" in receive_buffer:
                            line, receive_buffer = receive_buffer.split(b"\n", 1)
                            if line.strip():
                                self.handle_motion_packet(json.loads(line.decode("utf-8")))
                    except socket.timeout:
                        continue
            except (OSError, ValueError, ConnectionError) as exc:
                rospy.logwarn_throttle(5.0, "SEA-Nav TCP unavailable: %s", exc)
            finally:
                with self.tcp_lock:
                    if self.tcp_socket is sock:
                        self.tcp_socket = None
                if sock is not None:
                    try:
                        sock.close()
                    except OSError:
                        pass
            rospy.sleep(self.tcp_reconnect_s)

    def handle_motion_packet(self, packet):
        if not isinstance(packet, dict):
            self._warn_once("tcp_packet_type", "ignoring non-object SEA-Nav TCP packet")
            return
        if packet.get("version") != 1 or packet.get("type") != "motion_state":
            self._warn_once("tcp_packet", "ignoring unknown SEA-Nav TCP packet")
            return
        gravity = _finite_vector(packet.get("projected_gravity", []), 3)
        nav_command = _finite_vector(packet.get("last_nav_command", []), 3)
        if gravity is None or nav_command is None:
            self._warn_once("tcp_state_shape", "motion_state requires 3-D projected_gravity and last_nav_command")
            return
        with self.tcp_lock:
            self.motion_state = {
                "projected_gravity": gravity,
                "last_nav_command": nav_command,
                "enabled": bool(packet.get("enabled", True)),
                "standing": bool(packet.get("standing", packet.get("enabled", True))),
            }
            self.last_motion_time = rospy.Time.now()
            motion_state = dict(self.motion_state)
        self.publish_motion_state(motion_state)

    def publish_motion_state(self, motion_state):
        """Expose the validated TCP state for ROS tools and diagnostics."""
        msg = Lite3State()
        # Use local receipt time because the two hosts may not share a clock.
        msg.header.stamp = rospy.Time.now()
        msg.header.frame_id = "base_link"
        msg.projected_gravity = list(motion_state["projected_gravity"])
        msg.last_nav_command = list(motion_state["last_nav_command"])
        msg.standing = bool(motion_state.get("standing", False))
        msg.enabled = bool(motion_state["enabled"])
        self.motion_state_pub.publish(msg)

    def goal_callback(self, msg):
        if math.isfinite(float(msg.x)) and math.isfinite(float(msg.y)):
            with self.observation_lock:
                self.goal_x = float(msg.x)
                self.goal_y = float(msg.y)
                self.goal_received = True
                self.has_goal = True
                self.publish_current_goal()
                self.history.clear()
            rospy.loginfo("navigation goal in %s: x=%.3f y=%.3f",
                          self.goal_frame, self.goal_x, self.goal_y)

    def publish_current_goal(self):
        """Retain the last accepted target even without valid sensor observations."""
        msg = PoseStamped()
        msg.header.stamp = rospy.Time.now()
        msg.header.frame_id = self.goal_frame
        msg.pose.position.x = self.goal_x
        msg.pose.position.y = self.goal_y
        msg.pose.orientation.w = 1.0
        self.current_goal_pub.publish(msg)

    def rviz_goal_callback(self, msg):
        """Transform a clicked goal into the startup-local /pose frame."""
        if not msg.header.frame_id:
            rospy.logwarn("ignoring RViz goal without a frame_id")
            return
        try:
            if msg.header.frame_id.lstrip("/") != self.goal_frame:
                self.tf_listener.waitForTransform(
                    self.goal_frame, msg.header.frame_id, msg.header.stamp,
                    rospy.Duration(0.3))
                msg = self.tf_listener.transformPose(self.goal_frame, msg)
            self.goal_callback(Pose2D(x=msg.pose.position.x,
                                      y=msg.pose.position.y, theta=0.0))
        except (tf.Exception, tf.LookupException, tf.ConnectivityException,
                tf.ExtrapolationException) as exc:
            rospy.logwarn("cannot transform RViz goal to %s: %s", self.goal_frame, exc)

    def rviz_pose_callback(self, msg):
        # Optional compatibility with RViz's 2D Pose Estimate tool. This only
        # changes the navigation target; it does not reset A-LOAM localization.
        goal = PoseStamped()
        goal.header = msg.header
        goal.pose = msg.pose.pose
        self.rviz_goal_callback(goal)

    def _warn_once(self, key, fmt, *args):
        if key not in self.warned:
            rospy.logwarn(fmt, *args)
            self.warned.add(key)

    def _fresh(self, stamp):
        return (stamp != rospy.Time(0) and
                (rospy.Time.now() - stamp).to_sec() <= self.fresh_s)

    def _current_step(self):
        if not self.goal_received:
            return None
        if (self.motion_state is None or not self.motion_state["enabled"] or
                self.rays is None or self.pose is None or self.odom is None):
            return None
        if not (self._fresh(self.last_motion_time) and
                self._fresh(self.last_rays_time) and
                self._fresh(self.last_pose_time) and
                self._fresh(self.last_odom_time)):
            return None

        gravity = self.motion_state["projected_gravity"]
        nav_command = self.motion_state["last_nav_command"]
        body_lin_vel = [float(self.odom.twist.twist.linear.x),
                        float(self.odom.twist.twist.linear.y),
                        float(self.odom.twist.twist.linear.z)]
        body_ang_vel = [float(self.odom.twist.twist.angular.x),
                        float(self.odom.twist.twist.angular.y),
                        float(self.odom.twist.twist.angular.z)]
        if (gravity is None or body_lin_vel is None or body_ang_vel is None or
                nav_command is None):
            self._warn_once("state_shape",
                            "TCP gravity/nav state and A-LOAM twist must each have length 3")
            return None

        dx = self.goal_x - float(self.pose.x)
        dy = self.goal_y - float(self.pose.y)
        c = math.cos(float(self.pose.theta))
        s = math.sin(float(self.pose.theta))
        goal_local = [c * dx + s * dy, -s * dx + c * dy]
        if math.hypot(dx, dy) <= self.goal_tolerance:
            self.goal_received = False
            rospy.loginfo("goal reached; waiting for a new RViz goal")
            return None
        rays_log2 = [math.log(value, 2.0) for value in self.rays]
        proprioception = gravity + nav_command + body_lin_vel + body_ang_vel
        return (proprioception + rays_log2 + goal_local,
                proprioception, list(self.rays), rays_log2, goal_local)

    def _diagnostic_goal_local(self):
        # Inspect the last accepted target independently of navigation readiness.
        if not self.has_goal or self.pose is None or not self._fresh(self.last_pose_time):
            return []
        dx = self.goal_x - float(self.pose.x)
        dy = self.goal_y - float(self.pose.y)
        c = math.cos(float(self.pose.theta))
        s = math.sin(float(self.pose.theta))
        return [c * dx + s * dy, -s * dx + c * dy]

    def publish_observation(self, _event):
        with self.observation_lock:
            self._publish_observation()

    def _publish_observation(self):
        current = self._current_step()
        if current is None:
            # Do not carry stale samples across a perception or state outage.
            self.history.clear()
            msg = SeaNavObservation()
            msg.header.stamp = rospy.Time.now()
            msg.header.frame_id = "base_link"
            msg.goal_local = self._diagnostic_goal_local()
            msg.valid = False
            self.observation_pub.publish(msg)
            return
        step, proprioception, rays, rays_log2, goal_local = current
        if not self.history:
            self.history.extend([list(step)] * self.history_length)
        else:
            self.history.append(list(step))

        msg = SeaNavObservation()
        msg.header.stamp = rospy.Time.now()
        msg.header.frame_id = "base_link"
        msg.history_length = self.history_length
        msg.step_size = self.step_size
        msg.observation = [value for item in self.history for value in item]
        msg.proprioception = proprioception
        msg.rays_m = rays
        msg.rays_log2 = rays_log2
        msg.goal_local = goal_local
        msg.previous_nav_command = list(proprioception[3:6])
        msg.valid = True
        self.observation_pub.publish(msg)


def main():
    rospy.init_node("sea_nav_interface")
    SeaNavInterface()
    rospy.spin()


if __name__ == "__main__":
    main()
