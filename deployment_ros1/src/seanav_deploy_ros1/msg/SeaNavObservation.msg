std_msgs/Header header

# One step is 55 values; history is oldest-to-newest and flattened.
# [gravity(3), previous_nav_command(3), body_lin_vel(3), body_ang_vel(3),
#  log2(rays_m)(41), goal_local_xy(2)] repeated history_length times.
uint32 history_length
uint32 step_size
float32[] observation

# Current unflattened values are included for inspection and debugging.
float32[] proprioception
float32[] rays_m
float32[] rays_log2
# Last accepted target in body XY, available with a fresh pose even if valid=false.
# Empty until a target is set, or when pose is missing/stale.
float32[] goal_local
float32[] previous_nav_command

bool valid
