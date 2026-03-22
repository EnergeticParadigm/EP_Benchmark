#!/bin/bash
set -euo pipefail

ROOT="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
PHASE2="$ROOT/configs/phase2_manifest.json"
PHASE3="$ROOT/configs/phase3_added_manifest.json"
BACKUP="$ROOT/configs/phase2_manifest.json.bak_phase3_pilot"

cp "$PHASE2" "$BACKUP"
restore() {
  mv "$BACKUP" "$PHASE2"
}
trap restore EXIT

/usr/bin/python3 - <<'PY'
import json
from pathlib import Path

root = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
phase2 = root / "configs" / "phase2_manifest.json"
phase3 = root / "configs" / "phase3_added_manifest.json"

p2 = json.loads(phase2.read_text(encoding="utf-8"))
p3 = json.loads(phase3.read_text(encoding="utf-8"))

existing = p2.get("phase2_added_tasks", [])
extra = p3.get("phase3_added_tasks", [])

merged = []
seen = set()
for x in existing + extra:
    if x not in seen:
        merged.append(x)
        seen.add(x)

p2["phase2_added_tasks"] = merged
p2["phase2_total_added"] = len(merged)
phase2.write_text(json.dumps(p2, indent=2) + "\n", encoding="utf-8")
print("Temporary merged phase3 tasks into phase2_manifest.json")
print("Merged tasks:", extra)
PY

/usr/bin/python3 "$ROOT/runner/runner.py"
