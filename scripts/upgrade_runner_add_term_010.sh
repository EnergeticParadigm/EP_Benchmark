#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

RUNNER="/Users/wesleyshu/ep_benchmark_v1/runner/runner.py"

/bin/cat > "$RUNNER" <<'EOT'
#!/usr/bin/env python3
import json
import subprocess
import time
from pathlib import Path
from typing import Any, Dict, List

BASE = Path("/Users/wesleyshu/ep_benchmark_v1")
TASKS_DIR = BASE / "tasks"
RESULTS_RAW_DIR = BASE / "results" / "raw"

def load_task_specs() -> List[Dict[str, Any]]:
    specs: List[Dict[str, Any]] = []
    for path in sorted(TASKS_DIR.rglob("task.json")):
        specs.append(json.loads(path.read_text(encoding="utf-8")))
    return specs

def make_placeholder_trace(task: Dict[str, Any], mode: str) -> Dict[str, Any]:
    return {
        "task_id": task["task_id"],
        "task_group": task["task_group"],
        "mode": mode,
        "model_name": "UNSET_MODEL",
        "success": False,
        "final_output": "",
        "step_count": 0,
        "tool_call_count": 0,
        "invalid_tool_call_count": 0,
        "token_count": 0,
        "runtime_seconds": 0.0,
        "checkpoint_count": 0,
        "rollback_count": 0,
        "route_change_count": 0,
        "failure_class": "incomplete_execution",
        "notes": "Placeholder trace. Real execution harness not connected yet."
    }

def run_term_001(task: Dict[str, Any], mode: str) -> Dict[str, Any]:
    task_base = BASE / "tasks" / "terminal" / "TERM_001"
    env_dir = task_base / "env"
    candidate_path = task_base / f"runtime_candidate__{mode}.json"
    evaluator = task_base / "evaluator" / "evaluate.py"

    start = time.time()
    grep_proc = subprocess.run(
        ["/usr/bin/grep", "-R", "-n", "ERROR 502", str(env_dir)],
        capture_output=True,
        text=True,
        check=False
    )
    runtime_seconds = round(time.time() - start, 4)

    matching_lines = [line for line in grep_proc.stdout.splitlines() if "req-77A9" in line]

    if len(matching_lines) != 1:
        return {
            "task_id": task["task_id"],
            "task_group": task["task_group"],
            "mode": mode,
            "model_name": "TERM_001_REAL_EXECUTION",
            "success": False,
            "final_output": "",
            "step_count": 1,
            "tool_call_count": 1,
            "invalid_tool_call_count": 0,
            "token_count": 0,
            "runtime_seconds": runtime_seconds,
            "checkpoint_count": 0,
            "rollback_count": 0,
            "route_change_count": 0,
            "failure_class": "final_answer_wrong",
            "notes": f"Expected exactly one matching line, found {len(matching_lines)}."
        }

    matched = matching_lines[0]
    prefix = str(env_dir) + "/"
    remainder = matched[len(prefix):]
    first_colon = remainder.find(":")
    second_colon = remainder.find(":", first_colon + 1)

    relative_path = remainder[:first_colon]
    line_number = int(remainder[first_colon + 1:second_colon])
    exact_line = remainder[second_colon + 1:]

    candidate = {
        "relative_path": relative_path,
        "line_number": line_number,
        "exact_line": exact_line
    }
    candidate_path.write_text(json.dumps(candidate, indent=2, ensure_ascii=False), encoding="utf-8")

    eval_proc = subprocess.run(
        ["/usr/bin/python3", str(evaluator), str(candidate_path)],
        capture_output=True,
        text=True,
        check=False
    )
    eval_result = json.loads(eval_proc.stdout)

    return {
        "task_id": task["task_id"],
        "task_group": task["task_group"],
        "mode": mode,
        "model_name": "TERM_001_REAL_EXECUTION",
        "success": bool(eval_result["success"]),
        "final_output": json.dumps(candidate, ensure_ascii=False),
        "step_count": 2,
        "tool_call_count": 2,
        "invalid_tool_call_count": 0,
        "token_count": 0,
        "runtime_seconds": runtime_seconds,
        "checkpoint_count": 0,
        "rollback_count": 0,
        "route_change_count": 0,
        "failure_class": None if eval_result["success"] else "final_answer_wrong",
        "notes": "TERM_001 executed by real grep search over env and then evaluated automatically."
    }

def run_term_010(task: Dict[str, Any], mode: str) -> Dict[str, Any]:
    task_base = BASE / "tasks" / "terminal" / "TERM_010"
    log_path = task_base / "env" / "logs" / "tests" / "test_run.log"
    candidate_path = task_base / f"runtime_candidate__{mode}.json"
    evaluator = task_base / "evaluator" / "evaluate.py"

    start = time.time()
    lines = log_path.read_text(encoding="utf-8").splitlines()

    failing_test_name = None
    error_type = None
    first_stacktrace_file_path = None

    for line in lines:
        if line.startswith("FAILED ") and " - " in line:
            failing_test_name = line.split("FAILED ", 1)[1].split(" - ", 1)[0].strip()
            error_type = line.split(" - ", 1)[1].strip()
            break

    for line in lines:
        stripped = line.strip()
        if stripped.startswith("app/") and ":" in stripped:
            first_stacktrace_file_path = stripped
            break

    runtime_seconds = round(time.time() - start, 4)

    candidate = {
        "failing_test_name": failing_test_name,
        "error_type": error_type,
        "first_stacktrace_file_path": first_stacktrace_file_path
    }
    candidate_path.write_text(json.dumps(candidate, indent=2, ensure_ascii=False), encoding="utf-8")

    eval_proc = subprocess.run(
        ["/usr/bin/python3", str(evaluator), str(candidate_path)],
        capture_output=True,
        text=True,
        check=False
    )
    eval_result = json.loads(eval_proc.stdout)

    return {
        "task_id": task["task_id"],
        "task_group": task["task_group"],
        "mode": mode,
        "model_name": "TERM_010_REAL_EXECUTION",
        "success": bool(eval_result["success"]),
        "final_output": json.dumps(candidate, ensure_ascii=False),
        "step_count": 2,
        "tool_call_count": 2,
        "invalid_tool_call_count": 0,
        "token_count": 0,
        "runtime_seconds": runtime_seconds,
        "checkpoint_count": 0,
        "rollback_count": 0,
        "route_change_count": 0,
        "failure_class": None if eval_result["success"] else "final_answer_wrong",
        "notes": "TERM_010 executed by real log parsing and then evaluated automatically."
    }

def main() -> None:
    modes = ["baseline", "baseline_scaffold", "ep"]
    specs = load_task_specs()
    RESULTS_RAW_DIR.mkdir(parents=True, exist_ok=True)

    for task in specs:
        for mode in modes:
            if task["task_id"] == "TERM_001":
                trace = run_term_001(task, mode)
            elif task["task_id"] == "TERM_010":
                trace = run_term_010(task, mode)
            else:
                trace = make_placeholder_trace(task, mode)

            out = RESULTS_RAW_DIR / f'{task["task_id"]}__{mode}.json'
            out.write_text(json.dumps(trace, indent=2, ensure_ascii=False), encoding="utf-8")

    print(f"Generated traces in {RESULTS_RAW_DIR}")

if __name__ == "__main__":
    main()
EOT

/bin/chmod +x "$RUNNER"
/usr/bin/python3 /Users/wesleyshu/ep_benchmark_v1/runner/runner.py
/usr/bin/python3 /Users/wesleyshu/ep_benchmark_v1/scorer/score.py
/bin/echo "DONE: TERM_010 added to real execution"
