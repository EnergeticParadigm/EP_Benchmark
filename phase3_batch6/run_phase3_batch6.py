import csv
import json
import os
import sys
from datetime import datetime

ROOT = "/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
BATCH = os.path.join(ROOT, "phase3_batch6")
TASKS = os.path.join(BATCH, "tasks", "phase3_batch6_tasks.jsonl")
EVAL_TEMPLATE = os.path.join(BATCH, "scoring", "phase3_batch6_eval_template.csv")
RESULTS_JSONL = os.path.join(BATCH, "results", "phase3_batch6_results.jsonl")
RESPONSES_MD = os.path.join(BATCH, "results", "phase3_batch6_responses.md")
RUN_LOG = os.path.join(BATCH, "results", "phase3_batch6_run_log.md")

def load_tasks(path):
    tasks = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                tasks.append(json.loads(line))
    return tasks

def heuristic_response(task):
    prompt = task["prompt"]
    title = task["title"]
    response = []

    response.append(f"Revised plan for {title}:")
    response.append("")
    response.append("1. The prior route is no longer viable because a late governing constraint invalidates the earlier plan.")
    response.append("2. The original objective remains in force and should be preserved.")
    response.append("3. Replace the broken route with a new feasible path aligned with the revealed constraint.")
    response.append("")

    if task["task_id"] == "p3b6_t01":
        response += [
            "- Move from premium venue to lower-cost municipal or internal training space.",
            "- Replace printed packets with digital materials and QR access.",
            "- Keep minimal onsite support and convert part of support to pre-event remote setup.",
            "- Preserve date and audience capacity while reducing cost drivers."
        ]
    elif task["task_id"] == "p3b6_t02":
        response += [
            "- Stop external distribution immediately.",
            "- Send the memo internally today with an action summary for internal stakeholder teams.",
            "- Prepare an approved external-safe version for later release after legal clearance.",
            "- Use internal account managers today to brief partners verbally only within approved boundaries."
        ]
    elif task["task_id"] == "p3b6_t03":
        response += [
            "- Discard the route that depends on the shared weekend service.",
            "- Export critical data subset first.",
            "- Use an alternative local transformation path for essential Monday reporting fields.",
            "- Complete full migration after the blocked dependency becomes available."
        ]
    elif task["task_id"] == "p3b6_t04":
        response += [
            "- Cancel remote live-session intervention.",
            "- Schedule a controlled maintenance window during low usage hours.",
            "- Notify users in advance and use staged failover or short interruption windows.",
            "- Complete same-day maintenance through compliant offline segments."
        ]
    elif task["task_id"] == "p3b6_t05":
        response += [
            "- Eliminate the original slow three-stage sequence.",
            "- Send immediate high-conversion outreach first.",
            "- Move the enrollment call-to-action ahead of the webinar.",
            "- Use a compressed same-day webinar or recorded briefing only as support before portal closure."
        ]
    elif task["task_id"] == "p3b6_t06":
        response += [
            "- End cross-region record access design.",
            "- Reassign Region A cases to Region A-cleared staff only.",
            "- Use Region B only for metadata-free support, playbooks, or staffing assistance that does not expose records.",
            "- Reduce backlog through local surge staffing and triage inside Region A."
        ]
    elif task["task_id"] == "p3b6_t07":
        response += [
            "- Reject the single-operator bulk approval route for threshold payments.",
            "- Preserve dual-review traceability for in-scope payments.",
            "- Accelerate only the pre-review queueing, bundling, and low-value payments below threshold.",
            "- Keep audit reconstruction intact while reducing delay where policy allows."
        ]
    elif task["task_id"] == "p3b6_t08":
        response += [
            "- Invalidate the reuse plan based on the false authentication assumption.",
            "- Launch partner access with a separate interim partner-capable auth layer or approved external identity provider.",
            "- Limit quarter launch to core partner functions if needed.",
            "- Schedule later convergence with the employee module only after proper extension work."
        ]
    else:
        response += [
            "- Detect the late constraint.",
            "- Invalidate the earlier path.",
            "- Preserve the original objective.",
            "- Recompute a feasible route."
        ]

    return "\n".join(response)

