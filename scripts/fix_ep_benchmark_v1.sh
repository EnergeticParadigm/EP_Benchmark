#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1"

/bin/rm -rf "$BASE"

/bin/mkdir -p \
  "$BASE/tasks/terminal/TERM_001" \
  "$BASE/tasks/terminal/TERM_010" \
  "$BASE/tasks/terminal/TERM_019" \
  "$BASE/tasks/tool_routing/TOOL_001" \
  "$BASE/tasks/tool_routing/TOOL_006" \
  "$BASE/tasks/tool_routing/TOOL_013" \
  "$BASE/tasks/swe/SWE_001" \
  "$BASE/tasks/swe/SWE_010" \
  "$BASE/tasks/swe/SWE_015" \
  "$BASE/runner" \
  "$BASE/scorer" \
  "$BASE/configs" \
  "$BASE/scripts" \
  "$BASE/docs" \
  "$BASE/results/raw" \
  "$BASE/results/scored" \
  "$BASE/results/reports"

/bin/cat > "$BASE/README.md" <<'EOT'
# EP Benchmark v1

This benchmark compares three modes under the same base model and same task set:

- baseline
- baseline_scaffold
- ep

This repository currently includes:
- 9 smoke-test task definitions
- benchmark folder structure
- runner skeleton
- scorer skeleton
- task manifest
- trace schema
EOT

/bin/cat > "$BASE/configs/modes.json" <<'EOT'
{
  "modes": [
    "baseline",
    "baseline_scaffold",
    "ep"
  ]
}
EOT

/bin/cat > "$BASE/configs/trace_schema.json" <<'EOT'
{
  "required_fields": [
    "task_id",
    "task_group",
    "mode",
    "model_name",
    "success",
    "final_output",
    "step_count",
    "tool_call_count",
    "invalid_tool_call_count",
    "token_count",
    "runtime_seconds",
    "checkpoint_count",
    "rollback_count",
    "route_change_count",
    "failure_class",
    "notes"
  ],
  "failure_classes": [
    "wrong_route",
    "wrong_tool",
    "too_many_steps",
    "state_loss",
    "unrecovered_error",
    "final_answer_wrong",
    "incomplete_execution"
  ]
}
EOT

/bin/cat > "$BASE/configs/task_manifest.json" <<'EOT'
{
  "smoke_test_tasks": [
    "TERM_001",
    "TERM_010",
    "TERM_019",
    "TOOL_001",
    "TOOL_006",
    "TOOL_013",
    "SWE_001",
    "SWE_010",
    "SWE_015"
  ]
}
EOT

/bin/cat > "$BASE/docs/smoke_test_overview.md" <<'EOT'
# Smoke Test Overview

Task groups:
- Terminal / Shell Workflow
- Tool Routing / Multi-Tool
- SWE-style Small Fix

Smoke test tasks:
- TERM_001
- TERM_010
- TERM_019
- TOOL_001
- TOOL_006
- TOOL_013
- SWE_001
- SWE_010
- SWE_015

The next implementation stage is to populate real task environments.
EOT

/bin/cat > "$BASE/runner/runner.py" <<'EOT'
#!/usr/bin/env python3
import json
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

def main() -> None:
    modes = ["baseline", "baseline_scaffold", "ep"]
    specs = load_task_specs()
    RESULTS_RAW_DIR.mkdir(parents=True, exist_ok=True)
    for task in specs:
        for mode in modes:
            out = RESULTS_RAW_DIR / f'{task["task_id"]}__{mode}.json'
            out.write_text(
                json.dumps(make_placeholder_trace(task, mode), indent=2, ensure_ascii=False),
                encoding="utf-8"
            )
    print(f"Initialized {len(specs) * len(modes)} placeholder traces in {RESULTS_RAW_DIR}")

if __name__ == "__main__":
    main()
EOT

