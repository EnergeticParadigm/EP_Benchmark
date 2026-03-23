#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"

SWE_DIR="$BASE/tasks/swe/phase3_batch2_swe_constraint_001"
TERM_DIR="$BASE/tasks/terminal/phase3_batch2_term_constraint_001"
TOOL_DIR="$BASE/tasks/tool_routing/phase3_batch2_tool_constraint_001"

MANIFEST1="$BASE/configs/task_manifest.json"
MANIFEST2="$BASE/configs/phase3_added_manifest.json"

echo "=== PHASE 3 BATCH 2 DRY RUN START ==="

echo
echo "=== 1. File presence check ==="
for f in \
  "$SWE_DIR/task.md" "$SWE_DIR/metadata.json" "$SWE_DIR/grader.py" \
  "$TERM_DIR/task.md" "$TERM_DIR/metadata.json" "$TERM_DIR/grader.py" \
  "$TOOL_DIR/task.md" "$TOOL_DIR/metadata.json" "$TOOL_DIR/grader.py" \
  "$MANIFEST1" "$MANIFEST2"
do
  if [ -f "$f" ]; then
    echo "OK FILE: $f"
  else
    echo "MISSING FILE: $f"
    exit 1
  fi
done

echo
echo "=== 2. JSON validity check ==="
/usr/bin/python3 -m json.tool "$SWE_DIR/metadata.json" >/dev/null
/usr/bin/python3 -m json.tool "$TERM_DIR/metadata.json" >/dev/null
/usr/bin/python3 -m json.tool "$TOOL_DIR/metadata.json" >/dev/null
/usr/bin/python3 -m json.tool "$MANIFEST1" >/dev/null
/usr/bin/python3 -m json.tool "$MANIFEST2" >/dev/null
echo "OK JSON"

echo
echo "=== 3. Python compile check ==="
/usr/bin/python3 -m py_compile "$SWE_DIR/grader.py"
/usr/bin/python3 -m py_compile "$TERM_DIR/grader.py"
/usr/bin/python3 -m py_compile "$TOOL_DIR/grader.py"
echo "OK PY_COMPILE"

echo
echo "=== 4. Manifest registration check ==="
/usr/bin/grep -q '"task_id": "SWE_CONSTRAINT_001"' "$MANIFEST1"
/usr/bin/grep -q '"task_id": "TERM_CONSTRAINT_001"' "$MANIFEST1"
/usr/bin/grep -q '"task_id": "TOOL_CONSTRAINT_001"' "$MANIFEST1"
/usr/bin/grep -q '"task_id": "SWE_CONSTRAINT_001"' "$MANIFEST2"
/usr/bin/grep -q '"task_id": "TERM_CONSTRAINT_001"' "$MANIFEST2"
/usr/bin/grep -q '"task_id": "TOOL_CONSTRAINT_001"' "$MANIFEST2"
echo "OK MANIFEST_REGISTRATION"

echo
echo "=== 5. Metadata-to-path consistency check ==="
/usr/bin/python3 - <<'PY'
import json
from pathlib import Path

base = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
checks = [
    ("SWE_CONSTRAINT_001", base / "tasks/swe/phase3_batch2_swe_constraint_001/metadata.json", "swe", "phase3_batch2_swe_constraint_001"),
    ("TERM_CONSTRAINT_001", base / "tasks/terminal/phase3_batch2_term_constraint_001/metadata.json", "terminal", "phase3_batch2_term_constraint_001"),
    ("TOOL_CONSTRAINT_001", base / "tasks/tool_routing/phase3_batch2_tool_constraint_001/metadata.json", "tool_routing", "phase3_batch2_tool_constraint_001"),
]
for expected_id, path, expected_track, expected_folder in checks:
    data = json.loads(path.read_text(encoding="utf-8"))
    assert data["task_id"] == expected_id, f"{path}: task_id mismatch"
    assert data["track"] == expected_track, f"{path}: track mismatch"
    assert data["task_folder"] == expected_folder, f"{path}: task_folder mismatch"
print("OK METADATA_PATH_CONSISTENCY")
PY

echo
echo "=== 6. Grader smoke test with evidence_examples ==="
/usr/bin/python3 "$SWE_DIR/grader.py" --evidence "$SWE_DIR/evidence_examples/pass.json" > /tmp/phase3_batch2_swe_result.json
/usr/bin/python3 "$TERM_DIR/grader.py" --evidence "$TERM_DIR/evidence_examples/pass.json" > /tmp/phase3_batch2_term_result.json
/usr/bin/python3 "$TOOL_DIR/grader.py" --evidence "$TOOL_DIR/evidence_examples/pass.json" > /tmp/phase3_batch2_tool_result.json

/usr/bin/python3 - <<'PY'
import json
paths = [
    "/tmp/phase3_batch2_swe_result.json",
    "/tmp/phase3_batch2_term_result.json",
    "/tmp/phase3_batch2_tool_result.json",
]
for p in paths:
    data = json.loads(open(p, encoding="utf-8").read())
    assert abs(float(data["final_score"]) - 1.0) < 1e-9, f"{p}: final_score not 1.0"
    assert data["failure_modes"] == [], f"{p}: failure_modes not empty"
print("OK GRADER_SMOKE_TEST")
PY

echo
echo "=== 7. Runner discovery ==="
/usr/bin/find "$BASE/runner" "$BASE/scripts" \
  \( -name "*.py" -o -name "*.sh" \) \
  -type f \
  -maxdepth 3 \
  | /usr/bin/sort > /tmp/ep_runner_candidates.txt || true

cat /tmp/ep_runner_candidates.txt

echo
echo "=== 8. Likely runner entry scan ==="
/usr/bin/python3 - <<'PY'
from pathlib import Path
import re

candidates = []
for root in [Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner"),
             Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/scripts")]:
    if not root.exists():
        continue
    for path in root.rglob("*"):
        if path.is_file() and path.suffix in {".py", ".sh"}:
            try:
                text = path.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                continue
            score = 0
            for token in ["task_manifest", "phase3_added_manifest", "metadata.json", "grader.py", "task_id", "tasks/"]:
                if token in text:
                    score += 1
            if score > 0:
                candidates.append((score, str(path)))
for score, path in sorted(candidates, reverse=True)[:20]:
    print(f"{score}\t{path}")
PY

echo
echo "=== 9. Dry-run summary ==="
echo "PHASE3_BATCH2_TASKS_READY=YES"
echo "MANIFEST_REGISTERED=YES"
echo "GRADER_SMOKE_TEST=PASS"
echo "RUNNER_DISCOVERY_FILE=/tmp/ep_runner_candidates.txt"
echo "=== PHASE 3 BATCH 2 DRY RUN COMPLETE ==="
