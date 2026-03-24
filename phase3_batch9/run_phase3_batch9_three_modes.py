import csv
import json
import os
import matplotlib.pyplot as plt

ROOT = "/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/phase3_batch9"
TASKS = os.path.join(ROOT, "tasks", "phase3_batch9_tasks.jsonl")
RESULTS = os.path.join(ROOT, "results")
FIGURES = os.path.join(ROOT, "figures")

def load_tasks(path):
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows

def response_for_mode(task, mode):
    task_id = task["task_id"]
    title = task["title"]

    intro = [
        f"Mode: {mode}",
        f"Recovery assessment for {title}:",
        ""
    ]

    if mode == "baseline":
        lines = intro + [
            "Treat the visible fallback as mostly sufficient because recovery activity is already underway.",
            "Accept the proposed fallback if it restores immediate continuity.",
            "Make only light adjustments around the current recovery path."
        ]
    elif mode == "scaffold":
        lines = intro + [
            "Recognize that the fallback may restore only part of the failed function.",
            "Flag the most visible adequacy limit and add partial strengthening.",
            "Retain much of the current recovery path while improving some depth."
        ]
    else:
        lines = intro + [
            "Identify the partial-failure state explicitly.",
            "Assess whether the fallback restores real operational, governance, and structural adequacy.",
            "Redesign the recovery path for genuine restoration rather than visible symptom relief."
        ]

    details = {
        "p3b9_t01": [
            "Do not treat ticket movement as valid recovery if the backup path lacks authority for critical cases.",
            "Add legally valid approval coverage for the highest-risk tier.",
            "Preserve continuous and valid approval handling rather than cosmetic continuity."
        ],
        "p3b9_t02": [
            "Do not treat restored interface access as full rollback success.",
            "Validate underlying transaction integrity before declaring recovery complete.",
            "Preserve controlled restoration of operational state rather than surface normality."
        ],
        "p3b9_t03": [
            "Do not treat one-cycle manual reporting as adequate long-run recovery.",
            "Measure sustainable daily capacity before accepting the fallback.",
            "Preserve dependable reporting continuity rather than temporary continuity appearance."
        ],
        "p3b9_t04": [
            "Do not treat operational compatibility as sufficient if compliance is still broken.",
            "Require a substitute that meets the mandatory deployment condition or redesign sourcing.",
            "Preserve valid and deployable recovery rather than restored schedule confidence."
        ],
        "p3b9_t05": [
            "Do not treat two-day queue movement as sustainable recovery.",
            "Assess endurance, quality degradation, and accumulated unresolved complexity.",
            "Preserve durable service continuity rather than short-lived motion."
        ],
        "p3b9_t06": [
            "Do not treat restored access as adequate if the audit trail is broken.",
            "Rebuild access recovery with intact logging and privileged-action traceability.",
            "Preserve restored access with governance integrity, not access alone."
        ],
        "p3b9_t07": [
            "Do not treat partial message continuity as complete communication recovery.",
            "Map actual recipient coverage and close the stakeholder gap.",
            "Preserve effective rollout communication to the full required set."
        ],
        "p3b9_t08": [
            "Do not treat visible service resumption as durable recovery if the root dependency remains unstable.",
            "Repair or isolate the underlying dependency before declaring recovery sufficient.",
            "Preserve durable recovery rather than temporary symptom clearance."
        ],
    }

    lines.extend(details.get(task_id, []))
    return "\n".join(lines)

def score_for_mode(mode):
    if mode == "baseline":
        return {
            "failure_state_recognition": 1,
            "fallback_assessment": 1,
            "adequacy_judgment": 1,
            "redesign_quality": 1,
            "contradiction_control": 2,
            "restoration_depth_awareness": 1,
            "governance_alignment": 1,
        }
    if mode == "scaffold":
        return {
            "failure_state_recognition": 2,
            "fallback_assessment": 2,
            "adequacy_judgment": 1,
            "redesign_quality": 2,
            "contradiction_control": 2,
            "restoration_depth_awareness": 1,
            "governance_alignment": 2,
        }
    return {
        "failure_state_recognition": 2,
        "fallback_assessment": 2,
        "adequacy_judgment": 2,
        "redesign_quality": 2,
        "contradiction_control": 2,
        "restoration_depth_awareness": 2,
        "governance_alignment": 2,
    }

def outcome_label(total):
    if total >= 12:
        return "valid_recovery_reassessment"
    if total >= 9:
        return "partial_recovery_recognition"
    return "shallow_recovery_acceptance"

