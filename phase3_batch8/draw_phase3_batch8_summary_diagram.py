import json
import os
import matplotlib.pyplot as plt

ROOT = "/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/phase3_batch8"
RESULTS = os.path.join(ROOT, "results")
FIGURES = os.path.join(ROOT, "figures")

files = {
    "Baseline": os.path.join(RESULTS, "phase3_batch8_baseline_results.jsonl"),
    "Scaffold": os.path.join(RESULTS, "phase3_batch8_scaffold_results.jsonl"),
    "EP": os.path.join(RESULTS, "phase3_batch8_ep_results.jsonl"),
}

def load_jsonl(path):
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows

data = {mode: load_jsonl(path) for mode, path in files.items()}

task_ids = [r["task_id"].upper() for r in data["Baseline"]]
baseline_scores = [r["total_score"] for r in data["Baseline"]]
scaffold_scores = [r["total_score"] for r in data["Scaffold"]]
ep_scores = [r["total_score"] for r in data["EP"]]

x = list(range(len(task_ids)))
w = 0.24

plt.figure(figsize=(13, 7))
b1 = plt.bar([i - w for i in x], baseline_scores, width=w, label="Baseline")
b2 = plt.bar(x, scaffold_scores, width=w, label="Scaffold")
b3 = plt.bar([i + w for i in x], ep_scores, width=w, label="EP")

plt.xticks(x, task_ids)
plt.ylim(0, 15)
plt.ylabel("Score per Task")
plt.xlabel("Task")
plt.title("Phase 3 Batch 8 — False Stability Recognition")
plt.axhline(14, linestyle="--", linewidth=1)
plt.legend()

for bars in [b1, b2, b3]:
    for bar in bars:
        h = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2,
            h + 0.08,
            f"{int(h)}",
            ha="center",
            va="bottom",
            fontsize=9
        )

plt.figtext(
    0.5, -0.02,
    "Baseline = false stability acceptance | Scaffold = partial fragility recognition | EP = stability reassessment with redesign",
    ha="center",
    fontsize=10
)

out_path = os.path.join(FIGURES, "phase3_batch8_summary_diagram.png")
plt.tight_layout()
plt.savefig(out_path, dpi=220, bbox_inches="tight")
print(out_path)
