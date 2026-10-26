#!/usr/bin/env python3
"""Run SEA-Nav with ONNX Runtime CPU on the perception host."""

import math
import os
import sys
import threading
import time

import rospy
import numpy as np
from std_msgs.msg import Float32

from seanav_deploy_ros1.msg import Lite3State, NavCommand, SeaNavObservation


# Catkin devel wrappers execute this source file from another directory.
sys.path.insert(0, os.path.dirname(os.path.realpath(__file__)))
from sea_nav_inference import OnnxPolicy


class SeaNavPolicy:
    def __init__(self):
        expand = lambda path: os.path.abspath(os.path.expandvars(os.path.expanduser(path)))
        model_path = expand(rospy.get_param("~model_path"))
        self.runtime = OnnxPolicy(model_path, int(rospy.get_param("~onnx_threads", 1)))
        # This gate affects velocity transmission, not the motion host FSM.
        self.run = bool(rospy.get_param("~run", False))
        self.fresh_s = float(rospy.get_param("~fresh_s", 0.25))
        self.goal_tolerance = float(rospy.get_param("~goal_tolerance", 0.3))
        self.command_min = rospy.get_param("~command_min", [-0.5, -0.5, -1.0])
        self.command_max = rospy.get_param("~command_max", [1.0, 0.5, 1.0])
        if (len(self.command_min) != 3 or len(self.command_max) != 3 or
                not all(math.isfinite(float(lo)) and math.isfinite(float(hi)) and lo <= 0 <= hi
                        for lo, hi in zip(self.command_min, self.command_max))):
            raise ValueError("command_min/max must be finite 3-vectors containing zero")
        self.lock = threading.Lock()
        self.observation = None
        self.observation_time = 0.0
        self.motion_ready = False
        self.motion_time = 0.0
        self.last_processed = None
        self.pub = rospy.Publisher(rospy.get_param("~nav_command_topic", "/sea_nav/nav_command"),
                                   NavCommand, queue_size=1)
        self.preview_pub = rospy.Publisher("/sea_nav/policy_command", NavCommand, queue_size=1)
        self.inference_pub = rospy.Publisher("/sea_nav/inference_ms", Float32, queue_size=1)
        rospy.Subscriber(rospy.get_param("~observation_topic", "/sea_nav/observation"),
                         SeaNavObservation, self.observation_callback, queue_size=1)
        rospy.Subscriber(rospy.get_param("~motion_state_topic", "/sea_nav/motion_state"),
                         Lite3State, self.motion_callback, queue_size=1)
        rospy.on_shutdown(self.stop)
        self.timer = rospy.Timer(rospy.Duration(0.02), self.tick)
        rospy.loginfo("SEA-Nav loaded: %s; run=%s", self.runtime.description, self.run)

    def observation_callback(self, msg):
        with self.lock:
            self.observation = msg
            self.observation_time = time.monotonic()

    def motion_callback(self, msg):
        with self.lock:
            # Motion host enables navigation explicitly with its local mode key.
            self.motion_ready = bool(msg.enabled and msg.standing)
            self.motion_time = time.monotonic()

    @staticmethod
    def command(values=(0.0, 0.0, 0.0), enable=False):
        msg = NavCommand()
        msg.header.stamp = rospy.Time.now()
        msg.header.frame_id = "base_link"
        msg.vx, msg.vy, msg.vyaw = values
        msg.enable = enable
        msg.emergency_stop = False
        return msg

    def stop(self):
        self.pub.publish(self.command())

    def tick(self, _event):
        with self.lock:
            obs, received = self.observation, self.observation_time
            motion_ready, motion_time = self.motion_ready, self.motion_time
        now = time.monotonic()
        if (obs is None or now - received > self.fresh_s or not obs.valid or
                not 0.0 <= (rospy.Time.now() - obs.header.stamp).to_sec() <= self.fresh_s or
                obs.history_length != 10 or obs.step_size != 55 or
                len(obs.observation) != 550 or
                not all(math.isfinite(value) for value in obs.observation)):
            self.stop()
            return
        # The current goal is the last two training inputs. Do not infer goal
        # distance from a separately sampled pose or a diagnostic field.
        if math.hypot(*obs.observation[-2:]) <= self.goal_tolerance:
            self.stop()
            return
        if self.last_processed is obs:
            return  # Do not reuse one sensor sample as another policy step.
        self.last_processed = obs
        try:
            started = time.perf_counter()
            output = self.runtime.infer(obs.observation)
            inference_ms = (time.perf_counter() - started) * 1000.0
            if tuple(output.shape) == (1, 2):
                # Lite3 play policies emit [vx, vyaw].  NavCommand keeps the
                # legacy [vx, vy, vyaw] order, so insert zero lateral speed.
                output = np.concatenate((output[:, :1], np.zeros_like(output[:, :1]),
                                         output[:, 1:]), axis=1)
            if tuple(output.shape) != (1, 3) or not np.isfinite(output).all():
                raise ValueError("non-finite or incorrectly shaped policy output")
            self.inference_pub.publish(Float32(data=inference_ms))
            if inference_ms > 20.0:
                rospy.logwarn_throttle(5.0, "SEA-Nav inference %.2f ms exceeds 20 ms period",
                                       inference_ms)
            values = output[0].tolist()
            values = [max(lo, min(hi, max(-3.0, min(3.0, value))))
                      for value, lo, hi in zip(values, self.command_min, self.command_max)]
            # Filtering is already performed on the motion host (alpha=0.5).
            self.preview_pub.publish(self.command(values))
            allowed = (self.run and motion_ready and time.monotonic() - motion_time <= self.fresh_s
                       and time.monotonic() - received <= self.fresh_s)
            self.pub.publish(self.command(values, True) if allowed else self.command())
        except Exception as exc:
            self.stop()
            rospy.logerr_throttle(2.0, "SEA-Nav inference failed: %s", exc)


if __name__ == "__main__":
    rospy.init_node("sea_nav_policy")
    try:
        node = SeaNavPolicy()
    except Exception as exc:
        rospy.logfatal("Cannot start SEA-Nav policy: %s", exc)
        sys.exit(1)
    rospy.spin()
