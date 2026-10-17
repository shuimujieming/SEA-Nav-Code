std_msgs/Header header

# Joint order must match the Lite3 training order:
# FL_HipX, FL_HipY, FL_Knee, FR_HipX, FR_HipY, FR_Knee,
# HL_HipX, HL_HipY, HL_Knee, HR_HipX, HR_HipY, HR_Knee.
string[] joint_names
float32[] joint_position
float32[] joint_velocity
float32[] joint_torque

# All vectors are in the robot base frame. Each array has length 3.
float32[] projected_gravity
float32[] base_linear_velocity
float32[] base_angular_velocity

# Last 12-D locomotion action and last 3-D navigation command.
float32[] last_loco_action
float32[] last_nav_command

# TCP bridge: standing in RLControl or Navigation; enabled only in Navigation.
bool standing
bool enabled
