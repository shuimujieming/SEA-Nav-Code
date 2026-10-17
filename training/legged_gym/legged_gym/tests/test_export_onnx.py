"""ONNX export/runtime regression checks, without ROS or robot access."""

from pathlib import Path
import importlib.util
import subprocess
import sys
import tempfile
import unittest

import numpy as np
import onnx
import torch

ROOT = Path(__file__).resolve().parents[4]
SCRIPTS = ROOT / "deployment_ros1/src/seanav_deploy_ros1/scripts"
sys.path.insert(0, str(SCRIPTS))
sys.path.insert(0, str(ROOT / "training/rsl_rl"))
from sea_nav_inference import OnnxPolicy, sample_observations
from rsl_rl.modules.cbf_actor_critic import DifferentiableSafeActorCritic

spec = importlib.util.spec_from_file_location(
    "training_export_onnx", str(ROOT / "training/legged_gym/legged_gym/utils/export_onnx.py"))
training_export = importlib.util.module_from_spec(spec)
spec.loader.exec_module(training_export)


class InferenceTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        torch.set_num_threads(1)

    def test_play_export_preserves_live_policy(self):
        torch.manual_seed(4)
        model = DifferentiableSafeActorCritic(
            num_actions=3, actor_hidden_dims=[64, 32], critic_hidden_dims=[48, 24],
            encoder_hidden_dims=[80, 40], activation="relu").train()
        model.encoder.eval()
        observations = torch.from_numpy(sample_observations(16, seed=5))
        # Forward with gradients leaves non-leaf caches on the live actor.
        expected = model.act_inference(observations).detach().numpy()
        cached_output = model.u_s
        modes = {name: module.training for name, module in model.named_modules()}
        devices = {name: param.device for name, param in model.named_parameters()}
        weights = {name: value.clone() for name, value in model.state_dict().items()}
        with tempfile.TemporaryDirectory() as directory:
            output = str(Path(directory) / "model.onnx")
            training_export.export_policy_as_onnx(model, output, samples=16)
            runtime = OnnxPolicy(output)
            actual = np.concatenate([runtime.infer(row) for row in observations.numpy()])
            np.testing.assert_allclose(actual, expected, rtol=1e-4, atol=1e-5)
        self.assertIs(model.u_s, cached_output)
        self.assertEqual(modes, {name: module.training for name, module in model.named_modules()})
        self.assertEqual(devices, {name: param.device for name, param in model.named_parameters()})
        for name, value in model.state_dict().items():
            self.assertTrue(torch.equal(value, weights[name]), name)

    def test_full_cbf_actor_and_torch_free_runtime(self):
        torch.manual_seed(2)
        model = DifferentiableSafeActorCritic(
            num_actions=3, actor_hidden_dims=[64, 32], critic_hidden_dims=[48, 24],
            encoder_hidden_dims=[80, 40], activation="elu").eval()
        # A non-default direction buffer must survive checkpoint export.
        angles = torch.linspace(-2 * np.pi / 3, 2 * np.pi / 3, 41)
        model.cbf_layer.ray_unit_vectors[:] = torch.stack((angles.cos(), angles.sin()), dim=1)
        with torch.no_grad():
            model.nav_head[-1].bias[:] = torch.tensor([1, .4, .2])
            model.alpha_head[-1].bias[:] = -4
        with tempfile.TemporaryDirectory() as directory:
            output = str(Path(directory) / "policy.onnx")
            result = training_export.export_policy_as_onnx(model, output, samples=32)
            self.assertLess(result["max_abs_error"], 1e-4)
            runtime = OnnxPolicy(output)
            observations = sample_observations(32, seed=42)
            with torch.inference_mode():
                expected = model.act_inference(torch.from_numpy(observations)).numpy()
                nominal = model.u_bar.numpy().copy()
            actual = np.concatenate([runtime.infer(row.tolist()) for row in observations])
            np.testing.assert_allclose(actual, expected, rtol=1e-4, atol=1e-5)
            # This must actually exercise CBF corrections, not just the raw actor.
            self.assertGreater(float(np.max(np.abs(actual - nominal))), 1e-3)
            subprocess.run([
                sys.executable, "-c",
                "import sys; sys.modules['torch'] = None; "
                "sys.path.insert(0, sys.argv[1]); "
                "from sea_nav_inference import OnnxPolicy; "
                "assert OnnxPolicy(sys.argv[2]).infer([0.0]*550).shape == (1,3)",
                str(SCRIPTS), output], check=True)

    def test_reject_locomotion_model_shape(self):
        with tempfile.TemporaryDirectory() as directory:
            path = str(Path(directory) / "locomotion.onnx")
            graph = onnx.helper.make_graph(
                [onnx.helper.make_node("Identity", ["obs"], ["actions"])], "wrong-policy",
                [onnx.helper.make_tensor_value_info("obs", onnx.TensorProto.FLOAT, [1, 45])],
                [onnx.helper.make_tensor_value_info("actions", onnx.TensorProto.FLOAT, [1, 45])])
            model = onnx.helper.make_model(graph, opset_imports=[onnx.helper.make_opsetid("", 17)])
            model.ir_version = 8
            onnx.save(model, path)
            with self.assertRaisesRegex(ValueError, "SEA-Nav ONNX"):
                OnnxPolicy(path)


if __name__ == "__main__":
    unittest.main()
