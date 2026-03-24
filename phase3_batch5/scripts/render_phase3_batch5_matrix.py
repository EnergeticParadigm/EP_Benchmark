#!/usr/bin/env python3
import csv
from pathlib import Path
import matplotlib.pyplot as plt
import numpy as np

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/phase3_batch5")
CSV_PATH = ROOT / "evaluation" / "phase3_batch5_scoring.csv"
PNG_PATH = ROOT / "phase3_batch5_measured_results_matrix.png"

TASK_ORDER = [
    "SWE_COUNTERFACTUAL_001",
    "TERM_COUNTERFACTUAL_001",
    "TOOL_COUNTERFACTUAL_001",
]
VARIANT_ORDER = [
    "Baseline",
    "Baseline Scaffold",
    "EP",
]

def main():
    rows = []
    with CSV_PATH.open("r", encoding="utf-8-sig", newline="") as f:
        for row in csv.DictReader(f):
            rows.append(row)

    score_map = {}
    label_map = {}
    for r in rows:
        task = r["task_id"].strip()
        variant = r["system_variant"].strip()
        score_txt = (r["score"] or "").strip()
        label = (r["label"] or "").strip().upper()
        score = float(score_txt) if score_txt else np.nan
        score_map[(task, variant)] = score
        label_map[(task, variant)] = label

    data = np.array([
        [score_map.get((task, variant), np.nan) for variant in VARIANT_ORDER]
        for task in TASK_ORDER
    ])

    fig, ax = plt.subplots(figsize=(10, 7))
    im = ax.imshow(data, aspect="auto", vmin=0.0, vmax=1.0, cmap="viridis")

    ax.set_xticks(range(len(VARIANT_ORDER)))
    ax.set_xticklabels(VARIANT_ORDER, fontsize=14)
    ax.set_yticks(range(len(TASK_ORDER)))
    ax.set_yticklabels(TASK_ORDER, fontsize=14)
    ax.set_xlabel("System variant", fontsize=16)
    ax.set_ylabel("Task", fontsize=16)
    ax.set_title("Phase 3 Batch 5 Measured Results\nCounterfactual-Compliance Drift", fontsize=22)

    for i, task in enumerate(TASK_ORDER):
        for j, variant in enumerate(VARIANT_ORDER):
            s = score_map.get((task, variant), np.nan)
            lbl = label_map.get((task, variant), "")
            if np.isnan(s):
                txt = "PENDING"
                color = "white"
            else:
                txt = f"{lbl}\n{s:.1f}" if lbl else f"{s:.1f}"
                color = "white" if s >= 0.75 else "black"
            ax.text(j, i, txt, ha="center", va="center", fontsize=16, color=color)

    cbar = fig.colorbar(im, ax=ax)
    cbar.set_label("Score", fontsize=16)
    cbar.ax.tick_params(labelsize=12)

    def count_label(target_variant, target_label):
        return sum(
            1 for t in TASK_ORDER
            if label_map.get((t, target_variant), "").upper() == target_label.upper()
        )

    summary = (
        f"Summary: Baseline = {count_label('Baseline','PASS')}/3 pass"
        f"   |   Baseline Scaffold = {count_label('Baseline Scaffold','PASS')}/3 pass"
        f"   |   EP = {count_label('EP','PASS')}/3 pass"
    )
    fig.text(0.5, 0.03, summary, ha="center", fontsize=14)

    plt.tight_layout(rect=[0, 0.06, 1, 1])
    plt.savefig(PNG_PATH, dpi=220)
    print(PNG_PATH)

if __name__ == "__main__":
    main()
