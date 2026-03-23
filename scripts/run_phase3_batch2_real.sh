#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
PY_RUNNER="$BASE/scripts/run_phase3_batch2_real.py"
MANIFEST="$BASE/configs/phase3_batch2_only_manifest.json"
MASTER_UPDATE="$BASE/scripts/update_phase3_master_summary.sh"

if [ ! -f "$PY_RUNNER" ]; then
  echo "MISSING_RUNNER=$PY_RUNNER"
  exit 1
fi

if [ ! -f "$MANIFEST" ]; then
  echo "MISSING_MANIFEST=$MANIFEST"
  exit 1
fi

/usr/bin/python3 "$PY_RUNNER" --manifest "$MANIFEST"

if [ ! -f "$MASTER_UPDATE" ]; then
  echo "MISSING_MASTER_UPDATE_SCRIPT=$MASTER_UPDATE"
  exit 1
fi

"$MASTER_UPDATE"
