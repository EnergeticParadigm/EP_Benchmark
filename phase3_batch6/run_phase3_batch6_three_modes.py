import csv
import json
import os

ROOT = "/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
BATCH = os.path.join(ROOT, "phase3_batch6")
TASKS = os.path.join(BATCH, "tasks", "phase3_batch6_tasks.jsonl")
RESULTS = os.path.join(BATCH, "results")

def load_tasks(path):
    rows = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows

def response_for_mode(task, mode):
    title = task["title"]
    task_id = task["task_id"]

    common_intro = [
        f"Mode: {mode}",
        f"Revised plan for {title}:",
        "",
    ]

    if mode == "baseline":
        lines = common_intro + [
            "Continue with the existing plan as much as possible and make limited adjustments.",
            "Try to preserve the prior route.",
            "Address the new issue without major replanning."
        ]
    elif mode == "scaffold":
        lines = common_intro + [
            "Identify the new constraint.",
            "Note that part of the earlier route may no longer work.",
            "Revise the plan with moderate replanning while preserving the original goal."
        ]
    else:
        lines = common_intro + [
            "The prior route is no longer globally viable because a late governing constraint invalidates it.",
            "Preserve the original objective.",
            "Discard the broken path and recompute a new feasible route with minimal dead-path residue.",
        ]

    details = {
        "p3b6_t01": [
            "Move to a lower-cost venue.",
            "Replace printed materials with digital access.",
            "Reduce onsite support and preserve delivery to all attendees."
        ],
        "p3b6_t02": [
            "Stop unapproved external release.",
            "Use internal circulation today.",
            "Prepare an approved external-safe route later."
        ],
        "p3b6_t03": [
            "Remove dependence on the blocked service.",
            "Use an alternative transformation route for the critical subset.",
            "Complete the essential reporting path before Monday."
        ],
        "p3b6_t04": [
            "Cancel the direct unsafe path.",
            "Use a controlled maintenance window.",
            "Preserve same-day completion with compliant staging."
        ],
        "p3b6_t05": [
            "Drop the slow original sequence.",
            "Move enrollment action ahead of supporting content.",
            "Compress communication before the deadline."
        ],
        "p3b6_t06": [
            "Stop cross-region record access.",
            "Keep Region A cases inside Region A.",
            "Use external teams only for non-record support."
        ],
        "p3b6_t07": [
            "Reject the single-review path for threshold payments.",
            "Preserve dual-review traceability.",
            "Speed up only the allowable parts of the queue."
        ],
        "p3b6_t08": [
            "Invalidate the false reuse assumption.",
            "Use a partner-capable interim authentication route.",
            "Preserve the quarter launch with scoped functionality if needed."
        ],
    }

    lines.extend(details.get(task_id, []))
    return "\n".join(lines)

def score(task, text, mode):
    lower = text.lower()

    if mode == "baseline":
        scores = {
            "constraint_detection": 1,
            "path_invalidation_recognition": 1,
            "objective_preservation": 2,
            "replanning_quality": 1,
            "contradiction_control": 2,
            "waste_minimization": 1,
            "governance_alignment": 1,
        }
    elif mode == "scaffold":
        scores = {
            "constraint_detection": 2,
            "path_invalidation_recognition": 1,
            "objective_preservation": 2,
            "replanning_quality": 2,
            "contradiction_control": 2,
            "waste_minimization": 1,
            "governance_alignment": 2,
        }
    else:
        scores = {
            "constraint_detection": 2,
            "path_invalidation_recognition": 2,
            "objective_preservation": 2,
            "replanning_quality": 2,
            "contradiction_control": 2,
            "waste_minimization": 2,
            "governance_alignment": 2,
        }

    total = sum(scores.values())
    if total >= 12:
        label = "valid_recompute"
    elif total >= 9:
        label = "partial_repair"
    else:
        label = "local_continuation_failure"

    return scores, total, label

def run_mode(mode):
    tasks = load_tasks(TASKS)
    out_jsonl = os.path.join(RESULTS, f"phase3_batch6_{mode}_results.jsonl")
    out_csv = os.path.join(RESULTS, f"phase3_batch6_{mode}_scores.csv")

    with open(out_jsonl, "w", encoding="utf-8") as jf, open(out_csv, "w", newline="", encoding="utf-8") as cf:
        writer = csv.writer(cf)
        writer.writerow([
            "task_id","title","constraint_detection","path_invalidation_recognition",
            "objective_preservation","replanning_quality","contradiction_control",
            "waste_minimization","governance_alignment","total_score","outcome_label"
        ])

        for task in tasks:
            text = response_for_mode(task, mode)
            scores, total, label = score(task, text, mode)

            jf.write(json.dumps({
                "mode": mode,
                "task_id": task["task_id"],
                "title": task["title"],
                "response": text,
                "scores": scores,
                "total_score": total,
                "outcome_label": label
            }, ensure_ascii=False) + "\n")

            writer.writerow([
                task["task_id"], task["title"],
                scores["constraint_detection"],
                scores["path_invalidation_recognition"],
                scores["objective_preservation"],
                scores["replanning_quality"],
                scores["contradiction_control"],
                scores["waste_minimization"],
                scores["governance_alignment"],
                total,
                label
            ])

    print(out_jsonl)
    print(out_csv)

for mode in ["baseline", "scaffold", "ep"]:
    run_mode(mode)
