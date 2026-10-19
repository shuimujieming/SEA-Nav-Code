# SEA-Nav ROS1 deployment with Velodyne VLP-16

This is a separate ROS1 catkin workspace. It does not modify the ROS2 package
under `deployment/`.

## Pipeline

```text
VLP-16 -> /velodyne_points -> pointcloud_to_laserscan -> /scan
       -> scan_to_rays_ros1 -> /rays (41 distances, -120..+120 deg)
       -> A-LOAM            -> /aft_mapped_to_init_high_frec
       -> lidar_odom_ros1   -> /pose (Pose2D)
```

The training contract stays unchanged: 41 rays, six degrees per ray, meters
clipped to 0.1--3.0, followed by the policy's existing `log2` encoding.

## Build

Install the ROS1 Velodyne and pointcloud conversion packages, then build from a
catkin workspace:

```bash
cd deployment_ros1
ROS_SETUP=/opt/ros/noetic/setup.bash ./build.sh
```

本工作空间已包含 `src/A-LOAM`，无需加载外部 `aloam_ws`。
每个新终端都要先加载 ROS，再加载本工作空间；否则生成的 Python 消息包
`seanav_deploy_ros1.msg` 不会出现在 `PYTHONPATH` 中，并会出现
`ModuleNotFoundError: No module named 'seanav_deploy_ros1'`：

```bash
source /opt/ros/noetic/setup.bash
source /home/shuimujieming/SEA-Nav-Code/deployment_ros1/devel/setup.bash
python3 -c "from seanav_deploy_ros1.msg import Lite3State, NavCommand, SeaNavObservation; print('ROS1 messages OK')"
```

确认输出 `ROS1 messages OK` 后，再在同一个终端执行 `roslaunch` 或 `rosrun`。
如果曾经先 source 过工作空间，之后又 source 了 `/opt/ros/noetic/setup.bash`，
需要按上面的顺序重新 source 一次。

不要在此之后加载外部 `/home/shuimujieming/aloam_ws/devel/setup.bash`，
它可能覆盖本工作空间的消息路径。可用 `rospack find aloam_velodyne` 确认
实际使用的是本工作空间的 `src/A-LOAM`。

## Run

```bash
roslaunch seanav_deploy_ros1 perception_vlp16.launch
rosrun seanav_deploy_ros1 rays_monitor_ros1.py
```

Start perception, the navigation interface and the monitor together:

```bash
roslaunch seanav_deploy_ros1 deploy.launch
```

`deploy.launch` currently includes `perception_vlp16.launch` and the monitor;
do not launch perception a second time. The motion host runs
`Lite3_deploy/build/rl_deploy` independently. The perception host sends navigation
commands over TCP; it does not start the locomotion executable.

## ONNX CPU 推理（推荐用于仅 CPU 的感知主机）

已接入 ONNX Runtime `CPUExecutionProvider`，使用 FP32、完整图优化和固定
`[1,550]` 输入。部署命令统一使用 `[vx, vy, vyaw]` 三维；Lite3 的 play
策略原始输出 `[vx, vyaw]` 时，导出端和部署端都会在中间插入一个恒为 0 的
`vy`，因此可以直接加载二维或三维输出的 ONNX 模型。保留 encoder、导航头、
alpha 头以及 **CBF 层**，部署端只加载 `.onnx` 导航模型，不需要 PyTorch、
`rsl_rl` 或 Isaac Gym。

### 1. 导出训练模型

在能运行 Isaac Gym 的训练环境、项目根目录执行（无需 ROS）：

```bash
python -m pip install -r training/legged_gym/requirements-export-onnx.txt
python training/legged_gym/legged_gym/scripts/play.py \
  --task lite3 --load_run 10_13_19-18-35_ --checkpoint 2000 \
  --export_onnx --onnx_output deployment_ros1/models/sea_nav_model_2000.onnx
```

换用自己的 checkpoint 时修改 `--load_run` 和 `--checkpoint`。`play.py` 加载
策略后导出同一个 actor，沿用当前网络激活函数和 CBF buffers，随后继续仿真。
省略 `--onnx_output` 时，默认保存到该训练 run 下的 `exported/model_2000.onnx`；
不传导出参数则按原来的方式运行 play。
导出会执行 ONNX 结构检查、128 组 PyTorch/ONNX 数值对比（含近障碍输入），
通过后写入目标文件。CBF 的 `exp2` 转成 ONNX `Pow(2,x)`。
ONNX 导出统一通过训练侧 `play.py` 进行，导出依赖安装在训练环境。
`deployment_ros1` 只加载模型进行策略推理。

