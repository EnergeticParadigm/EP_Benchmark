#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
OUT="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/results/phase3_batch2_execution/inner_executor_candidates.txt"

mkdir -p /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/results/phase3_batch2_execution

{
  echo "=== CANDIDATE FILES BY NAME ==="
  /usr/bin/find "$BASE/scripts" "$BASE/runner" \
    \( -name "*.py" -o -name "*.sh" \) -type f 2>/dev/null \
    | /usr/bin/grep -E 'baseline|scaffold|ep|executor|runner|model|inference|generate|execute' \
    | /usr/bin/sort || true

  echo
  echo "=== FILES MENTIONING task-id / output / metadata ==="
  /usr/bin/grep -R -n -E 'task-id|task_id|output|metadata|results/raw|baseline|scaffold|ep' \
    "$BASE/scripts" "$BASE/runner" 2>/dev/null || true

  echo
  echo "=== LIKELY CLI ENTRY FILES ==="
  /usr/bin/python3 - <<'PY'
from pathlib import Path

base = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
cands = []
for root in [base / "scripts", base / "runner"]:
    if not root.exists():
        continue
    for p in root.rglob("*"):
        if not p.is_file() or p.suffix not in {".py", ".sh"}:
            continue
        try:
            text = p.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        score = 0
        for token in [
            "--task-id", "--task_id", "--output", "--metadata", "--task-dir", "--task-md",
            "results/raw", "baseline", "scaffold", "ep", "execute", "runner"
        ]:
            if token in text or token in p.name:
                score += 1
        if score > 0:
            cands.append((score, str(p)))
for score, path in sorted(cands, reverse=True)[:80]:
    print(f"{score}\t{path}")
PY
} > "$OUT"

echo "DISCOVERY_REPORT=$OUT"
