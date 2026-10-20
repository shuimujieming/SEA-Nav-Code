#!/usr/bin/env python3
"""Project a PointCloud2 into a planar LaserScan in a target frame."""

import math

import numpy as np
import rospy
import sensor_msgs.point_cloud2 as point_cloud2
import tf
from sensor_msgs.msg import LaserScan, PointCloud2


class CloudToScan:
    def __init__(self):
        self.input_topic = rospy.get_param("~input_topic", "/cloud_registered_lidar")
        self.output_topic = rospy.get_param("~output_topic", "/scan")
        self.target_frame = rospy.get_param("~target_frame", "base_link").lstrip("/")
        self.min_height = float(rospy.get_param("~min_height", -0.35))
        self.max_height = float(rospy.get_param("~max_height", 0.35))
        self.angle_min = float(rospy.get_param("~angle_min", -math.pi))
        self.angle_max = float(rospy.get_param("~angle_max", math.pi))
        self.angle_increment = math.radians(float(rospy.get_param("~angle_increment_deg", 1.0)))
        self.range_min = float(rospy.get_param("~range_min", 0.1))
        self.range_max = float(rospy.get_param("~range_max", 30.0))
        self.tf_listener = tf.TransformListener()
        self.pub = rospy.Publisher(self.output_topic, LaserScan, queue_size=2)
        self.sub = rospy.Subscriber(self.input_topic, PointCloud2, self.callback, queue_size=1)
        rospy.loginfo("cloud_to_scan_ros1: %s -> %s in %s", self.input_topic,
                      self.output_topic, self.target_frame)

    def callback(self, msg):
        source_frame = msg.header.frame_id.lstrip("/")
        try:
            self.tf_listener.waitForTransform(
                self.target_frame, source_frame, msg.header.stamp, rospy.Duration(0.2))
            translation, rotation = self.tf_listener.lookupTransform(
                self.target_frame, source_frame, msg.header.stamp)
        except (tf.LookupException, tf.ConnectivityException, tf.ExtrapolationException) as exc:
            rospy.logwarn_throttle(5.0, "cloud_to_scan_ros1: TF %s -> %s unavailable: %s",
                                   source_frame, self.target_frame, exc)
            return

        transform = tf.transformations.quaternion_matrix(rotation)
        transform[:3, 3] = translation
        count = int(math.ceil((self.angle_max - self.angle_min) / self.angle_increment))
        ranges = np.full(count, np.inf, dtype=np.float32)
        try:
            points = point_cloud2.read_points(msg, field_names=("x", "y", "z"), skip_nans=True)
            for x, y, z in points:
                px, py, pz, _ = transform.dot((x, y, z, 1.0))
                if pz < self.min_height or pz > self.max_height:
                    continue
                distance = math.hypot(px, py)
                if distance < self.range_min or distance > self.range_max:
                    continue
                angle = math.atan2(py, px)
                index = int(math.floor((angle - self.angle_min) / self.angle_increment))
                if 0 <= index < count and distance < ranges[index]:
                    ranges[index] = distance
        except (ValueError, TypeError, KeyError) as exc:
            rospy.logerr_throttle(5.0, "cloud_to_scan_ros1: invalid PointCloud2: %s", exc)
            return

        scan = LaserScan()
        scan.header.stamp = msg.header.stamp if msg.header.stamp.to_sec() else rospy.Time.now()
        scan.header.frame_id = self.target_frame
        scan.angle_min = self.angle_min
        scan.angle_max = self.angle_max
        scan.angle_increment = self.angle_increment
        scan.time_increment = 0.0
        scan.scan_time = 0.1
        scan.range_min = self.range_min
        scan.range_max = self.range_max
        scan.ranges = ranges.tolist()
        self.pub.publish(scan)


if __name__ == "__main__":
    rospy.init_node("cloud_to_scan")
    CloudToScan()
    rospy.spin()
