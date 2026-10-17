#!/usr/bin/env python3
"""Convert A-LOAM's world-frame odometry into SEA-Nav's local ``/pose``."""

import math

import rospy
import tf
import tf2_ros
from geometry_msgs.msg import Pose2D, TransformStamped
from nav_msgs.msg import Odometry


def wrap_pi(angle):
    return (angle + math.pi) % (2.0 * math.pi) - math.pi


def yaw_from_quaternion(q):
    siny = 2.0 * (q.w * q.z + q.x * q.y)
    cosy = 1.0 - 2.0 * (q.y * q.y + q.z * q.z)
    return math.atan2(siny, cosy)


def rpy_from_quaternion(q):
    sinr = 2.0 * (q.w * q.x + q.y * q.z)
    cosr = 1.0 - 2.0 * (q.x * q.x + q.y * q.y)
    roll = math.atan2(sinr, cosr)
    sinp = 2.0 * (q.w * q.y - q.z * q.x)
    pitch = math.asin(max(-1.0, min(1.0, sinp)))
    return roll, pitch, yaw_from_quaternion(q)


class AloamOdom:
    """Subscribe to A-LOAM and publish a startup-relative ``Pose2D``."""

    def __init__(self):
        self.odom_topic = rospy.get_param("~odom_topic", "/aft_mapped_to_init_high_frec")
        self.output_topic = rospy.get_param("~output_topic", "/pose")
        self.output_odom_topic = rospy.get_param("~output_odom_topic", "/pose_odom")
        self.skip_first_msgs = int(rospy.get_param("~skip_first_msgs", 3))
        self.origin_settle_msgs = int(rospy.get_param("~origin_settle_msgs", 30))
        self.laser_yaw_offset = float(rospy.get_param("~laser_yaw_offset_rad", 0.0))
        self.laser_x = float(rospy.get_param("~laser_x_in_base_m", 0.0))
        self.laser_y = float(rospy.get_param("~laser_y_in_base_m", 0.0))
        self.pose_x_sign = float(rospy.get_param("~pose_x_sign", 1.0))
        self.pose_y_sign = float(rospy.get_param("~pose_y_sign", 1.0))
        self.yaw_sign = float(rospy.get_param("~yaw_sign", 1.0))
        self.debug_log_hz = float(rospy.get_param("~debug_log_hz", 2.0))
        self.min_velocity_dt = float(rospy.get_param("~min_velocity_dt", 0.001))
        self.max_velocity_dt = float(rospy.get_param("~max_velocity_dt", 0.2))
        self.local_frame = rospy.get_param("~local_frame", "odom").lstrip("/")
        self.publish_base_tf = bool(rospy.get_param("~publish_base_tf", True))
        self.origin_tf = tf2_ros.StaticTransformBroadcaster()
        self.base_tf = tf.TransformBroadcaster()

        self.msg_count = 0
        self.valid_count = 0
        self.origin = None
        self.last_log = rospy.Time(0)
        self.previous_motion = None
        self.pub = rospy.Publisher(self.output_topic, Pose2D, queue_size=10)
        self.odom_pub = rospy.Publisher(self.output_odom_topic, Odometry, queue_size=10)
        self.sub = rospy.Subscriber(self.odom_topic, Odometry, self.callback, queue_size=10)
        rospy.loginfo("aloam_odom_ros1: %s -> %s and %s", self.odom_topic,
                      self.output_topic, self.output_odom_topic)

    def should_log(self):
        if self.debug_log_hz <= 0.0:
            return False
        now = rospy.Time.now()
        if (now - self.last_log).to_sec() < 1.0 / self.debug_log_hz:
            return False
        self.last_log = now
        return True

    def callback(self, msg):
        self.msg_count += 1
        if self.msg_count <= self.skip_first_msgs:
            return

        p = msg.pose.pose.position
        raw_roll, raw_pitch, raw_yaw = rpy_from_quaternion(msg.pose.pose.orientation)
        yaw = wrap_pi(self.yaw_sign * raw_yaw - self.laser_yaw_offset)

        # A-LOAM's translation is the Velodyne pose in camera_init. Correct for
        # a non-centered Velodyne mounting position to obtain base_link pose.
        c, s = math.cos(yaw), math.sin(yaw)
        offset_x = c * self.laser_x - s * self.laser_y
        offset_y = s * self.laser_x + c * self.laser_y
        base_x = float(p.x) - offset_x
        base_y = float(p.y) - offset_y
        base_z = float(p.z)

        self.valid_count += 1
        if self.origin is None:
            if self.valid_count < self.origin_settle_msgs:
                if self.should_log():
                    rospy.loginfo("settling A-LOAM origin: %d/%d", self.valid_count, self.origin_settle_msgs)
                return
            self.origin = (base_x, base_y, base_z, yaw, raw_roll, raw_pitch)
            # /pose is measured in this startup-relative frame. Publish its
            # relationship to A-LOAM's world for RViz goal transformations.
            world_frame = msg.header.frame_id.lstrip("/")
            if (world_frame and world_frame != self.local_frame and
                    self.pose_x_sign == self.pose_y_sign == self.yaw_sign == 1.0):
                origin_tf = TransformStamped()
                origin_tf.header.stamp = rospy.Time.now()
                origin_tf.header.frame_id = world_frame
                origin_tf.child_frame_id = self.local_frame
                origin_tf.transform.translation.x = base_x
                origin_tf.transform.translation.y = base_y
                origin_tf.transform.translation.z = base_z
                q = tf.transformations.quaternion_from_euler(0.0, 0.0, yaw)
                (origin_tf.transform.rotation.x, origin_tf.transform.rotation.y,
                 origin_tf.transform.rotation.z, origin_tf.transform.rotation.w) = q
                self.origin_tf.sendTransform(origin_tf)
            else:
                rospy.logwarn("world-to-local TF unavailable; use RViz Fixed Frame=%s. "
                              "External-frame goals require standard axis signs.", self.local_frame)
            rospy.loginfo("A-LOAM origin fixed: x=%.3f y=%.3f z=%.3f yaw=%.3f",
                          base_x, base_y, base_z, yaw)

        x0, y0, z0, yaw0, roll0, pitch0 = self.origin
        dx, dy = base_x - x0, base_y - y0
        c0, s0 = math.cos(yaw0), math.sin(yaw0)
        pose = Pose2D()
        pose.x = self.pose_x_sign * (c0 * dx + s0 * dy)
        pose.y = self.pose_y_sign * (-s0 * dx + c0 * dy)
        pose.theta = wrap_pi(yaw - yaw0)
        self.pub.publish(pose)

        # A-LOAM's odometry message leaves twist empty. Estimate the body
        # velocity from consecutive startup-relative poses. The resulting
        # twist is expressed in base_link, matching the training convention.
        stamp = msg.header.stamp if msg.header.stamp.to_sec() > 0.0 else rospy.Time.now()
        linear_body = (0.0, 0.0, 0.0)
        angular_z = 0.0
        if self.previous_motion is not None:
            (previous_stamp, previous_x, previous_y, previous_z,
             previous_roll, previous_pitch, previous_yaw) = self.previous_motion
            dt = (stamp - previous_stamp).to_sec()
            if self.min_velocity_dt <= dt <= self.max_velocity_dt:
                dx_local = pose.x - previous_x
                dy_local = pose.y - previous_y
                c, s = math.cos(pose.theta), math.sin(pose.theta)
                dx_body = c * dx_local + s * dy_local
                dy_body = -s * dx_local + c * dy_local
                linear_body = (dx_body / dt, dy_body / dt,
                               (base_z - previous_z) / dt)
                angular_z = wrap_pi(pose.theta - previous_yaw) / dt
                angular_xy = (wrap_pi(raw_roll - previous_roll) / dt,
                              wrap_pi(raw_pitch - previous_pitch) / dt)
            else:
                angular_xy = (0.0, 0.0)
        else:
            angular_xy = (0.0, 0.0)
        self.previous_motion = (stamp, pose.x, pose.y, base_z,
                                raw_roll, raw_pitch, pose.theta)

        odom = Odometry()
        odom.header.stamp = stamp
        odom.header.frame_id = self.local_frame
        odom.child_frame_id = "base_link"
        odom.pose.pose.position.x = pose.x
        odom.pose.pose.position.y = pose.y
        odom.pose.pose.position.z = base_z - z0
        odom.pose.pose.orientation.z = math.sin(pose.theta * 0.5)
        odom.pose.pose.orientation.w = math.cos(pose.theta * 0.5)
        odom.twist.twist.linear.x = linear_body[0]
        odom.twist.twist.linear.y = linear_body[1]
        odom.twist.twist.linear.z = linear_body[2]
        odom.twist.twist.angular.x = angular_xy[0]
        odom.twist.twist.angular.y = angular_xy[1]
        odom.twist.twist.angular.z = angular_z
        self.odom_pub.publish(odom)
        if self.publish_base_tf:
            self.base_tf.sendTransform(
                (pose.x, pose.y, base_z - z0),
                (0.0, 0.0, math.sin(pose.theta * 0.5), math.cos(pose.theta * 0.5)),
                stamp, "base_link", self.local_frame)

        if self.should_log():
            rospy.loginfo("A-LOAM pose x=%.3f y=%.3f yaw=%.3f frame=%s child=%s",
                          pose.x, pose.y, pose.theta,
                          msg.header.frame_id, msg.child_frame_id)


if __name__ == "__main__":
    rospy.init_node("lidar_odom")
    AloamOdom()
    rospy.spin()
