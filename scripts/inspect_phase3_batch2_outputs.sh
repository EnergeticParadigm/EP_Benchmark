#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
RESULT_DIR="$BASE/results/phase3_batch2"
RUNNER_LOG_DIR="$BASE/results/phase3_batch2_runner_logs"

echo "=== SUMMARY JSON ==="
if [ -f "$RESULT_DIR/phase3_batch2_summary.json" ]; then
  /bin/cat "$RESULT_DIR/phase3_batch2_summary.json"
else
  echo "MISSING: $RESULT_DIR/phase3_batch2_summary.json"
fi

echo
echo "=== SUMMARY MD ==="
if [ -f "$RESULT_DIR/phase3_batch2_summary.md" ]; then
  /bin/cat "$RESULT_DIR/phase3_batch2_summary.md"
else
  echo "MISSING: $RESULT_DIR/phase3_batch2_summary.md"
fi

echo
echo "=== RUNNER STDOUT SNAPSHOT ==="
if [ -f "$RESULT_DIR/raw/runner_stdout_snapshot.log" ]; then
  /bin/cat "$RESULT_DIR/raw/runner_stdout_snapshot.log"
else
  echo "MISSING: $RESULT_DIR/raw/runner_stdout_snapshot.log"
fi

echo
echo "=== RUNNER STDERR SNAPSHOT ==="
if [ -f "$RESULT_DIR/raw/runner_stderr_snapshot.log" ]; then
  /bin/cat "$RESULT_DIR/raw/runner_stderr_snapshot.log"
else
  echo "MISSING: $RESULT_DIR/raw/runner_stderr_snapshot.log"
fi

echo
echo "=== WRAPPER STDOUT ==="
if [ -f "$RESULT_DIR/logs/run_phase3_batch2.stdout.log" ]; then
  /bin/cat "$RESULT_DIR/logs/run_phase3_batch2.stdout.log"
else
  echo "MISSING: $RESULT_DIR/logs/run_phase3_batch2.stdout.log"
fi

echo
echo "=== WRAPPER STDERR ==="
if [ -f "$RESULT_DIR/logs/run_phase3_batch2.stderr.log" ]; then
  /bin/cat "$RESULT_DIR/logs/run_phase3_batch2.stderr.log"
else
  echo "MISSING: $RESULT_DIR/logs/run_phase3_batch2.stderr.log"
fi

echo
echo "=== RUNNER LOG DIR FILES ==="
/usr/bin/find "$RUNNER_LOG_DIR" -maxdepth 2 -type f | /usr/bin/sort || true

echo
echo "=== PHASE3_BATCH2 RESULT FILES ==="
/usr/bin/find "$RESULT_DIR" -maxdepth 3 -type f | /usr/bin/sort || true

echo
echo "=== SEARCH FOR TASK IDS IN RESULTS ==="
/usr/bin/grep -R -n -E 'SWE_CONSTRAINT_001|TERM_CONSTRAINT_001|TOOL_CONSTRAINT_001|final_score|PASS|FAIL|status' \
  "$RESULT_DIR" "$RUNNER_LOG_DIR" 2>/dev/null || true
