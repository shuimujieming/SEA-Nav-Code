#!/usr/bin/env python3
"""Small ROS1 terminal monitor for the 41-ray output."""

import math

import rospy
from sensor_msgs.msg import LaserScan


class Monitor:
    def __init__(self):
        self.topic = rospy.get_param("~topic", "/rays")
        self.warn_distance = float(rospy.get_param("~warn_distance", 0.6))
        self.last = rospy.Time(0)
        rospy.Subscriber(self.topic, LaserScan, self.callback, queue_size=1)

    def callback(self, msg):
        now = rospy.Time.now()
        if (now - self.last).to_sec() < 0.2:
            return
        self.last = now
        values = list(msg.ranges)
        if not values:
            return
        finite = [(i, float(v)) for i, v in enumerate(values) if math.isfinite(v)]
        nearest_i, nearest = min(finite, key=lambda x: x[1]) if finite else (-1, float("nan"))
        front = values[min(20, len(values) - 1)]
        print("\033[2J\033[H", end="")
        print("SEA-Nav ROS1 /rays monitor")
        print("idx 0=-120 deg right, idx 20=front, idx 40=+120 deg left")
        print("count=%d range=[%.2f, %.2f] m" % (len(values), msg.range_min, msg.range_max))
        print("nearest: idx=%d dist=%.3f m" % (nearest_i, nearest))
        print("front idx20=%.3f m %s" % (front, "!" if front < self.warn_distance else ""))
        print("sample:", " ".join("%02d=%.2f" % (i, values[i]) for i in (0, 10, 20, 30, 40) if i < len(values)))


if __name__ == "__main__":
    rospy.init_node("rays_monitor")
    Monitor()
    rospy.spin()
