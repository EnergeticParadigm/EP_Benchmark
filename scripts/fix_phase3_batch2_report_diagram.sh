#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
SRC="/mnt/data/phase3_batch2_diagrams/phase3_batch2_task_matrix.png"
DST_DIR="$BASE/reports/assets/phase3_batch2"
DST="$DST_DIR/phase3_batch2_task_matrix.png"
REPORT_SCRIPT="$BASE/scripts/create_phase3_batch2_formal_report.sh"

mkdir -p "$DST_DIR"

if [ ! -f "$SRC" ]; then
  echo "MISSING_SOURCE_DIAGRAM=$SRC"
  exit 1
fi

/bin/cp -f "$SRC" "$DST"

if [ ! -f "$REPORT_SCRIPT" ]; then
  echo "MISSING_REPORT_SCRIPT=$REPORT_SCRIPT"
  exit 1
fi

/usr/bin/python3 - <<'PY'
from pathlib import Path

script = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/scripts/create_phase3_batch2_formal_report.sh")
text = script.read_text(encoding="utf-8")
text = text.replace(
    'DIAGRAM_SRC="/mnt/data/phase3_batch2_diagrams/phase3_batch2_task_matrix.png"',
    'DIAGRAM_SRC="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/reports/assets/phase3_batch2/phase3_batch2_task_matrix.png"'
)
script.write_text(text, encoding="utf-8")
print("UPDATED_REPORT_SCRIPT=" + str(script))
PY

"$REPORT_SCRIPT"

echo "COPIED_DIAGRAM=$DST"
echo "REPORT_READY=$BASE/reports/phase3_batch2_formal_report.md"
