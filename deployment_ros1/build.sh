#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"
ROS_SETUP="${ROS_SETUP:-/opt/ros/noetic/setup.bash}"
if [ ! -f "${ROS_SETUP}" ]; then
  echo "ROS setup file not found: ${ROS_SETUP}" >&2
  exit 1
fi
source "${ROS_SETUP}"
catkin_make
echo "[build] done; source deployment_ros1/devel/setup.bash"