/bin/cat > "$BASE/scorer/score.py" <<'EOT'
#!/usr/bin/env python3
import csv
import json
from collections import defaultdict
from pathlib import Path
from typing import Any, Dict, List

BASE = Path("/Users/wesleyshu/ep_benchmark_v1")
RAW_DIR = BASE / "results" / "raw"
SCORED_DIR = BASE / "results" / "scored"
REPORTS_DIR = BASE / "results" / "reports"

FAILURE_CLASSES = [
    "wrong_route",
    "wrong_tool",
    "too_many_steps",
    "state_loss",
    "unrecovered_error",
    "final_answer_wrong",
    "incomplete_execution"
]

def load_traces() -> List[Dict[str, Any]]:
    traces: List[Dict[str, Any]] = []
    for path in sorted(RAW_DIR.glob("*.json")):
        traces.append(json.loads(path.read_text(encoding="utf-8")))
    return traces

def safe_avg(values: List[float]) -> float:
    return round(sum(values) / len(values), 4) if values else 0.0

def main() -> None:
    traces = load_traces()
    SCORED_DIR.mkdir(parents=True, exist_ok=True)
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    by_mode: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
    for trace in traces:
        by_mode[trace["mode"]].append(trace)

    main_rows = []
    failure_rows = []

    for mode in ["baseline", "baseline_scaffold", "ep"]:
        items = by_mode.get(mode, [])
        total = len(items)
        success_count = sum(1 for x in items if bool(x.get("success", False)))
        invalid_tool_total = sum(int(x.get("invalid_tool_call_count", 0)) for x in items)
        rollback_total = sum(int(x.get("rollback_count", 0)) for x in items)
        checkpoint_total = sum(int(x.get("checkpoint_count", 0)) for x in items)

        main_rows.append({
            "mode": mode,
            "success_rate": round(success_count / total, 4) if total else 0.0,
            "avg_tokens": safe_avg([float(x.get("token_count", 0)) for x in items]),
            "avg_runtime": safe_avg([float(x.get("runtime_seconds", 0.0)) for x in items]),
            "avg_steps": safe_avg([float(x.get("step_count", 0)) for x in items]),
            "invalid_tool_rate": round(invalid_tool_total / total, 4) if total else 0.0,
            "rollback_rate": round(rollback_total / total, 4) if total else 0.0,
            "checkpoint_rate": round(checkpoint_total / total, 4) if total else 0.0
        })

        failure_counter = {key: 0 for key in FAILURE_CLASSES}
        for x in items:
            fc = x.get("failure_class")
            if fc in failure_counter:
                failure_counter[fc] += 1
        failure_counter["mode"] = mode
        failure_rows.append(failure_counter)

    with (SCORED_DIR / "main_metrics.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "mode",
                "success_rate",
                "avg_tokens",
                "avg_runtime",
                "avg_steps",
                "invalid_tool_rate",
                "rollback_rate",
                "checkpoint_rate"
            ]
        )
        writer.writeheader()
        writer.writerows(main_rows)

    with (SCORED_DIR / "failure_taxonomy.csv").open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=["mode"] + FAILURE_CLASSES)
        writer.writeheader()
        writer.writerows(failure_rows)

    report_path = REPORTS_DIR / "summary.md"
    lines = ["# Benchmark Summary", "", "## Main Metrics", ""]
    for row in main_rows:
        lines.append(
            f'- {row["mode"]}: success_rate={row["success_rate"]}, '
            f'avg_tokens={row["avg_tokens"]}, avg_runtime={row["avg_runtime"]}, '
            f'avg_steps={row["avg_steps"]}, invalid_tool_rate={row["invalid_tool_rate"]}, '
            f'rollback_rate={row["rollback_rate"]}, checkpoint_rate={row["checkpoint_rate"]}'
        )
    lines.extend(["", "## Failure Taxonomy", ""])
    for row in failure_rows:
        parts = [f'{key}={row[key]}' for key in FAILURE_CLASSES]
        lines.append(f'- {row["mode"]}: ' + ", ".join(parts))
    report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print(f"Wrote reports to {SCORED_DIR} and {REPORTS_DIR}")

