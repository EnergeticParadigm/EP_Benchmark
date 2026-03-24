import json
import os
import matplotlib.pyplot as plt

root = "/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/phase3_batch6"

files = {
    "Baseline": os.path.join(root, "results", "phase3_batch6_baseline_results.jsonl"),
    "Scaffold": os.path.join(root, "results", "phase3_batch6_scaffold_results.jsonl"),
    "EP": os.path.join(root, "results", "phase3_batch6_ep_results.jsonl"),
}

data = {}
for mode, path in files.items():
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            if line.strip():
                rows.append(json.loads(line))
    data[mode] = rows

task_ids = [r["task_id"].upper() for r in data["Baseline"]]
baseline_scores = [r["total_score"] for r in data["Baseline"]]
scaffold_scores = [r["total_score"] for r in data["Scaffold"]]
ep_scores = [r["total_score"] for r in data["EP"]]

x = range(len(task_ids))
w = 0.24

plt.figure(figsize=(13, 6.8))
plt.bar([i - w for i in x], baseline_scores, width=w, label="Baseline")
plt.bar(x, scaffold_scores, width=w, label="Scaffold")
plt.bar([i + w for i in x], ep_scores, width=w, label="EP")

plt.xticks(list(x), task_ids)
plt.ylim(0, 15)
plt.ylabel("Total Score")
plt.xlabel("Task")
plt.title("Phase 3 Batch 6 — Baseline vs Scaffold vs EP")
plt.axhline(14, linestyle="--", linewidth=1)
plt.legend()
plt.tight_layout()

png = os.path.join(root, "figures", "phase3_batch6_three_mode_comparison.png")
plt.savefig(png, dpi=220, bbox_inches="tight")
print(png)
