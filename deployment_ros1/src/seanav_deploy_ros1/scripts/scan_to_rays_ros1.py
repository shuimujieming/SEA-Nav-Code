#!/usr/bin/env python3
"""Convert a ROS1 LaserScan into SEA-Nav's 41-ray LaserScan contract."""

import math

import numpy as np
import rospy
from sensor_msgs.msg import LaserScan


def wrap_pi(angle):
    return (angle + math.pi) % (2.0 * math.pi) - math.pi


class ScanToRays:
    def __init__(self):
        self.input_topic = rospy.get_param("~input_topic", "/scan")
        self.output_topic = rospy.get_param("~output_topic", "/rays")
        self.output_frame = rospy.get_param("~output_frame", "base_link")
        self.yaw_offset = float(rospy.get_param("~laser_yaw_offset_rad", 0.0))
        self.invert_angle = bool(rospy.get_param("~invert_angle", False))
        self.range_min = float(rospy.get_param("~range_min", 0.1))
        self.range_max = float(rospy.get_param("~range_max", 3.0))
        self.bin_width = math.radians(float(rospy.get_param("~bin_width_deg", 6.0)))

        self.target_angles = np.linspace(-2.0 * math.pi / 3.0, 2.0 * math.pi / 3.0, 41)
        self.pub = rospy.Publisher(self.output_topic, LaserScan, queue_size=10)
        self.sub = rospy.Subscriber(self.input_topic, LaserScan, self.callback, queue_size=10)
        rospy.loginfo(
            "scan_to_rays_ros1: %s -> %s, 41 rays [-120,+120] deg, yaw_offset=%.3f, invert=%s",
            self.input_topic, self.output_topic, self.yaw_offset, self.invert_angle,
        )

    def callback(self, msg):
        ranges = np.asarray(msg.ranges, dtype=np.float32)
        if ranges.size == 0 or msg.angle_increment == 0.0:
            return
        raw_angles = msg.angle_min + np.arange(ranges.size, dtype=np.float32) * msg.angle_increment
        sign = -1.0 if self.invert_angle else 1.0
        output = []
        for base_angle in self.target_angles:
            laser_angle = sign * (base_angle - self.yaw_offset)
            diff = np.abs(wrap_pi(raw_angles - laser_angle))
            candidates = ranges[diff <= 0.5 * self.bin_width]
            candidates = candidates[np.isfinite(candidates) & (candidates > 0.0)]
            if candidates.size:
                value = float(np.min(candidates))
            else:
                value = float(ranges[int(np.argmin(diff))])
                if not np.isfinite(value) or value <= 0.0:
                    value = self.range_max
            output.append(float(np.clip(value, self.range_min, self.range_max)))

        out = LaserScan()
        out.header.stamp = msg.header.stamp if msg.header.stamp.to_sec() > 0.0 else rospy.Time.now()
        out.header.frame_id = self.output_frame
        out.angle_min = float(self.target_angles[0])
        out.angle_max = float(self.target_angles[-1])
        out.angle_increment = float(self.target_angles[1] - self.target_angles[0])
        out.scan_time = msg.scan_time if msg.scan_time > 0.0 else 0.1
        out.range_min = self.range_min
        out.range_max = self.range_max
        out.ranges = output
        self.pub.publish(out)


if __name__ == "__main__":
    rospy.init_node("scan_to_rays")
    ScanToRays()
    rospy.spin()