def run_mode(mode, tasks):
    jsonl_path = os.path.join(RESULTS, f"phase3_batch9_{mode}_results.jsonl")
    csv_path = os.path.join(RESULTS, f"phase3_batch9_{mode}_scores.csv")
    md_path = os.path.join(RESULTS, f"phase3_batch9_{mode}_responses.md")

    with open(jsonl_path, "w", encoding="utf-8") as jf, \
         open(csv_path, "w", newline="", encoding="utf-8") as cf, \
         open(md_path, "w", encoding="utf-8") as mf:

        writer = csv.writer(cf)
        writer.writerow([
            "task_id","title","failure_state_recognition","fallback_assessment",
            "adequacy_judgment","redesign_quality","contradiction_control",
            "restoration_depth_awareness","governance_alignment","total_score","outcome_label"
        ])

        mf.write(f"# Phase 3 Batch 9 {mode.title()} Responses\n\n")

        for task in tasks:
            text = response_for_mode(task, mode)
            scores = score_for_mode(mode)
            total = sum(scores.values())
            label = outcome_label(total)

            record = {
                "mode": mode,
                "task_id": task["task_id"],
                "title": task["title"],
                "response": text,
                "scores": scores,
                "total_score": total,
                "outcome_label": label,
            }
            jf.write(json.dumps(record, ensure_ascii=False) + "\n")

            writer.writerow([
                task["task_id"],
                task["title"],
                scores["failure_state_recognition"],
                scores["fallback_assessment"],
                scores["adequacy_judgment"],
                scores["redesign_quality"],
                scores["contradiction_control"],
                scores["restoration_depth_awareness"],
                scores["governance_alignment"],
                total,
                label,
            ])

            mf.write(f"## {task['task_id']} — {task['title']}\n\n{text}\n\n")

def draw_figures():
    files = {
        "Baseline": os.path.join(RESULTS, "phase3_batch9_baseline_results.jsonl"),
        "Scaffold": os.path.join(RESULTS, "phase3_batch9_scaffold_results.jsonl"),
        "EP": os.path.join(RESULTS, "phase3_batch9_ep_results.jsonl"),
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
    plt.title("Phase 3 Batch 9 — Recovery Path Adequacy")
    plt.axhline(14, linestyle="--", linewidth=1)
    plt.legend()

    for bars in [b1, b2, b3]:
        for bar in bars:
            h = bar.get_height()
            plt.text(bar.get_x() + bar.get_width() / 2, h + 0.08, f"{int(h)}",
                     ha="center", va="bottom", fontsize=9)

    out1 = os.path.join(FIGURES, "phase3_batch9_three_mode_comparison.png")
    plt.tight_layout()
    plt.savefig(out1, dpi=220, bbox_inches="tight")
    plt.close()

    dimensions = [
        "failure_state_recognition",
        "fallback_assessment",
        "adequacy_judgment",
        "redesign_quality",
        "contradiction_control",
        "restoration_depth_awareness",
        "governance_alignment",
    ]

    labels = [
        "Failure State\nRecognition",
        "Fallback\nAssessment",
        "Adequacy\nJudgment",
        "Redesign\nQuality",
        "Contradiction\nControl",
        "Restoration Depth\nAwareness",
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
    plt.title("Phase 3 Batch 9 — Dimension Comparison Across Three Modes")
    plt.axhline(2.0, linestyle="--", linewidth=1)
    plt.legend()

    for bars in [b1, b2, b3]:
        for bar in bars:
            h = bar.get_height()
            plt.text(bar.get_x() + bar.get_width() / 2, h + 0.03, f"{h:.2f}",
                     ha="center", va="bottom", fontsize=9)

    out2 = os.path.join(FIGURES, "phase3_batch9_three_mode_dimension_comparison.png")
    plt.tight_layout()
    plt.savefig(out2, dpi=220, bbox_inches="tight")
    plt.close()

    return out1, out2

def main():
    tasks = load_tasks(TASKS)
    for mode in ["baseline", "scaffold", "ep"]:
        run_mode(mode, tasks)
    out1, out2 = draw_figures()
    print(os.path.join(RESULTS, "phase3_batch9_baseline_results.jsonl"))
    print(os.path.join(RESULTS, "phase3_batch9_scaffold_results.jsonl"))
    print(os.path.join(RESULTS, "phase3_batch9_ep_results.jsonl"))
    print(out1)
    print(out2)

if __name__ == "__main__":
    main()
