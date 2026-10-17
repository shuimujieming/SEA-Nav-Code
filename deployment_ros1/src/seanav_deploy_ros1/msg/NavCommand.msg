std_msgs/Header header

# Physical command sent to the locomotion layer, not normalized policy output.
# vx and vy are m/s in base_link; vyaw is rad/s about base_link +Z.
float32 vx
float32 vy
float32 vyaw

bool enable
bool emergency_stop
