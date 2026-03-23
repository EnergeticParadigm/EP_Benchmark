#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
PY_RUNNER="$BASE/scripts/run_phase3_batch2_compare.py"
MANIFEST="$BASE/configs/phase3_batch2_only_manifest.json"

if [ ! -f "$PY_RUNNER" ]; then
  echo "MISSING_RUNNER=$PY_RUNNER"
  exit 1
fi

if [ ! -f "$MANIFEST" ]; then
  echo "MISSING_MANIFEST=$MANIFEST"
  exit 1
fi

/usr/bin/python3 "$PY_RUNNER" --manifest "$MANIFEST"