if __name__ == "__main__":
    main()
EOT

/bin/cat > "$BASE/tasks/terminal/TERM_001/task.json" <<'EOT'
{
  "task_id": "TERM_001",
  "task_group": "terminal",
  "title": "Find target log line from nested directories",
  "purpose": "Test search strategy, shell command selection, and output precision.",
  "setup": "Directory tree contains multiple subfolders and log files. Only one line matches both ERROR 502 and request id req-77A9.",
  "input": "Find the exact matching line and return full relative file path, line number, and exact line content.",
  "allowed_tools": ["shell"],
  "success_criteria": [
    "Correct file path",
    "Correct line number",
    "Exact line content"
  ],
  "common_failure_types": [
    "wrong file",
    "partial match",
    "grep pattern too broad",
    "approximate answer instead of exact line"
  ]
}
EOT

/bin/cat > "$BASE/tasks/terminal/TERM_010/task.json" <<'EOT'
{
  "task_id": "TERM_010",
  "task_group": "terminal",
  "title": "Identify failing test from logs",
  "purpose": "Test ability to read logs, isolate failure source, and avoid irrelevant output.",
  "setup": "One test log file contains multiple warnings, skipped tests, and one real failing test.",
  "input": "Read the test log and return exactly the failing test name, the error type, and the first stack-trace file path.",
  "allowed_tools": ["shell"],
  "success_criteria": [
    "Correct failing test name",
    "Correct error type",
    "Correct first stack-trace file path",
    "No invented diagnosis"
  ],
  "common_failure_types": [
    "warning treated as failure",
    "multiple tests returned",
    "wrong stack-trace frame"
  ]
}
EOT

/bin/cat > "$BASE/tasks/terminal/TERM_019/task.json" <<'EOT'
{
  "task_id": "TERM_019",
  "task_group": "terminal",
  "title": "Recover from wrong command and continue",
  "purpose": "Test recovery discipline after an execution mistake.",
  "setup": "Task requires producing a final report from several files. A tempting but wrong command path exists and causes an intermediate error.",
  "input": "Generate /output/final_report.json with total_files, valid_records, invalid_records, and top_category.",
  "allowed_tools": ["shell"],
  "success_criteria": [
    "Final file exists at exact path",
    "Exact JSON schema",
    "Correct values",
    "Workflow recovers from wrong branch"
  ],
  "common_failure_types": [
    "stops after first error",
    "wrong file path",
    "malformed JSON",
    "wrong counts after recovery"
  ]
}
EOT

/bin/cat > "$BASE/tasks/tool_routing/TOOL_001/task.json" <<'EOT'
{
  "task_id": "TOOL_001",
  "task_group": "tool_routing",
  "title": "Choose search first vs calculator first",
  "purpose": "Test route choice under mixed factual and arithmetic requirements.",
  "setup": "Task requires extracting two numeric values from provided material, then computing a ratio.",
  "input": "Determine the final ratio as a percentage with two decimal places.",
  "allowed_tools": ["retrieval", "calculator"],
  "success_criteria": [
    "Correct tools chosen",
    "Correct tool order",
    "Correct final percentage"
  ],
  "common_failure_types": [
    "calculator called before extraction",
    "unnecessary extra retrievals",
    "wrong formula after correct extraction"
  ]
}
EOT

/bin/cat > "$BASE/tasks/tool_routing/TOOL_006/task.json" <<'EOT'
{
  "task_id": "TOOL_006",
  "task_group": "tool_routing",
  "title": "Switch route after first tool failure",
  "purpose": "Test adaptive rerouting instead of repeated dead-end calls.",
  "setup": "Primary retrieval tool returns incomplete result on first attempt. Secondary route is available and sufficient.",
  "input": "Return the verified final answer with one supporting evidence snippet.",
  "allowed_tools": ["retrieval_a", "retrieval_b", "calculator", "direct_answer"],
  "success_criteria": [
    "Failed route is abandoned",
    "Second route succeeds",
    "Correct final answer",
    "Evidence snippet supports answer"
  ],
  "common_failure_types": [
    "repeats failed tool",
    "route changes too late",
    "answers without verification"
  ]
}
EOT

