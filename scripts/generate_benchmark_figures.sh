#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1"
FIG_DIR="$BASE/results/figures"
/bin/mkdir -p "$FIG_DIR"

cat > /Users/wesleyshu/ep_benchmark_v1/scripts/generate_benchmark_figures.py <<'PY'
#!/usr/bin/env python3
from pathlib import Path
import math
import matplotlib.pyplot as plt

BASE = Path("/Users/wesleyshu/ep_benchmark_v1")
FIG_DIR = BASE / "results" / "figures"
FIG_DIR.mkdir(parents=True, exist_ok=True)

modes = ["baseline", "baseline_scaffold", "ep"]

success_rates = {
    "baseline": 0.4375,
    "baseline_scaffold": 0.8750,
    "ep": 0.9688,
}

invalid_tool_rate = {
    "baseline": 0.1875,
    "baseline_scaffold": 0.0938,
    "ep": 0.0000,
}

checkpoint_rate = {
    "baseline": 0.0000,
    "baseline_scaffold": 0.0000,
    "ep": 0.2500,
}

rollback_rate = {
    "baseline": 0.0312,
    "baseline_scaffold": 0.1250,
    "ep": 0.2500,
}

failure_taxonomy = {
    "wrong_route": {
        "baseline": 6,
        "baseline_scaffold": 0,
        "ep": 0,
    },
    "wrong_tool": {
        "baseline": 6,
        "baseline_scaffold": 3,
        "ep": 0,
    },
    "final_answer_wrong": {
        "baseline": 6,
        "baseline_scaffold": 1,
        "ep": 1,
    },
}

paired_pvalues = {
    "baseline vs baseline_scaffold": 0.000122,
    "baseline vs ep": 0.000015,
    "baseline_scaffold vs ep": 0.250000,
}

# 1. Success rates
plt.figure(figsize=(8, 5))
x = range(len(modes))
y = [success_rates[m] for m in modes]
bars = plt.bar(x, y)
plt.xticks(list(x), modes, rotation=0)
plt.ylim(0, 1.05)
plt.ylabel("Success Rate")
plt.title("Benchmark Success Rates")
for i, v in enumerate(y):
    plt.text(i, v + 0.02, f"{v:.4f}", ha="center")
plt.tight_layout()
plt.savefig(FIG_DIR / "benchmark_success_rates.png", dpi=220, bbox_inches="tight")
plt.close()

# 2. Governance metrics
plt.figure(figsize=(9, 5.5))
metrics = ["invalid_tool_rate", "checkpoint_rate", "rollback_rate"]
metric_values = [
    [invalid_tool_rate[m] for m in modes],
    [checkpoint_rate[m] for m in modes],
    [rollback_rate[m] for m in modes],
]
width = 0.22
base_x = list(range(len(modes)))
for idx, values in enumerate(metric_values):
    xpos = [v + (idx - 1) * width for v in base_x]
    plt.bar(xpos, values, width=width, label=metrics[idx])
    for j, val in enumerate(values):
        plt.text(xpos[j], val + 0.01, f"{val:.4f}", ha="center", fontsize=9)
plt.xticks(base_x, modes)
plt.ylim(0, 0.32)
plt.ylabel("Rate")
plt.title("Governance-Oriented Metrics")
plt.legend()
plt.tight_layout()
plt.savefig(FIG_DIR / "benchmark_governance_metrics.png", dpi=220, bbox_inches="tight")
plt.close()

# 3. Failure taxonomy
plt.figure(figsize=(9.5, 5.5))
failure_names = list(failure_taxonomy.keys())
failure_values = [[failure_taxonomy[name][m] for m in modes] for name in failure_names]
width = 0.22
base_x = list(range(len(modes)))
for idx, values in enumerate(failure_values):
    xpos = [v + (idx - 1) * width for v in base_x]
    plt.bar(xpos, values, width=width, label=failure_names[idx])
    for j, val in enumerate(values):
        plt.text(xpos[j], val + 0.15, f"{val}", ha="center", fontsize=9)
plt.xticks(base_x, modes)
plt.ylabel("Count")
plt.title("Failure Taxonomy Comparison")
plt.legend()
plt.tight_layout()
plt.savefig(FIG_DIR / "benchmark_failure_taxonomy.png", dpi=220, bbox_inches="tight")
plt.close()

# 4. Paired significance
plt.figure(figsize=(9, 5.2))
labels = list(paired_pvalues.keys())
neglog = [-math.log10(v) for v in paired_pvalues.values()]
x = range(len(labels))
plt.bar(x, neglog)
plt.axhline(-math.log10(0.05), linestyle="--")
plt.xticks(list(x), labels, rotation=12)
plt.ylabel("-log10(p-value)")
plt.title("Paired Significance Strength")
for i, v in enumerate(neglog):
    plt.text(i, v + 0.08, f"{list(paired_pvalues.values())[i]:.6f}", ha="center", fontsize=9)
plt.tight_layout()
plt.savefig(FIG_DIR / "benchmark_paired_significance.png", dpi=220, bbox_inches="tight")
plt.close()

# 5. One-page summary figure
plt.figure(figsize=(11, 7))
plt.axis("off")
summary_text = (
    "EP Benchmark v1 Phase 2 Complete\n\n"
    "Task Pack\n"
    "32 tasks, fully executed\n\n"
    "Success Rates\n"
    "baseline = 0.4375\n"
    "baseline_scaffold = 0.8750\n"
    "ep = 0.9688\n\n"
    "Paired Significance\n"
    "baseline vs baseline_scaffold = 0.000122\n"
    "baseline vs ep = 0.000015\n"
    "baseline_scaffold vs ep = 0.250000\n\n"
    "Governance Metrics\n"
    "invalid_tool_rate: 0.1875 / 0.0938 / 0.0000\n"
    "checkpoint_rate: 0.0000 / 0.0000 / 0.2500\n"
    "rollback_rate: 0.0312 / 0.1250 / 0.2500\n\n"
    "Conclusion\n"
    "Raw execution is weakest.\n"
    "Structured execution is much stronger.\n"
    "Governed execution is strongest."
)
plt.text(0.03, 0.95, summary_text, va="top", fontsize=15)
plt.tight_layout()
plt.savefig(FIG_DIR / "benchmark_summary_onepage.png", dpi=220, bbox_inches="tight")
plt.close()

print(f"Created figures in {FIG_DIR}")
for path in sorted(FIG_DIR.glob("*.png")):
    print(path)
PY

/bin/chmod +x /Users/wesleyshu/ep_benchmark_v1/scripts/generate_benchmark_figures.py
/usr/bin/python3 /Users/wesleyshu/ep_benchmark_v1/scripts/generate_benchmark_figures.py
