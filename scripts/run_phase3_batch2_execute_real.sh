#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
MANIFEST="$BASE/configs/phase3_batch2_only_manifest.json"
PY="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/execute_phase3_batch2.py"

/usr/bin/python3 "$PY" --manifest "$MANIFEST"