当前仓库已生成上述示例 ONNX，保留该 checkpoint 原有 CBF 参数和 ray 方向，
具体来源见 [models/README.md](models/README.md)。

### 2. 感知主机运行

在用于运行 ROS 节点的 Python 3.8 环境安装 CPU 运行时（无需安装 PyTorch）：

```bash
/usr/bin/python3 -m pip install --user --upgrade -r deployment_ros1/requirements-onnx.txt
source /opt/ros/noetic/setup.bash
source deployment_ros1/devel/setup.bash
roslaunch seanav_deploy_ros1 deploy.launch \
  enable_policy:=true run:=false \
  model_path:=/home/shuimujieming/SEA-Nav-Code/deployment_ros1/models/sea_nav_model_2000.onnx \
  onnx_threads:=1 policy_python:=/usr/bin/python3 \
  motion_host:=192.168.1.102
```

如果依赖装在虚拟环境中，将 `policy_python` 改为该环境的 Python，保持与
ROS Noetic 一致的 Python 3.8。重新构建工作空间后使用更新的节点。
在机器人本地按 B 进入导航、RViz 选目标，`run:=false` 下仅查看策略速度；
需要发送有效速度时用 `run:=true`。A 返回遥控 RL；遥控 RL 不接受导航速度。

若出现 `module compiled against API version 0xe but this version of numpy is 0xd`
或 `numpy.core.multiarray failed to import`，说明加载的 NumPy C API 低于某个
二进制扩展所需的版本。部署依赖固定为 Python 3.8 可用的 NumPy 1.24.4。
使用与 `policy_python` 相同的解释器升级依赖并检查实际加载路径：

```bash
/usr/bin/python3 -m pip install --user --upgrade -r deployment_ros1/requirements-onnx.txt
/usr/bin/python3 -c "import sys, numpy, onnxruntime; print(sys.executable); print(numpy.__version__, numpy.__file__); print(onnxruntime.__version__, onnxruntime.__file__)"
```

如果 `policy_python` 指向虚拟环境，请将上述 `/usr/bin/python3` 替换为该环境
的 Python，并去掉 `--user`。如果升级后仍加载旧 NumPy，检查 `PYTHONPATH`
和 `numpy.__file__` 是否指向另一个环境。修复后重新启动节点。

### 3. 在机载 CPU 上选线程数

小网络不需要占满 CPU。默认单线程，关闭 ORT 线程空转，减少与 A-LOAM 的
资源竞争；`onnx_threads` 只控制算子内部线程数，算子之间顺序执行。
在机载端运行下列独立测试，不需要 ROS 或 PyTorch：

```bash
python3 deployment_ros1/src/seanav_deploy_ros1/scripts/sea_nav_inference.py \
  --model deployment_ros1/models/sea_nav_model_2000.onnx \
  --threads 1 2 4 --iterations 1000
```

同时运行实际感知负载时，比较 P95/P99 延迟，再确定线程数。
节点也发布 `/sea_nav/inference_ms` (`std_msgs/Float32`)，包括输入转换和模型执行，
不含传感器、ROS 和 TCP 延迟。超过 20 ms 时打印节流告警：

```bash
rostopic echo /sea_nav/inference_ms
rostopic hz /sea_nav/policy_command
```

本开发机 Intel Core Ultra 9 285K、单线程、预热后计时 500 次的示例：

| 后端 | P50 | P95 |
| --- | --- | --- |
| ONNX Runtime CPU | 0.055 ms | 0.057 ms |

计时含 Python 列表转 FP32 输入；测试与 A-LOAM 未同时运行，不能作为机载端
延迟保证。策略周期仍为训练对应的 20 ms（50 Hz），不因推理变快而提高控制频率。

## RViz 选点与 ONNX 策略推理

感知主机上的完整链路：

```text
RViz goal -> sea_nav_interface_ros1 -> /sea_nav/observation (550)
                                     -> sea_nav_policy_ros1 (ONNX + CBF)
                                     -> /sea_nav/nav_command
                                     -> TCP -> 运动主机 Lite3_deploy
```

`model_path` 指向训练侧 `play.py --export_onnx` 导出的导航 `.onnx` 文件。
网络激活函数、encoder、导航头、alpha 头以及 CBF 已包含在模型中，
感知端通过 ONNX Runtime CPU 直接推理，以 50 Hz 运行。

