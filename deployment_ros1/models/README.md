# Navigation ONNX artifact

`model_2000.onnx` was exported from
`training/legged_gym/logs/Lite3_pos_rough/10_13_19-18-35_/model_2000.pt`
with ELU activation, FP32, opset 17. It includes the complete deterministic
SEA-Nav actor and CBF, with input `observation [1,550]` and output
`nav_command [1,3]` (`vx, vy, vyaw`) in m/s, m/s, rad/s before deployment
clamp/filter. A Lite3 checkpoint whose play actor has two outputs (`vx, vyaw`)
is exported with a zero `vy` inserted between them.

128 generated validation samples passed PyTorch/ONNX comparison
(`rtol=1e-4, atol=1e-5`, max absolute error `7.75e-6`). These are numerical
conversion checks. They do not validate navigation performance on a robot.
The checkpoint's existing CBF ray direction buffer is preserved, including
the training angle discrepancy described in the workspace README.

Export your chosen checkpoint with training `play.py --export_onnx` as
described in [the workspace README](../README.md). Retraining requires a new export.
