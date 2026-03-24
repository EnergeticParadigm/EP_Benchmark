import os
import json
import sys
import matplotlib.pyplot as plt

ROOT = "/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/phase3_batch6"
RESULTS = os.path.join(ROOT, "results")
FIGURES = os.path.join(ROOT, "figures")
os.makedirs(FIGURES, exist_ok=True)

files = {
    "Baseline": os.path.join(RESULTS, "phase3_batch6_baseline_results.jsonl"),
    "Scaffold": os.path.join(RESULTS, "phase3_batch6_scaffold_results.jsonl"),
    "EP": os.path.join(RESULTS, "phase3_batch6_ep_results.jsonl"),
}

for mode, path in files.items():
    if not os.path.isfile(path):
        print(f"Missing real run file for {mode}: {path}")
        sys.exit(1)

def load_jsonl(path):
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows

data = {mode: load_jsonl(path) for mode, path in files.items()}

baseline_map = {r["task_id"]: r for r in data["Baseline"]}
scaffold_map = {r["task_id"]: r for r in data["Scaffold"]}
ep_map = {r["task_id"]: r for r in data["EP"]}

task_ids = sorted(set(baseline_map) & set(scaffold_map) & set(ep_map))
if not task_ids:
    print("No shared task_ids across the three real run files.")
    sys.exit(2)

task_labels = [t.upper() for t in task_ids]
baseline_scores = [baseline_map[t]["total_score"] for t in task_ids]
scaffold_scores = [scaffold_map[t]["total_score"] for t in task_ids]
ep_scores = [ep_map[t]["total_score"] for t in task_ids]

x = list(range(len(task_ids)))
w = 0.24

plt.figure(figsize=(13, 7))
b1 = plt.bar([i - w for i in x], baseline_scores, width=w, label="Baseline")
b2 = plt.bar(x, scaffold_scores, width=w, label="Scaffold")
b3 = plt.bar([i + w for i in x], ep_scores, width=w, label="EP")
plt.xticks(x, task_labels)
plt.ylim(0, 15)
plt.ylabel("Total Score")
plt.xlabel("Task")
plt.title("Phase 3 Batch 6 — Real Run Comparison")
plt.axhline(14, linestyle="--", linewidth=1)
plt.legend()
for bars in [b1, b2, b3]:
    for bar in bars:
        h = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2, h + 0.08, f"{h:.0f}", ha="center", va="bottom", fontsize=9)
plt.tight_layout()
out1 = os.path.join(FIGURES, "phase3_batch6_three_mode_comparison_real.png")
plt.savefig(out1, dpi=220, bbox_inches="tight")
plt.close()

dimensions = [
    "constraint_detection",
    "path_invalidation_recognition",
    "objective_preservation",
    "replanning_quality",
    "contradiction_control",
    "waste_minimization",
    "governance_alignment",
]

labels = [
    "Constraint\nDetection",
    "Path\nInvalidation",
    "Objective\nPreservation",
    "Replanning\nQuality",
    "Contradiction\nControl",
    "Waste\nMinimization",
    "Governance\nAlignment",
]

def avg_dim(rows, dim):
    return sum(r["scores"][dim] for r in rows) / len(rows)

baseline_dim = [avg_dim(data["Baseline"], d) for d in dimensions]
scaffold_dim = [avg_dim(data["Scaffold"], d) for d in dimensions]
ep_dim = [avg_dim(data["EP"], d) for d in dimensions]

x = list(range(len(labels)))
plt.figure(figsize=(13, 7))
b1 = plt.bar([i - w for i in x], baseline_dim, width=w, label="Baseline")
b2 = plt.bar(x, scaffold_dim, width=w, label="Scaffold")
b3 = plt.bar([i + w for i in x], ep_dim, width=w, label="EP")
plt.xticks(x, labels)
plt.ylim(0, 2.2)
plt.ylabel("Average Dimension Score")
plt.title("Phase 3 Batch 6 — Real Run Dimension Comparison")
plt.axhline(2.0, linestyle="--", linewidth=1)
plt.legend()
for bars in [b1, b2, b3]:
    for bar in bars:
        h = bar.get_height()
        plt.text(bar.get_x() + bar.get_width()/2, h + 0.03, f"{h:.2f}", ha="center", va="bottom", fontsize=9)
plt.tight_layout()
out2 = os.path.join(FIGURES, "phase3_batch6_three_mode_dimension_comparison_real.png")
plt.savefig(out2, dpi=220, bbox_inches="tight")
plt.close()

print(out1)
print(out2)