已对仓库中 `training/legged_gym/logs/Lite3_pos_rough/10_13_19-18-35_/model_2000.pt`
导出的 ONNX 完成离线加载和推理检查。该 checkpoint 的 CBF `ray_unit_vectors` 覆盖
±90°，而 Lite3 的训练/部署 rays 是 ±120°。导出的 ONNX 保留了训练时的
CBF buffer；这个角度不一致是训练侧已有的问题，影响 CBF
的几何含义，需要统一训练配置并重新训练/验证，不能把当前 CBF 当作已验证的
实机避障保证。

使用安装了 `requirements-onnx.txt` 的 Python 3.8 环境；launch 会为该节点
追加系统 ROS Python 依赖路径：

```bash
source /opt/ros/noetic/setup.bash
source /home/shuimujieming/SEA-Nav-Code/deployment_ros1/devel/setup.bash
roslaunch seanav_deploy_ros1 deploy.launch \
  enable_policy:=true run:=false \
  model_path:=/absolute/path/to/sea_nav_model_2000.onnx \
  policy_python:=/usr/bin/python3 \
  motion_host:=192.168.1.102
```

在 RViz 中：

1. 将 **Fixed Frame** 设置为 `odom`（启动局部坐标系），显示 `/scan` 和 TF。
2. 用 **2D Nav Goal** 点击目标，默认话题 `/move_base_simple/goal`
   (`geometry_msgs/PoseStamped`)。
3. 也兼容 **2D Pose Estimate** 的 `/initialpose`
   (`geometry_msgs/PoseWithCovarianceStamped`)。此节点把它当作目标点，
   不会重置 A-LOAM 定位；有其他定位程序时建议使用 2D Nav Goal。
4. 当前策略只用目标的 x/y，不控制拖拽箭头的最终朝向。

`lidar_odom_ros1.py` 固定启动原点后发布 `camera_init -> odom` 静态 TF
和 `odom -> base_link` 动态 TF。RViz 也可使用 `camera_init` 选点，接口会
按消息时间将目标变换到 `odom`；变换不存在时拒绝该目标，不会直接混用坐标。
若另有节点发布 `odom -> base_link`，请在 `deploy_ros1.yaml` 设置
`publish_base_tf: false`。非标准轴符号配置无法用普通 TF 表达，需在 `odom`
中选点。修改里程计节点后应重启感知 launch。

查看推理与发送结果：

```bash
rostopic echo /sea_nav/current_goal
rostopic echo /sea_nav/observation/goal_local
rostopic echo /sea_nav/policy_command
rostopic echo /sea_nav/nav_command
rostopic echo /sea_nav/motion_state/last_nav_command
```

`/sea_nav/current_goal` 为锁存的 `geometry_msgs/PoseStamped`，表示接口最后接收的
目标点，坐标系为 `goal_frame`（默认 `odom`），单位米。RViz 目标会先转换到此
坐标系再发布；到达后保留最后目标值。默认等待选点时不会发布占位目标。
`/sea_nav/observation/goal_local` 是相对机器人当前位置、转到机身坐标系的
`[x, y]`，x 朝前、y 朝左。设置目标且 `/pose` 新鲜时即有值，支持在遥控模式
查看；到达后仍显示最后目标的相对位置。未设置目标或 pose 缺失/超时时为空。
该调试字段有值不代表策略观测有效，完整观测是否可用于推理仍由 `valid` 表示。

`run:=false` 时 `/sea_nav/policy_command` 显示限幅后的推理速度，
`/sea_nav/nav_command` 持续发送禁用的零速度。将上述启动命令改为
`run:=true` 后，在运动主机已进入 Navigation 导航模式且状态新鲜时，才发送有效速度。
底层运控由运动主机独立启动。

真机 Retroid：Y 站起，A 进入遥控 RL，B 进入导航，导航中按 A 返回遥控。
仅导航模式禁用摇杆方向；X 趴下、双摇杆按下进入阻尼仍然可用。
RL 模式只接受遥控器速度，感知端 TCP 连接及零速度消息不会接管遥控。
导航模式 TCP 超时或命令禁用时，机器人按已有滤波减速至零，不自动切回遥控。
运动主机需重新编译并运行更新后的 `Lite3_deploy/rl_deploy`。

可用 `rostopic echo /sea_nav/motion_state` 检查模式：
RL 为 `enabled: false, standing: true`；导航为两者 `true`。

默认 `require_goal:=true`，等待 RViz 或 `/goal` 选点才生成有效观测；
距离目标小于 `goal_tolerance:=0.3` 米后清除目标并等待下一次选点。
观测/运动状态超时、无效观测、推理失败均发送禁用的零速度。
运动主机仍有独立的 0.25 秒命令超时。速度单位为 m/s、m/s、rad/s，
感知端限幅为 `vx[-0.5,0.5]`、`vy[-0.5,0.5]`、`vyaw[-0.8,0.8]`；
`alpha=0.5` 滤波由运动主机完成，感知端不重复滤波。

