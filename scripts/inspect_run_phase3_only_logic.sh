#!/bin/bash
set -euo pipefail

TARGET="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/scripts/run_phase3_only.py"
OUT="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/results/phase3_batch2/run_phase3_only_logic_report.txt"

if [ ! -f "$TARGET" ]; then
  echo "MISSING: $TARGET"
  exit 1
fi

mkdir -p /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/results/phase3_batch2

{
  echo "=== FILE ==="
  echo "$TARGET"
  echo

  echo "=== SEARCH: manifest / argparse / task_id / AMBIG / CONSTRAINT ==="
  /usr/bin/grep -n -E 'manifest|argparse|task_id|tasks|AMBIG|CONSTRAINT|phase3|json.load|read_text|Path\(' "$TARGET" || true
  echo

  echo "=== SEARCH: explicit old task ids ==="
  /usr/bin/grep -n -E 'SWE_AMBIG_001|TERM_AMBIG_001|TOOL_AMBIG_001' "$TARGET" || true
  echo

  echo "=== SEARCH: possible hard-coded lists ==="
  /usr/bin/grep -n -E '\[[^]]*SWE_|\\[[^]]*TERM_|\\[[^]]*TOOL_|task_ids|selected_tasks|phase3_tasks|TASKS' "$TARGET" || true
  echo

  echo "=== FULL FILE WITH LINE NUMBERS ==="
  /usr/bin/nl -ba "$TARGET"
} > "$OUT"

echo "REPORT_WRITTEN=$OUT"
