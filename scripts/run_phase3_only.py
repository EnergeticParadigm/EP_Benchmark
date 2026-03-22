#!/usr/bin/env python3
import json
import importlib.util
from pathlib import Path

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
RUNNER_PATH = ROOT / "runner" / "runner.py"
RESULTS_RAW_DIR = ROOT / "results" / "raw"
RESULTS_RAW_DIR.mkdir(parents=True, exist_ok=True)

spec = importlib.util.spec_from_file_location("ep_runner_phase3", RUNNER_PATH)
runner = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(runner)

phase3_tasks = [
    {"task_id": "TOOL_AMBIG_001", "task_group": "tool_routing"},
    {"task_id": "TERM_AMBIG_001", "task_group": "terminal"},
    {"task_id": "SWE_AMBIG_001", "task_group": "swe"},
]

dispatch = {
    "TOOL_AMBIG_001": runner.run_tool_ambig_001,
    "TERM_AMBIG_001": runner.run_term_ambig_001,
    "SWE_AMBIG_001": runner.run_swe_ambig_001,
}

modes = ["baseline", "baseline_scaffold", "ep"]

written = []
for task in phase3_tasks:
    fn = dispatch[task["task_id"]]
    for mode in modes:
        trace = fn(task, mode)
        out = RESULTS_RAW_DIR / f'{task["task_id"]}__{mode}.json'
        out.write_text(json.dumps(trace, indent=2, ensure_ascii=False), encoding="utf-8")
        written.append(str(out))

print("WROTE:")
for path in written:
    print(path)
