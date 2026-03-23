#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
OUT="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/reports/assets/phase3_batch2/phase3_batch2_task_matrix.png"
PY_SCRIPT="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/scripts/redraw_phase3_batch2_task_matrix.py"
REPORT_SCRIPT="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/scripts/create_phase3_batch2_formal_report.sh"

mkdir -p /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/reports/assets/phase3_batch2

cat > "$PY_SCRIPT" <<'PY'
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

out = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/reports/assets/phase3_batch2/phase3_batch2_task_matrix.png")
out.parent.mkdir(parents=True, exist_ok=True)

systems = ["Baseline", "Scaffold", "EP"]
tasks = ["SWE_CONSTRAINT_001", "TERM_CONSTRAINT_001", "TOOL_CONSTRAINT_001"]
matrix = np.array([
    [0, 1, 2],
    [0, 1, 2],
    [0, 1, 2],
])

fig, ax = plt.subplots(figsize=(9, 5.5))
im = ax.imshow(matrix, aspect="auto")
ax.set_title("Phase 3 Batch 2: Task-by-Task Outcome Matrix")
ax.set_xticks(np.arange(len(systems)))
ax.set_xticklabels(systems)
ax.set_yticks(np.arange(len(tasks)))
ax.set_yticklabels(tasks)

labels = {0: "Fail", 1: "Partial", 2: "Pass"}
for i in range(matrix.shape[0]):
    for j in range(matrix.shape[1]):
        ax.text(j, i, labels[int(matrix[i, j])], ha="center", va="center")

cbar = fig.colorbar(im, ax=ax)
cbar.set_ticks([0, 1, 2])
cbar.set_ticklabels(["Fail", "Partial", "Pass"])

fig.tight_layout()
fig.savefig(out, dpi=200, bbox_inches="tight")
plt.close(fig)

print(str(out))
PY

if /usr/bin/python3 -c "import matplotlib, numpy" >/dev/null 2>&1; then
  /usr/bin/python3 "$PY_SCRIPT"
elif /opt/homebrew/bin/python3 -c "import matplotlib, numpy" >/dev/null 2>&1; then
  /opt/homebrew/bin/python3 "$PY_SCRIPT"
elif /usr/local/bin/python3 -c "import matplotlib, numpy" >/dev/null 2>&1; then
  /usr/local/bin/python3 "$PY_SCRIPT"
else
  echo "NO_LOCAL_PYTHON_WITH_MATPLOTLIB_AND_NUMPY_FOUND"
  exit 1
fi

/usr/bin/python3 - <<'PY'
from pathlib import Path
script = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/scripts/create_phase3_batch2_formal_report.sh")
text = script.read_text(encoding="utf-8")
old = 'DIAGRAM_SRC="/mnt/data/phase3_batch2_diagrams/phase3_batch2_task_matrix.png"'
new = 'DIAGRAM_SRC="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/reports/assets/phase3_batch2/phase3_batch2_task_matrix.png"'
if old in text:
    text = text.replace(old, new)
script.write_text(text, encoding="utf-8")
print("UPDATED=" + str(script))
PY

"$REPORT_SCRIPT"

echo "DIAGRAM_READY=$OUT"
echo "REPORT_READY=/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/reports/phase3_batch2_formal_report.md"