The standard Velodyne launch included by `perception_vlp16.launch` may need
the VLP-16 model, device IP, and frame arguments adjusted for the installed
Velodyne driver version. A valid TF chain is required:

```text
base_link -> velodyne
```

`lidar_odom_ros1.py` subscribes to A-LOAM's
`/aft_mapped_to_init_high_frec` (`nav_msgs/Odometry`) and fixes the first stable
pose as the local `/pose` origin. To use A-LOAM odometry before mapping is
available, set `odom_topic` to `/laser_odom_to_init` in `deploy_ros1.yaml`.

The cloud is transformed to `base_link` before ray generation, so
`laser_yaw_offset_rad` is `0.0` by default. Place an obstacle one meter ahead
and verify `/rays[20]` is about 1.0 m. Tune `min_height` and `max_height` in the
launch file to exclude ground returns while retaining the robot-collision
height range.

If `/scan` is empty or RViz cannot display it with `base_link` as Fixed Frame,
check the transform first:

```bash
rosrun tf tf_echo base_link velodyne
rostopic echo /velodyne_points/header -n 1
rostopic hz /scan
```

For diagnosis only, set `target_frame:=velodyne`. If `/scan` then appears, the
point cloud driver is working and the missing piece is the TF to `base_link`:

```bash
roslaunch seanav_deploy_ros1 perception_vlp16.launch target_frame:=velodyne
```

The final deployment should use `target_frame:=base_link`, because the height
filter and the 41 ray angles must be defined in the robot frame.

The launch currently publishes a temporary static transform by default. Replace
the placeholder values at the top of `perception_vlp16.launch` after measuring
the real mounting pose. You can override them at launch time, for example:

```bash
roslaunch seanav_deploy_ros1 perception_vlp16.launch \
  publish_static_tf:=true velodyne_z:=0.60
```

Do not enable this option when the robot already publishes the same TF, since
duplicate transforms can make the point cloud appear unstable.

Before enabling motors, check:

```bash
rostopic hz /velodyne_points
rostopic hz /scan
rostopic hz /rays
rostopic echo /rays -n 1
rostopic echo /pose -n 1
rostopic echo /pose_odom -n 1
```

## Lite3 ROS1 control contract

The motion host runs `Lite3_deploy` and its TCP server independently;
the perception host runs this ROS1 client for observations and navigation commands.

```text
Motion host TCP server ----motion_state----> sea_nav_interface_ros1
                                      \
VLP-16 -> /rays ----------------------> sea_nav_interface_ros1
A-LOAM  -> /pose + /pose_odom --------/        |
/goal (Pose2D) -------------------------------+--> /sea_nav/observation
                                                        |
SEA-Nav policy runner <-- observation             policy output
                                                        |
Motion host TCP server <---nav_command------ sea_nav_interface_ros1
```

`/sea_nav/observation` is `SeaNavObservation` and contains the exact training
input: 10 steps x 55 values = 550 floats, oldest to newest. Every step is:

```text
projected_gravity[3]
previous_nav_command[3]
base_linear_velocity_body[3]
base_angular_velocity_body[3]
log2(rays_m[41])
goal_local_xy[2]
```

`/pose` is the startup-local `Pose2D` used for the goal transform. A-LOAM's
original odometry message has an empty twist, so `lidar_odom_ros1.py` computes
body-frame linear and angular velocity by finite differences and publishes it
as `/pose_odom` (`nav_msgs/Odometry`). Its twist is what the observation node
uses. The z, roll, and pitch components are derived from the A-LOAM pose too;
the planar `/pose` topic remains unchanged. Tune `min_velocity_dt` and
`max_velocity_dt` if A-LOAM timestamps are irregular.

Rays are clipped to `[0.1, 3.0]` meters before `log2`. The goal is supplied in
the same startup-local frame as `/pose` and converted to the robot body frame
using `/pose.theta`. By default the node waits for an explicit goal. RViz goals
or `geometry_msgs/Pose2D` on `/goal` (already in `odom`) set it at runtime.
With `require_goal:=false`, the initial goal is `(goal_x, goal_y)`.

