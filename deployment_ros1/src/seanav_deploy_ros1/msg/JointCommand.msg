std_msgs/Header header

# Low-level PD target interface. All arrays must have the same length and use
# the Lite3 joint order documented in Lite3State.msg.
string[] joint_names
float32[] position
float32[] velocity
float32[] effort
float32[] kp
float32[] kd

bool enable
bool emergency_stop
