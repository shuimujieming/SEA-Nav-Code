cmake_minimum_required(VERSION 3.0.2)
project(seanav_deploy_ros1)

find_package(catkin REQUIRED COMPONENTS
  geometry_msgs
  message_generation
  nav_msgs
  rospy
  sensor_msgs
  std_msgs
  tf
  tf2_ros
)

add_message_files(
  FILES
  Lite3State.msg
  SeaNavObservation.msg
  NavCommand.msg
  JointCommand.msg
)

generate_messages(DEPENDENCIES std_msgs)

catkin_package(CATKIN_DEPENDS message_runtime std_msgs)

catkin_install_python(PROGRAMS
  scripts/scan_to_rays_ros1.py
  scripts/lidar_odom_ros1.py
  scripts/rays_monitor_ros1.py
  scripts/sea_nav_interface_ros1.py
  scripts/sea_nav_policy_ros1.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(FILES scripts/sea_nav_inference.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch config msg
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)