`/sea_nav/nav_command` is `NavCommand`. Its `vx`, `vy`, and `vyaw` fields are
physical values in m/s, m/s, and rad/s. The Lite3 training and deployment
limits are `vx=[-0.5, 0.5]`, `vy=[-0.5, 0.5]`, and `vyaw=[-0.8, 0.8]`.
The command is the
navigation action passed to the locomotion policy; it is not a 12-joint motor
packet.

`JointCommand` is also defined for a future ROS-owned locomotion layer. It is a
12-joint PD target packet with `position`, `velocity`, `effort`, `kp`, and `kd`
arrays in the Lite3 joint order. The current observation node does not publish
this message because the locomotion policy and Motion SDK remain inside the
Lite3 controller. If that architecture is adopted, use `/lite3/joint_command`
and enforce an independent command timeout in the Motion SDK bridge.

The validated TCP `motion_state` is also published locally as
`/sea_nav/motion_state` (`seanav_deploy_ros1/Lite3State`) for inspection with
standard ROS tools. The vector fields `projected_gravity` and
`last_nav_command` are populated; joint fields remain empty because the motion
host does not send joint telemetry in the current protocol.

### TCP protocol

The two hosts use one bidirectional TCP connection carrying UTF-8 JSON lines.
Each line ends with `\n` and contains `"version": 1` plus a `"type"` field.
The motion host sends state frames to the perception host:

```json
{"version":1,"type":"motion_state","stamp":1710000000.12,
 "projected_gravity":[0.0,0.0,-1.0],
 "last_nav_command":[0.2,0.0,0.0],"enabled":true,"standing":true}
```

The perception host sends policy output frames back:

```json
{"version":1,"type":"nav_command","stamp":1710000000.14,
 "vx":0.4,"vy":0.0,"vyaw":0.1,
 "enable":true,"emergency_stop":false}
```

`stamp` is a Unix timestamp for logging only. Freshness is determined by local
receipt time. The motion host must validate finite values, clamp commands to
the validated envelope, and enter a safe zero-command state if the TCP link or
command stream is silent. The ROS1 client reconnects every second after a
disconnect. The default endpoint is `192.168.2.1:29001`; override it with
`motion_host:=... motion_port:=...`.

### Motion host and policy contract

1. Run the TCP server on `motion_host:motion_port` and send `motion_state`
   frames at a stable rate (target 50-200 Hz). `projected_gravity` must be in
   the body frame. `last_nav_command` must be the command actually applied
   after the trained `alpha=0.5` filter and Lite3 limits; this is the previous
   command used in the next policy observation.
2. Receive `nav_command` frames and use their physical units as the locomotion
   policy command. Keep the command bounded and implement a timeout that zeros
   the command or enters the robot's safe state when messages stop. Treat
   `enable=false` as a zero target velocity and `emergency_stop=true` as an
   immediate safe-state request in Navigation mode. RL mode accepts joystick
   velocity only and ignores TCP commands. Publish `enabled=true` only in
   Navigation; publish `standing=true` in RL or Navigation. Keep local mode,
   lie-down and damping buttons available in both modes.
3. Keep the low-level PD/Motion SDK path unchanged until the navigation command
   path has been tested with the robot suspended. If a ROS-owned locomotion
   controller is chosen later, it may instead subscribe to `JointCommand`.
4. The SEA-Nav policy runner must consume `SeaNavObservation.observation` with
   shape `[1, 550]`, run deterministic inference (`act_inference` equivalent),
   including the trained CBF safety layer, and publish the three resulting
   values as `NavCommand`. Do not apply `log2` a second time and do not treat
   these values as normalized `[-1, 1]` actions.
5. Run the navigation observation and action loop at 50 Hz to match the Lite3
   training period (`sim.dt=0.005`, locomotion decimation `4`, effective
   policy period `0.02 s`). If the policy runs at another rate, make that delay
   part of a deliberate retraining or validation decision.

The repository's `Lite3_deploy` implements the TCP server, command timeout,
physical velocity input and applied-command feedback. The perception-side
`sea_nav_policy_ros1.py` implements ONNX Runtime CPU inference and the ROS command
publisher. Body-frame linear and angular velocity comes from `/pose_odom`.
The deployed locomotion ONNX model must match the one used for navigation
training, including joint order, observation order, action scale, default pose
and PD gains.

Run only the interface node for wiring tests:

```bash
rosrun seanav_deploy_ros1 sea_nav_interface_ros1.py
rostopic echo /sea_nav/observation
```

The node waits for a fresh TCP `motion_state`, `/rays`, `/pose`, and
`/pose_odom`; missing or stale input does not produce a valid observation. It
never starts `rl_deploy` or sends motor commands directly. It only forwards
the policy's `NavCommand` over TCP.
