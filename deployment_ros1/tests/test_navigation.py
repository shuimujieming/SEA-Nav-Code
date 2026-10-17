"""Offline contract tests; no ROS master, TCP connection or robot required."""

import importlib.util
from copy import deepcopy
import json
import math
from pathlib import Path
import threading
import time
import unittest
from unittest.mock import Mock, patch

import rospy
import numpy as np
from geometry_msgs.msg import Pose2D, PoseStamped, PoseWithCovarianceStamped
from nav_msgs.msg import Odometry
from seanav_deploy_ros1.msg import Lite3State, SeaNavObservation

ROOT = Path(__file__).resolve().parents[2]
SCRIPTS = ROOT / "deployment_ros1/src/seanav_deploy_ros1/scripts"


def module(name):
    spec = importlib.util.spec_from_file_location(name, SCRIPTS / (name + ".py"))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


policy = module("sea_nav_policy_ros1")
interface = module("sea_nav_interface_ros1")
odom_module = module("lidar_odom_ros1")


class NavigationTest(unittest.TestCase):
    def setUp(self):
        rospy.rostime.set_rostime_initialized(True)
        rospy.rostime._set_rostime(rospy.Time(100))

    def test_onnx_runs_without_training_dependencies(self):
        with patch.dict("sys.modules", {"torch": None, "rsl_rl": None}):
            runtime = policy.OnnxPolicy(ROOT / "deployment_ros1/models/sea_nav_model_2000.onnx")
            inputs = np.zeros((10, 55), dtype=np.float32)
            inputs[:, 12:53] = math.log2(3.0)
            inputs[-1, -2] = 2.0
            output = runtime.infer(inputs.ravel().tolist())
            self.assertEqual(output.shape, (1, 3))
            self.assertTrue(np.isfinite(output).all())
            with self.assertRaisesRegex(ValueError, r"must be a .onnx"):
                policy.OnnxPolicy("model_2000.pt")

    def runner(self):
        node = policy.SeaNavPolicy.__new__(policy.SeaNavPolicy)
        node.runtime = Mock()
        node.runtime.infer.return_value = np.array([[0.4, -0.2, 0.1]], dtype=np.float32)
        node.inference_pub = Mock()
        node.run = True
        node.fresh_s = 0.25
        node.goal_tolerance = 0.3
        node.command_min = [-0.5, -0.5, -0.8]
        node.command_max = [0.5, 0.5, 0.8]
        node.lock = threading.Lock()
        node.motion_ready = True
        node.motion_time = node.observation_time = time.monotonic()
        node.last_processed = None
        node.pub, node.preview_pub = Mock(), Mock()
        obs = SeaNavObservation()
        obs.header.stamp = rospy.Time.now()
        obs.valid = True
        obs.history_length, obs.step_size = 10, 55
        obs.observation = [0.0] * 550
        obs.observation[-2] = 2.0
        node.observation = obs
        return node

    def test_velocity_and_run_gate(self):
        node = self.runner()
        node.tick(None)
        command = node.pub.publish.call_args[0][0]
        self.assertTrue(command.enable)
        self.assertAlmostEqual(command.vx, 0.4)
        node = self.runner()
        node.run = False
        node.tick(None)
        self.assertFalse(node.pub.publish.call_args[0][0].enable)
        self.assertEqual(node.pub.publish.call_args[0][0].vx, 0.0)
        self.assertAlmostEqual(node.preview_pub.publish.call_args[0][0].vx, 0.4)

    def test_navigation_velocity_limits(self):
        for sign in (1, -1):
            node = self.runner()
            node.runtime.infer.return_value = np.array([[3 * sign] * 3], dtype=np.float32)
            node.tick(None)
            for publisher in (node.pub, node.preview_pub):
                msg = publisher.publish.call_args[0][0]
                self.assertEqual((msg.vx, msg.vy, msg.vyaw), (0.5 * sign, 0.5 * sign, 0.8 * sign))

    def test_invalid_stale_arrived_and_disabled_stop(self):
        cases = [lambda n: setattr(n, "observation", None),
                 lambda n: setattr(n.observation, "valid", False),
                 lambda n: setattr(n, "observation_time", time.monotonic() - 1),
                 lambda n: setattr(n.observation.header, "stamp", rospy.Time(98)),
                 lambda n: setattr(n.observation, "history_length", 9),
                 lambda n: n.observation.observation.__setitem__(0, float("nan")),
                 lambda n: n.observation.observation.__setitem__(-2, 0.1),
                 lambda n: setattr(n, "motion_ready", False),
                 lambda n: setattr(n, "motion_time", time.monotonic() - 1),
                 lambda n: setattr(n.runtime.infer, "return_value", np.full((1, 3), float("nan")))]
        for change in cases:
            with self.subTest(change=change), patch.object(rospy, "logerr_throttle"):
                node = self.runner()
                change(node)
                node.tick(None)
                command = node.pub.publish.call_args[0][0]
                self.assertFalse(command.enable)
                self.assertEqual((command.vx, command.vy, command.vyaw), (0, 0, 0))

    def test_motion_host_mode_controls_navigation(self):
        node = self.runner()
        state = Lite3State()
        # The robot is standing in manual RL; perception must not take over.
        state.standing, state.enabled = True, False
        node.motion_callback(state)
        node.tick(None)
        self.assertFalse(node.pub.publish.call_args[0][0].enable)
        # Local navigation key enables the perception command stream.
        state.enabled = True
        node.motion_callback(state)
        node.observation_callback(deepcopy(node.observation))
        node.tick(None)
        self.assertTrue(node.pub.publish.call_args[0][0].enable)
        # Returning to manual sends disabled zeros again.
        state.enabled = False
        node.motion_callback(state)
        node.observation_callback(deepcopy(node.observation))
        node.tick(None)
        command = node.pub.publish.call_args[0][0]
        self.assertFalse(command.enable)
        self.assertEqual((command.vx, command.vy, command.vyaw), (0, 0, 0))

    def test_rviz_goal_transform_and_pose_tool(self):
        node = interface.SeaNavInterface.__new__(interface.SeaNavInterface)
        node.goal_frame = "odom"
        node.goal_received = False
        node.current_goal_pub = Mock()
        node.observation_lock = threading.RLock()
        node.history = []
        node.tf_listener = Mock()
        clicked = PoseStamped()
        clicked.header.frame_id = "camera_init"
        transformed = PoseStamped()
        transformed.pose.position.x, transformed.pose.position.y = 2, 3
        node.tf_listener.transformPose.return_value = transformed
        with patch.object(rospy, "loginfo"):
            node.rviz_goal_callback(clicked)
            self.assertTrue(node.goal_received)
            self.assertEqual((node.goal_x, node.goal_y), (2, 3))
            target = node.current_goal_pub.publish.call_args[0][0]
            self.assertEqual(target.header.frame_id, "odom")
            self.assertEqual((target.pose.position.x, target.pose.position.y), (2, 3))
            node.tf_listener.transformPose.assert_called_once_with("odom", clicked)
            pose = PoseWithCovarianceStamped()
            pose.header.frame_id = "odom"
            pose.pose.pose.position.x = 4
            node.rviz_pose_callback(pose)
            self.assertEqual(node.goal_x, 4)

    def test_relative_goal_available_without_navigation_observation(self):
        node = interface.SeaNavInterface.__new__(interface.SeaNavInterface)
        node.goal_received = node.has_goal = True
        node.goal_x, node.goal_y = 2.0, 3.0
        node.pose = Pose2D(x=2.0, y=1.0, theta=math.pi / 2)
        node.last_pose_time = rospy.Time.now()
        node.fresh_s = 0.25
        node.motion_state = None
        node.history = ["old observation"]
        node.observation_pub = Mock()
        node._publish_observation()
        msg = node.observation_pub.publish.call_args[0][0]
        self.assertFalse(msg.valid)
        self.assertEqual(msg.observation, [])
        self.assertEqual(node.history, [])
        np.testing.assert_allclose(msg.goal_local, [2.0, 0.0], atol=1e-6)
        self.assertEqual(msg.header.frame_id, "base_link")
        # Reaching the target ends navigation but keeps the diagnostic target.
        node.goal_received = False
        np.testing.assert_allclose(node._diagnostic_goal_local(), [2.0, 0.0], atol=1e-6)
        node.last_pose_time = rospy.Time(99)
        self.assertEqual(node._diagnostic_goal_local(), [])
        node.last_pose_time = rospy.Time.now()
        node.has_goal = False
        self.assertEqual(node._diagnostic_goal_local(), [])

    def test_inferred_command_serialized_to_motion_host(self):
        runner = self.runner()
        runner.tick(None)
        command = runner.pub.publish.call_args[0][0]
        bridge = interface.SeaNavInterface.__new__(interface.SeaNavInterface)
        bridge.tcp_lock = threading.Lock()
        bridge.motion_host, bridge.motion_port = "127.0.0.1", 29001
        bridge.tcp_reconnect_s = 1
        bridge.pending_command = None
        bridge.nav_command_callback(command)
        # Simulate a fresh command arriving after connection, as a running
        # policy does. The bridge intentionally drops commands queued offline.
        fake_socket = Mock()
        fake_socket.recv.return_value = b""
        def connected(*args, **kwargs):
            return fake_socket
        def started(*args):
            if args and args[0] == "SEA-Nav TCP connected to motion host":
                bridge.nav_command_callback(command)
        with patch.object(interface.socket, "create_connection", side_effect=connected), \
                patch.object(rospy, "is_shutdown", side_effect=[False, False, True]), \
                patch.object(rospy, "loginfo", side_effect=started), \
                patch.object(rospy, "logwarn_throttle"), patch.object(rospy, "sleep"):
            bridge.tcp_loop()
        payload = fake_socket.sendall.call_args[0][0]
        self.assertTrue(payload.endswith(b"\n"))
        packet = json.loads(payload)
        self.assertEqual(packet["type"], "nav_command")
        self.assertTrue(packet["enable"])
        self.assertAlmostEqual(packet["vx"], 0.4)

    def test_startup_origin_tf_agrees_with_pose(self):
        params = {"~skip_first_msgs": 0, "~origin_settle_msgs": 1, "~debug_log_hz": 0}
        with patch.object(rospy, "get_param", side_effect=lambda k, d: params.get(k, d)), \
                patch.object(rospy, "Publisher", side_effect=lambda *a, **k: Mock()), \
                patch.object(rospy, "Subscriber"), \
                patch.object(rospy, "loginfo"), \
                patch.object(odom_module.tf2_ros, "StaticTransformBroadcaster"), \
                patch.object(odom_module.tf, "TransformBroadcaster"):
            node = odom_module.AloamOdom()
            msg = Odometry()
            msg.header.frame_id = "/camera_init"
            msg.header.stamp = rospy.Time(100)
            msg.pose.pose.position.x, msg.pose.pose.position.y = 5, 7
            msg.pose.pose.orientation.z = math.sin(math.pi / 4)
            msg.pose.pose.orientation.w = math.cos(math.pi / 4)
            node.callback(msg)
            origin = node.origin_tf.sendTransform.call_args[0][0]
            self.assertEqual(origin.child_frame_id, "odom")
            self.assertEqual(origin.transform.translation.x, 5)
            msg.pose.pose.position.y += 1  # Forward along startup yaw=pi/2.
            msg.header.stamp = rospy.Time.from_sec(100.1)
            node.callback(msg)
            pose = node.pub.publish.call_args[0][0]
            self.assertAlmostEqual(pose.x, 1)
            self.assertAlmostEqual(pose.y, 0)
            translation = node.base_tf.sendTransform.call_args[0][0]
            self.assertAlmostEqual(translation[0], pose.x)


if __name__ == "__main__":
    unittest.main()
