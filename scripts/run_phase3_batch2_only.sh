#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
CONFIG_DIR="$BASE/configs"
RESULT_DIR="$BASE/results/phase3_batch2_runner_logs"
RUNNER_PY="$BASE/scripts/run_phase3_only.py"
SUBSET_MANIFEST="$CONFIG_DIR/phase3_batch2_only_manifest.json"
SOURCE_MANIFEST="$CONFIG_DIR/task_manifest.json"

mkdir -p "$RESULT_DIR"

if [ ! -f "$RUNNER_PY" ]; then
  echo "MISSING_RUNNER: $RUNNER_PY"
  exit 1
fi

if [ ! -f "$SOURCE_MANIFEST" ]; then
  echo "MISSING_MANIFEST: $SOURCE_MANIFEST"
  exit 1
fi

/usr/bin/python3 - <<'PY'
import json
from pathlib import Path

source = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/configs/task_manifest.json")
target = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/configs/phase3_batch2_only_manifest.json")
wanted = {
    "SWE_CONSTRAINT_001",
    "TERM_CONSTRAINT_001",
    "TOOL_CONSTRAINT_001",
}

data = json.loads(source.read_text(encoding="utf-8"))

def collect_tasks(node, out):
    if isinstance(node, list):
        for item in node:
            collect_tasks(item, out)
    elif isinstance(node, dict):
        if "task_id" in node and node["task_id"] in wanted:
            out.append(node)
        for v in node.values():
            collect_tasks(v, out)

found = []
collect_tasks(data, found)

seen = set()
dedup = []
for item in found:
    tid = item["task_id"]
    if tid not in seen:
        seen.add(tid)
        dedup.append(item)

missing = sorted(wanted - seen)
if missing:
    raise SystemExit("MISSING_TASKS_IN_SOURCE_MANIFEST: " + ", ".join(missing))

target.write_text(json.dumps({"tasks": dedup}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print("WROTE_SUBSET_MANIFEST=" + str(target))
for item in dedup:
    print("INCLUDED_TASK_ID=" + item["task_id"])
PY

STDOUT1="$RESULT_DIR/run_phase3_batch2_only.stdout.log"
STDERR1="$RESULT_DIR/run_phase3_batch2_only.stderr.log"
STDOUT2="$RESULT_DIR/run_phase3_batch2_only_alt.stdout.log"
STDERR2="$RESULT_DIR/run_phase3_batch2_only_alt.stderr.log"

set +e

/usr/bin/python3 "$RUNNER_PY" \
  --manifest "$SUBSET_MANIFEST" \
  >"$STDOUT1" 2>"$STDERR1"
RC1=$?

if [ $RC1 -eq 0 ]; then
  echo "RUNNER_OK"
  echo "RUNNER_ENTRY=$RUNNER_PY"
  echo "RUNNER_MODE=--manifest"
  echo "STDOUT_LOG=$STDOUT1"
  echo "STDERR_LOG=$STDERR1"
  exit 0
fi

/usr/bin/python3 "$RUNNER_PY" \
  --task-manifest "$SUBSET_MANIFEST" \
  >"$STDOUT2" 2>"$STDERR2"
RC2=$?

if [ $RC2 -eq 0 ]; then
  echo "RUNNER_OK"
  echo "RUNNER_ENTRY=$RUNNER_PY"
  echo "RUNNER_MODE=--task-manifest"
  echo "STDOUT_LOG=$STDOUT2"
  echo "STDERR_LOG=$STDERR2"
  exit 0
fi

set -e

echo "RUNNER_FAILED"
echo "RUNNER_ENTRY=$RUNNER_PY"
echo "ATTEMPT1=--manifest"
echo "ATTEMPT1_STDOUT=$STDOUT1"
echo "ATTEMPT1_STDERR=$STDERR1"
echo "ATTEMPT2=--task-manifest"
echo "ATTEMPT2_STDOUT=$STDOUT2"
echo "ATTEMPT2_STDERR=$STDERR2"

echo
echo "==== STDERR attempt 1 ===="
/bin/cat "$STDERR1" || true
echo
echo "==== STDERR attempt 2 ===="
/bin/cat "$STDERR2" || true

exit 1
