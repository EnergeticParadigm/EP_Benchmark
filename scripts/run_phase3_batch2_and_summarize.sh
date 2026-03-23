#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
RUNNER="$BASE/scripts/run_phase3_only.py"
WRAPPER="$BASE/scripts/run_phase3_batch2_only.sh"
MANIFEST="$BASE/configs/phase3_batch2_only_manifest.json"
RESULT_ROOT="$BASE/results/phase3_batch2"
LOG_DIR="$RESULT_ROOT/logs"
RAW_DIR="$RESULT_ROOT/raw"
SUMMARY_JSON="$RESULT_ROOT/phase3_batch2_summary.json"
SUMMARY_MD="$RESULT_ROOT/phase3_batch2_summary.md"
STDOUT_LOG="$LOG_DIR/run_phase3_batch2.stdout.log"
STDERR_LOG="$LOG_DIR/run_phase3_batch2.stderr.log"
RUNNER_STDOUT_COPY="$RAW_DIR/runner_stdout_snapshot.log"
RUNNER_STDERR_COPY="$RAW_DIR/runner_stderr_snapshot.log"

mkdir -p "$LOG_DIR" "$RAW_DIR"

if [ ! -f "$RUNNER" ]; then
  echo "MISSING_RUNNER: $RUNNER"
  exit 1
fi

if [ ! -f "$WRAPPER" ]; then
  echo "MISSING_WRAPPER: $WRAPPER"
  exit 1
fi

if [ ! -f "$MANIFEST" ]; then
  echo "MISSING_MANIFEST: $MANIFEST"
  exit 1
fi

"$WRAPPER" > "$STDOUT_LOG" 2> "$STDERR_LOG"

RUNNER_WRAPPER_STDOUT="$BASE/results/phase3_batch2_runner_logs/run_phase3_batch2_only.stdout.log"
RUNNER_WRAPPER_STDERR="$BASE/results/phase3_batch2_runner_logs/run_phase3_batch2_only.stderr.log"

if [ -f "$RUNNER_WRAPPER_STDOUT" ]; then
  /bin/cp -f "$RUNNER_WRAPPER_STDOUT" "$RUNNER_STDOUT_COPY"
else
  : > "$RUNNER_STDOUT_COPY"
fi

if [ -f "$RUNNER_WRAPPER_STDERR" ]; then
  /bin/cp -f "$RUNNER_WRAPPER_STDERR" "$RUNNER_STDERR_COPY"
else
  : > "$RUNNER_STDERR_COPY"
fi

/usr/bin/python3 - <<'PY'
import json
import re
from pathlib import Path

base = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
result_root = base / "results/phase3_batch2"
log_dir = result_root / "logs"
raw_dir = result_root / "raw"

stdout_log = log_dir / "run_phase3_batch2.stdout.log"
stderr_log = log_dir / "run_phase3_batch2.stderr.log"
runner_stdout = raw_dir / "runner_stdout_snapshot.log"
runner_stderr = raw_dir / "runner_stderr_snapshot.log"
manifest = base / "configs/phase3_batch2_only_manifest.json"

summary_json = result_root / "phase3_batch2_summary.json"
summary_md = result_root / "phase3_batch2_summary.md"

wrapper_stdout = stdout_log.read_text(encoding="utf-8", errors="ignore") if stdout_log.exists() else ""
wrapper_stderr = stderr_log.read_text(encoding="utf-8", errors="ignore") if stderr_log.exists() else ""
runner_stdout_text = runner_stdout.read_text(encoding="utf-8", errors="ignore") if runner_stdout.exists() else ""
runner_stderr_text = runner_stderr.read_text(encoding="utf-8", errors="ignore") if runner_stderr.exists() else ""

manifest_data = json.loads(manifest.read_text(encoding="utf-8"))
tasks = manifest_data.get("tasks", []) if isinstance(manifest_data, dict) else []
task_ids = [t.get("task_id", "") for t in tasks if isinstance(t, dict)]

