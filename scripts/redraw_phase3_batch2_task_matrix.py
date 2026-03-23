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