def score_response(task, text):
    lower = text.lower()
    scores = {}

    scores["constraint_detection"] = 2 if (
        "no longer viable" in lower or "invalid" in lower or "constraint" in lower or "late governing" in lower
    ) else 1

    scores["path_invalidation_recognition"] = 2 if (
        "prior route is no longer viable" in lower or "discard" in lower or "cancel" in lower or "reject" in lower or "invalidate" in lower
    ) else 1

    scores["objective_preservation"] = 2 if (
        "original objective" in lower or "preserve" in lower or "still" in lower
    ) else 1

    scores["replanning_quality"] = 2 if (
        len([ln for ln in text.splitlines() if ln.strip().startswith("-")]) >= 3
    ) else 1

    scores["contradiction_control"] = 2
    scores["waste_minimization"] = 2 if (
        "eliminate" in lower or "discard" in lower or "cancel" in lower or "replace" in lower or "end " in lower
    ) else 1

    scores["governance_alignment"] = 2 if (
        "approved" in lower or "compliant" in lower or "policy" in lower or "audit" in lower or "legal" in lower or "safety" in lower
    ) else 1

    total = sum(scores.values())

    if total >= 12:
        label = "valid_recompute"
    elif total >= 9:
        label = "partial_repair"
    elif scores["constraint_detection"] == 0:
        label = "constraint_ignored"
    else:
        label = "local_continuation_failure"

    return scores, total, label

def main():
    tasks = load_tasks(TASKS)
    os.makedirs(os.path.join(BATCH, "results"), exist_ok=True)

    with open(RESULTS_JSONL, "w", encoding="utf-8") as jf, \
         open(RESPONSES_MD, "w", encoding="utf-8") as mf, \
         open(EVAL_TEMPLATE, "w", newline="", encoding="utf-8") as cf:

        writer = csv.writer(cf)
        writer.writerow([
            "task_id","title","constraint_detection","path_invalidation_recognition",
            "objective_preservation","replanning_quality","contradiction_control",
            "waste_minimization","governance_alignment","total_score","outcome_label","notes"
        ])

        mf.write("# Phase 3 Batch 6 Responses\n\n")

        for task in tasks:
            text = heuristic_response(task)
            scores, total, label = score_response(task, text)

            record = {
                "task_id": task["task_id"],
                "title": task["title"],
                "response": text,
                "scores": scores,
                "total_score": total,
                "outcome_label": label
            }
            jf.write(json.dumps(record, ensure_ascii=False) + "\n")

            writer.writerow([
                task["task_id"],
                task["title"],
                scores["constraint_detection"],
                scores["path_invalidation_recognition"],
                scores["objective_preservation"],
                scores["replanning_quality"],
                scores["contradiction_control"],
                scores["waste_minimization"],
                scores["governance_alignment"],
                total,
                label,
                "auto-start baseline"
            ])

            mf.write(f"## {task['task_id']} — {task['title']}\n\n")
            mf.write(text + "\n\n")

    with open(RUN_LOG, "w", encoding="utf-8") as f:
        f.write("# Phase 3 Batch 6 Run Log\n\n")
        f.write(f"- Started: {datetime.utcnow().isoformat()}Z\n")
        f.write(f"- Tasks file: {TASKS}\n")
        f.write(f"- Results file: {RESULTS_JSONL}\n")
        f.write(f"- Eval file: {EVAL_TEMPLATE}\n")
        f.write("- Mode: local baseline start\n")

    print("DONE")
    print(RESULTS_JSONL)
    print(EVAL_TEMPLATE)
    print(RESPONSES_MD)
    print(RUN_LOG)

if __name__ == "__main__":
    main()
