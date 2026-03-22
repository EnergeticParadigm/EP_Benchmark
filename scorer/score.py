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
