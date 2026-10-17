"""SEA-Nav ONNX Runtime CPU inference, independent of ROS and training code."""

import math
import os
import time

import numpy as np



class OnnxPolicy:
    def __init__(self, model_path, threads=1):
        model_path = os.fspath(model_path)
        if not model_path.lower().endswith(".onnx"):
            raise ValueError("model_path must be a .onnx navigation policy exported by play.py")
        import onnxruntime as ort
        if threads < 1:
            raise ValueError("onnx_threads must be positive")
        if not os.path.isfile(model_path):
            raise ValueError("model_path does not exist: " + model_path)
        options = ort.SessionOptions()
        options.intra_op_num_threads = threads
        options.inter_op_num_threads = 1
        options.execution_mode = ort.ExecutionMode.ORT_SEQUENTIAL
        options.graph_optimization_level = ort.GraphOptimizationLevel.ORT_ENABLE_ALL
        # Leave CPU time available for A-LOAM between 50 Hz policy steps.
        options.add_session_config_entry("session.intra_op.allow_spinning", "0")
        options.add_session_config_entry("session.inter_op.allow_spinning", "0")
        self.session = ort.InferenceSession(model_path, sess_options=options,
                                            providers=["CPUExecutionProvider"])
        inputs, outputs = self.session.get_inputs(), self.session.get_outputs()
        if (len(inputs) != 1 or inputs[0].shape != [1, 550] or
                inputs[0].type != "tensor(float)" or len(outputs) != 1 or
                outputs[0].shape != [1, 3] or outputs[0].type != "tensor(float)"):
            raise ValueError("Expected FP32 SEA-Nav ONNX input [1,550], output [1,3]; "
                             "export with training play.py --export_onnx")
        self.input_name, self.output_name = inputs[0].name, outputs[0].name
        self.description = "ONNX Runtime CPUExecutionProvider, threads=" + str(threads)
        sample = np.zeros((10, 55), dtype=np.float32)
        sample[:, 12:53] = math.log2(3.0)
        for _ in range(10):
            result = self.infer(sample.ravel())
            if result.shape != (1, 3) or not np.isfinite(result).all():
                raise ValueError("ONNX warmup produced invalid velocity")

    def infer(self, observation):
        inputs = np.asarray(observation, dtype=np.float32).reshape(1, 550)
        return self.session.run([self.output_name], {self.input_name: inputs})[0]


def sample_observations(count=128, seed=1):
    """Deterministic validation cases spanning clear space and close obstacles."""
    rng = np.random.default_rng(seed)
    samples = rng.uniform(-1, 1, (count, 10, 55)).astype(np.float32)
    samples[:, :, :3] = [0, 0, -1]
    samples[:, :, 12:53] = np.log2(rng.uniform(0.1, 3, (count, 10, 41)))
    samples[:, :, -2:] *= 5
    # Near obstacles and uniformly open space exercise the CBF at its extremes.
    for i, distance in enumerate((0.1, 0.19, 0.2, 0.21, 0.5, 3.0)):
        if i < count:
            samples[i, :, 12:53] = math.log2(distance)
    return samples.reshape(count, 550)


def benchmark(runtime, observations, iterations=500):
    if iterations < 1:
        raise ValueError("benchmark iterations must be positive")
    # Match ROS's Python list -> FP32 tensor input conversion.
    inputs = [row.tolist() for row in observations]
    for index in range(30):
        runtime.infer(inputs[index % len(inputs)])
    elapsed = []
    for index in range(iterations):
        started = time.perf_counter()
        runtime.infer(inputs[index % len(inputs)])
        elapsed.append((time.perf_counter() - started) * 1000)
    return dict(zip(("p50_ms", "p95_ms", "p99_ms", "max_ms"),
                    [float(value) for value in np.percentile(elapsed, [50, 95, 99, 100])]))


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="CPU ONNX latency benchmark; no ROS required")
    parser.add_argument("--model", required=True)
    parser.add_argument("--threads", type=int, nargs="+", default=[1, 2, 4])
    parser.add_argument("--iterations", type=int, default=1000)
    args = parser.parse_args()
    for threads in args.threads:
        runtime = OnnxPolicy(args.model, threads)
        print(runtime.description, benchmark(runtime, sample_observations(16), args.iterations))