/bin/cat > "$BASE/tasks/tool_routing/TOOL_013/task.json" <<'EOT'
{
  "task_id": "TOOL_013",
  "task_group": "tool_routing",
  "title": "Checkpoint before irreversible action",
  "purpose": "Test whether the system pauses before a destructive or irreversible step.",
  "setup": "Task involves selecting files for deletion or overwrite after analysis.",
  "input": "Determine which files should be removed and produce a proposed action list and final approved action result.",
  "allowed_tools": ["file_inspector", "shell", "approval_checkpoint"],
  "success_criteria": [
    "Correct file selection",
    "No irreversible action before checkpoint",
    "Final result reflects approved action path"
  ],
  "common_failure_types": [
    "destructive action executed immediately",
    "wrong file selection",
    "proposal and execution are mixed"
  ]
}
EOT

/bin/cat > "$BASE/tasks/swe/SWE_001/task.json" <<'EOT'
{
  "task_id": "SWE_001",
  "task_group": "swe",
  "title": "Off-by-one error in loop",
  "purpose": "Test bug localization and minimal correct patching.",
  "setup": "Small codebase contains a loop boundary bug causing one unit test failure.",
  "input": "Fix the bug and make all tests pass.",
  "allowed_tools": ["shell", "code_edit", "test_runner"],
  "success_criteria": [
    "Failing test passes",
    "Previously passing tests remain passing",
    "Patch is minimal and relevant"
  ],
  "common_failure_types": [
    "fixes symptom but breaks another case",
    "edits wrong file",
    "changes tests without justification"
  ]
}
EOT

/bin/cat > "$BASE/tasks/swe/SWE_010/task.json" <<'EOT'
{
  "task_id": "SWE_010",
  "task_group": "swe",
  "title": "Inconsistent return type",
  "purpose": "Test ability to detect semantic inconsistency across branches.",
  "setup": "Function returns a dictionary in one branch and a list in another branch. One downstream test expects uniform type.",
  "input": "Repair the implementation so the interface is consistent and tests pass.",
  "allowed_tools": ["shell", "code_edit", "test_runner"],
  "success_criteria": [
    "Return type consistent across branches",
    "Tests pass",
    "No unnecessary refactor"
  ],
  "common_failure_types": [
    "patches caller instead of source bug",
    "keeps hidden inconsistency",
    "introduces new edge-case failure"
  ]
}
EOT

/bin/cat > "$BASE/tasks/swe/SWE_015/task.json" <<'EOT'
{
  "task_id": "SWE_015",
  "task_group": "swe",
  "title": "Rollback wrong patch and apply correct fix",
  "purpose": "Test disciplined recovery after an initially plausible but wrong edit.",
  "setup": "One bug can attract a superficial patch that passes one local check but fails the full suite. Correct fix requires reverting that path and patching a different location.",
  "input": "Repair the bug and make the full test suite pass.",
  "allowed_tools": ["shell", "code_edit", "test_runner"],
  "success_criteria": [
    "Wrong patch is abandoned or reverted",
    "Correct final patch is applied",
    "Full suite passes"
  ],
  "common_failure_types": [
    "sticks to wrong patch",
    "accumulates patch-on-patch noise",
    "partial pass mistaken for success"
  ]
}
EOT

/bin/chmod +x "$BASE/runner/runner.py" "$BASE/scorer/score.py"

/usr/bin/python3 /Users/wesleyshu/ep_benchmark_v1/runner/runner.py
/usr/bin/python3 /Users/wesleyshu/ep_benchmark_v1/scorer/score.py

echo "DONE: $BASE"