def detect_status(task_id: str, text: str) -> str:
    patterns = [
        (rf"\b{re.escape(task_id)}\b.*\bPASS(?:ED)?\b", "pass"),
        (rf"\bPASS(?:ED)?\b.*\b{re.escape(task_id)}\b", "pass"),
        (rf"\b{re.escape(task_id)}\b.*\bFAIL(?:ED)?\b", "fail"),
        (rf"\bFAIL(?:ED)?\b.*\b{re.escape(task_id)}\b", "fail"),
        (rf'"task_id"\s*:\s*"{re.escape(task_id)}".*?"final_score"\s*:\s*1(?:\.0+)?', "pass"),
        (rf'"task_id"\s*:\s*"{re.escape(task_id)}".*?"final_score"\s*:\s*0(?:\.\d+)?', "fail"),
    ]
    merged = "\n".join([wrapper_stdout, wrapper_stderr, runner_stdout_text, runner_stderr_text, text])
    for pattern, status in patterns:
        if re.search(pattern, merged, flags=re.IGNORECASE | re.DOTALL):
            return status
    return "unknown"

task_summaries = []
for task in tasks:
    if not isinstance(task, dict):
        continue
    task_id = task.get("task_id", "")
    track = task.get("track", "")
    task_dir = task.get("task_dir", "")
    task_status = detect_status(task_id, runner_stdout_text)
    task_summaries.append({
        "task_id": task_id,
        "track": track,
        "task_dir": task_dir,
        "status": task_status
    })

overall_runner_ok = "RUNNER_OK" in wrapper_stdout
pass_count = sum(1 for t in task_summaries if t["status"] == "pass")
fail_count = sum(1 for t in task_summaries if t["status"] == "fail")
unknown_count = sum(1 for t in task_summaries if t["status"] == "unknown")

summary = {
    "batch_id": "phase3_batch2",
    "runner_entry": str(base / "scripts/run_phase3_only.py"),
    "wrapper_script": str(base / "scripts/run_phase3_batch2_only.sh"),
    "manifest": str(manifest),
    "overall_runner_ok": overall_runner_ok,
    "task_count": len(task_summaries),
    "pass_count": pass_count,
    "fail_count": fail_count,
    "unknown_count": unknown_count,
    "tasks": task_summaries,
    "logs": {
        "wrapper_stdout": str(stdout_log),
        "wrapper_stderr": str(stderr_log),
        "runner_stdout_snapshot": str(runner_stdout),
        "runner_stderr_snapshot": str(runner_stderr),
    }
}

summary_json.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

lines = []
lines.append("# Phase 3 Batch 2 Execution Summary")
lines.append("")
lines.append(f"- Batch: `phase3_batch2`")
lines.append(f"- Runner OK: `{str(overall_runner_ok).lower()}`")
lines.append(f"- Task count: `{len(task_summaries)}`")
lines.append(f"- Pass count: `{pass_count}`")
lines.append(f"- Fail count: `{fail_count}`")
lines.append(f"- Unknown count: `{unknown_count}`")
lines.append("")
lines.append("## Tasks")
lines.append("")
for item in task_summaries:
    lines.append(f"- `{item['task_id']}` | track=`{item['track']}` | status=`{item['status']}`")
lines.append("")
lines.append("## Logs")
lines.append("")
lines.append(f"- Wrapper stdout: `{stdout_log}`")
lines.append(f"- Wrapper stderr: `{stderr_log}`")
lines.append(f"- Runner stdout snapshot: `{runner_stdout}`")
lines.append(f"- Runner stderr snapshot: `{runner_stderr}`")
lines.append("")
lines.append("## Notes")
lines.append("")
if unknown_count > 0:
    lines.append("- Some task-level statuses remain `unknown` because the current runner output did not expose a per-task verdict in a parseable form.")
else:
    lines.append("- All task-level statuses were parsed from runner output.")
summary_md.write_text("\n".join(lines) + "\n", encoding="utf-8")

print("SUMMARY_JSON=" + str(summary_json))
print("SUMMARY_MD=" + str(summary_md))
print("PASS_COUNT=" + str(pass_count))
print("FAIL_COUNT=" + str(fail_count))
print("UNKNOWN_COUNT=" + str(unknown_count))
print("PHASE3_BATCH2_SUMMARY_OK")
PY

echo "DONE"
echo "SCRIPT=/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/scripts/run_phase3_batch2_and_summarize.sh"
echo "SUMMARY_JSON=$SUMMARY_JSON"
echo "SUMMARY_MD=$SUMMARY_MD"
