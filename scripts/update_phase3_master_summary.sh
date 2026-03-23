#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
RESULTS_DIR="$BASE/results"
PHASE3_DIR="$RESULTS_DIR/phase3"
BATCH2_DIR="$RESULTS_DIR/phase3_batch2_real"

INPUT_SUMMARY="$BATCH2_DIR/phase3_batch2_real_summary.json"
MASTER_JSON="$PHASE3_DIR/phase3_master_summary.json"
MASTER_MD="$PHASE3_DIR/phase3_master_summary.md"

mkdir -p "$PHASE3_DIR"

if [ ! -f "$INPUT_SUMMARY" ]; then
  echo "MISSING_INPUT_SUMMARY=$INPUT_SUMMARY"
  exit 1
fi

/usr/bin/python3 - <<'PY'
import json
from pathlib import Path

base = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
results_dir = base / "results"
phase3_dir = results_dir / "phase3"
batch2_summary_path = results_dir / "phase3_batch2_real" / "phase3_batch2_real_summary.json"
master_json_path = phase3_dir / "phase3_master_summary.json"
master_md_path = phase3_dir / "phase3_master_summary.md"

phase3_dir.mkdir(parents=True, exist_ok=True)

batch2 = json.loads(batch2_summary_path.read_text(encoding="utf-8"))

if master_json_path.exists():
    master = json.loads(master_json_path.read_text(encoding="utf-8"))
else:
    master = {
        "phase": 3,
        "batches": {},
        "totals": {
            "task_count": 0,
            "pass_count": 0,
            "fail_count": 0,
            "partial_count": 0,
            "error_count": 0
        }
    }

master.setdefault("phase", 3)
master.setdefault("batches", {})
master.setdefault("totals", {
    "task_count": 0,
    "pass_count": 0,
    "fail_count": 0,
    "partial_count": 0,
    "error_count": 0
})

master["batches"]["phase3_batch2_real"] = {
    "summary_json": str(batch2_summary_path),
    "task_count": int(batch2.get("task_count", 0)),
    "pass_count": int(batch2.get("pass_count", 0)),
    "fail_count": int(batch2.get("fail_count", 0)),
    "partial_count": int(batch2.get("partial_count", 0)),
    "error_count": int(batch2.get("error_count", 0)),
    "tasks": batch2.get("tasks", [])
}

totals = {
    "task_count": 0,
    "pass_count": 0,
    "fail_count": 0,
    "partial_count": 0,
    "error_count": 0
}

for batch_name, batch_data in master["batches"].items():
    totals["task_count"] += int(batch_data.get("task_count", 0))
    totals["pass_count"] += int(batch_data.get("pass_count", 0))
    totals["fail_count"] += int(batch_data.get("fail_count", 0))
    totals["partial_count"] += int(batch_data.get("partial_count", 0))
    totals["error_count"] += int(batch_data.get("error_count", 0))

master["totals"] = totals

master_json_path.write_text(json.dumps(master, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

lines = []
lines.append("# Phase 3 Master Summary")
lines.append("")
lines.append(f"- Total task count: `{totals['task_count']}`")
lines.append(f"- Total pass count: `{totals['pass_count']}`")
lines.append(f"- Total fail count: `{totals['fail_count']}`")
lines.append(f"- Total partial count: `{totals['partial_count']}`")
lines.append(f"- Total error count: `{totals['error_count']}`")
lines.append("")
lines.append("## Batches")
lines.append("")

for batch_name in sorted(master["batches"].keys()):
    batch = master["batches"][batch_name]
    lines.append(f"### {batch_name}")
    lines.append("")
    lines.append(f"- Summary JSON: `{batch.get('summary_json', '')}`")
    lines.append(f"- Task count: `{batch.get('task_count', 0)}`")
    lines.append(f"- Pass count: `{batch.get('pass_count', 0)}`")
    lines.append(f"- Fail count: `{batch.get('fail_count', 0)}`")
    lines.append(f"- Partial count: `{batch.get('partial_count', 0)}`")
    lines.append(f"- Error count: `{batch.get('error_count', 0)}`")
    lines.append("")
    lines.append("#### Tasks")
    lines.append("")
    for task in batch.get("tasks", []):
        lines.append(
            f"- `{task.get('task_id', '')}` | track=`{task.get('track', '')}` | status=`{task.get('status', '')}` | final_score=`{task.get('final_score', '')}`"
        )
    lines.append("")

master_md_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

print(f"MASTER_JSON={master_json_path}")
print(f"MASTER_MD={master_md_path}")
print("UPDATE_PHASE3_MASTER_SUMMARY_OK")
PY
