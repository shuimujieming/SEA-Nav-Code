"""Export a loaded SEA-Nav actor without requiring ROS or Isaac Gym."""

import copy
import os
from pathlib import Path
import tempfile

import numpy as np
import torch


class SeaNavOnnxActor(torch.nn.Module):
    """Copy inference modules only; the live policy may hold non-leaf caches."""

    def __init__(self, actor_critic):
        super().__init__()
        for name in ("encoder", "backbone", "nav_head", "alpha_head", "cbf_layer"):
            setattr(self, name, copy.deepcopy(getattr(actor_critic, name)))
        self.num_obs_one_step = actor_critic.num_obs_one_step
        self.num_props = actor_critic.num_props
        self.num_rays = actor_critic.num_rays
        self.num_actions = actor_critic.num_actions
        if self.num_actions not in (2, 3):
            raise ValueError("SEA-Nav export supports only 2-D or 3-D navigation actions")

    def forward(self, observation):
        latest = observation[:, -self.num_obs_one_step:]
        rays = latest[:, self.num_props:self.num_props + self.num_rays]
        latent = self.encoder(observation)
        features = self.backbone(torch.cat((latest, latent), dim=-1))
        nominal = self.nav_head(features)
        alpha = torch.nn.functional.softplus(self.alpha_head(features))
        safe = self.cbf_layer(nominal, torch.exp2(rays), alpha)
        if self.num_actions == 2:
            # Lite3 predicts [vx, vyaw], while the deployment command contract
            # remains [vx, vy, vyaw]. Keep the lateral command explicitly zero.
            zero_vy = torch.zeros_like(safe[:, :1])
            safe = torch.cat((safe[:, :1], zero_vy, safe[:, 1:]), dim=-1)
        return safe


def export_policy_as_onnx(actor_critic, output_path, checkpoint_path=None, samples=128):
    """Export FP32 batch-one inference, validate it, then publish the ONNX file.

    Uses a CPU copy so play's policy device, mode and inference caches are preserved.
    ONNX and ONNX Runtime are needed only when this function is called.
    """
    import onnx
    import onnxruntime as ort

    if samples < 6:
        raise ValueError("validation requires at least 6 samples")
    actor = SeaNavOnnxActor(actor_critic).cpu().float().eval()
    rng = np.random.default_rng(1)
    observations = rng.uniform(-1, 1, (samples, actor_critic.his_len,
                                      actor.num_obs_one_step)).astype(np.float32)
    observations[:, :, :3] = [0, 0, -1]
    rays = observations[:, :, actor.num_props:actor.num_props + actor.num_rays]
    rays[:] = np.log2(rng.uniform(0.1, 3, rays.shape))
    observations[:, :, -2:] *= 5
    for i, distance in enumerate((0.1, 0.19, 0.2, 0.21, 0.5, 3.0)):
        rays[i] = np.log2(distance)
    observations = observations.reshape(samples, actor_critic.num_obs_hist)

    output = Path(output_path).expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(dir=str(output.parent)) as temporary:
        candidate = str(Path(temporary) / "policy.onnx")

        # PyTorch 2.4's legacy exporter lacks exp2; ONNX Pow(2, x) is equivalent.
        def exp2_symbolic(graph, value):
            two = graph.op("Constant", value_t=torch.tensor(2.0, dtype=torch.float32))
            return graph.op("Pow", two, value)

        torch.onnx.register_custom_op_symbolic("aten::exp2", exp2_symbolic, 17)
        try:
            with torch.inference_mode():
                torch.onnx.export(
                    actor, torch.from_numpy(observations[:1]), candidate,
                    input_names=["observation"], output_names=["nav_command"],
                    opset_version=17, do_constant_folding=True)
        finally:
            torch.onnx.unregister_custom_op_symbolic("aten::exp2", 17)

        graph = onnx.load(candidate)
        onnx.helper.set_model_props(graph, {
            "seanav.model": "SEA-Nav actor with ExactLSECBFLayer",
            "seanav.input": "%d oldest-to-newest steps: props%d, log2(rays%d), goal2" %
                            (actor_critic.his_len, actor.num_props, actor.num_rays),
            "seanav.output": "vx,vy,vyaw before external clamp/filter",
            "seanav.checkpoint": Path(checkpoint_path).name if checkpoint_path else "",
        })
        onnx.checker.check_model(graph)
        onnx.save(graph, candidate)
        options = ort.SessionOptions()
        options.intra_op_num_threads = 1
        options.inter_op_num_threads = 1
        runtime = ort.InferenceSession(candidate, sess_options=options,
                                       providers=["CPUExecutionProvider"])
        exported_actions = 3 if actor_critic.num_actions == 2 else actor_critic.num_actions
        if (runtime.get_inputs()[0].shape != [1, actor_critic.num_obs_hist] or
                runtime.get_outputs()[0].shape != [1, exported_actions]):
            raise ValueError("Exported ONNX input/output shape does not match the policy")
        max_error = 0.0
        with torch.inference_mode():
            for observation in observations:
                batch = observation[None]
                expected = actor(torch.from_numpy(batch)).numpy()
                actual = runtime.run(["nav_command"], {"observation": batch})[0]
                if not np.isfinite(actual).all() or not np.isfinite(expected).all():
                    raise ValueError("Policy produced a non-finite velocity during validation")
                np.testing.assert_allclose(actual, expected, rtol=1e-4, atol=1e-5)
                max_error = max(max_error, float(np.max(np.abs(actual - expected))))
        # Keep any previous export intact if validation fails.
        os.replace(candidate, output)
    return {"path": str(output), "samples": samples, "max_abs_error": max_error}
