#!/usr/bin/env python3
import csv
import itertools
import json
import math
from collections import defaultdict
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1")
RAW_DIR = BASE / "results" / "raw"
OUT_CSV = BASE / "results" / "scored" / "significance_metrics.csv"
OUT_MD = BASE / "results" / "reports" / "significance_report_v1.md"

MODES = ["baseline", "baseline_scaffold", "ep"]

def load_traces():
    by_task = defaultdict(dict)
    for path in sorted(RAW_DIR.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        by_task[data["task_id"]][data["mode"]] = data
    return by_task

def comb(n: int, k: int) -> int:
    return math.comb(n, k)

def exact_binomial_two_sided(k: int, n: int) -> float:
    if n == 0:
        return 1.0
    probs = [comb(n, i) * (0.5 ** n) for i in range(n + 1)]
    observed = probs[k]
    p = sum(prob for prob in probs if prob <= observed + 1e-15)
    return min(1.0, p)

def wilson_interval(successes: int, n: int, z: float = 1.96):
    if n == 0:
        return (0.0, 1.0)
    phat = successes / n
    denom = 1 + (z * z) / n
    center = (phat + (z * z) / (2 * n)) / denom
    margin = (z / denom) * math.sqrt((phat * (1 - phat) / n) + ((z * z) / (4 * n * n)))
    low = max(0.0, center - margin)
    high = min(1.0, center + margin)
    return (low, high)

def paired_success_table(by_task, mode_a, mode_b):
    a_only = 0
    b_only = 0
    both_success = 0
    both_fail = 0
    shared = 0

    for task_id, modes in by_task.items():
        if mode_a not in modes or mode_b not in modes:
            continue
        shared += 1
        a = bool(modes[mode_a]["success"])
        b = bool(modes[mode_b]["success"])
        if a and not b:
            a_only += 1
        elif b and not a:
            b_only += 1
        elif a and b:
            both_success += 1
        else:
            both_fail += 1

    return {
        "task_count": shared,
        "a_only": a_only,
        "b_only": b_only,
        "both_success": both_success,
        "both_fail": both_fail,
    }

def success_summary(by_task, mode):
    successes = 0
    total = 0
    for task_id, modes in by_task.items():
        if mode not in modes:
            continue
        total += 1
        successes += 1 if bool(modes[mode]["success"]) else 0
    low, high = wilson_interval(successes, total)
    return {
        "mode": mode,
        "successes": successes,
        "total": total,
        "success_rate": successes / total if total else 0.0,
        "ci_low": low,
        "ci_high": high,
    }

def average_metric(by_task, mode, field):
    vals = []
    for task_id, modes in by_task.items():
        if mode in modes:
            vals.append(float(modes[mode].get(field, 0)))
    return sum(vals) / len(vals) if vals else 0.0

def write_csv(rows):
    OUT_CSV.parent.mkdir(parents=True, exist_ok=True)
    with OUT_CSV.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=[
                "comparison",
                "task_count",
                "a_only",
                "b_only",
                "both_success",
                "both_fail",
                "exact_sign_pvalue",
                "effect_direction"
            ]
        )
        writer.writeheader()
        writer.writerows(rows)

def fmt(x):
    return f"{x:.4f}"

def main():
    by_task = load_traces()

    summaries = [success_summary(by_task, mode) for mode in MODES]

    pair_rows = []
    for mode_a, mode_b in itertools.combinations(MODES, 2):
        table = paired_success_table(by_task, mode_a, mode_b)
        discordant = table["a_only"] + table["b_only"]
        smaller = min(table["a_only"], table["b_only"])
        p = exact_binomial_two_sided(smaller, discordant)
        if table["a_only"] > table["b_only"]:
            direction = mode_a
        elif table["b_only"] > table["a_only"]:
            direction = mode_b
        else:
            direction = "tie"
        pair_rows.append({
            "comparison": f"{mode_a} vs {mode_b}",
            "task_count": table["task_count"],
            "a_only": table["a_only"],
            "b_only": table["b_only"],
            "both_success": table["both_success"],
            "both_fail": table["both_fail"],
            "exact_sign_pvalue": round(p, 6),
            "effect_direction": direction
        })

    write_csv(pair_rows)

    avg_runtime = {mode: average_metric(by_task, mode, "runtime_seconds") for mode in MODES}
    avg_steps = {mode: average_metric(by_task, mode, "step_count") for mode in MODES}
    avg_invalid = {mode: average_metric(by_task, mode, "invalid_tool_call_count") for mode in MODES}
    avg_checkpoint = {mode: average_metric(by_task, mode, "checkpoint_count") for mode in MODES}
    avg_rollback = {mode: average_metric(by_task, mode, "rollback_count") for mode in MODES}

    lines = []
    lines.append("# EP Significance Report v1")
    lines.append("")
    lines.append("## Current Statistical Reading")
    lines.append("")
    lines.append("This report applies a paired exact sign-style comparison to the current 9-task smoke test. Because the benchmark is still small, these results should be read as early directional evidence rather than as final statistical proof.")
    lines.append("")
    lines.append("The comparison is paired at the task level. For each pair of modes, the report counts how many tasks are won by one mode and not the other. It then applies an exact two-sided binomial calculation over the discordant task count. This is the simplest robust significance check for the current benchmark shape.")
    lines.append("")
    lines.append("The current smoke test is also highly deterministic. That means the main value of this report is not to produce a dramatic p-value claim. Its real value is to show whether the observed ordering baseline < baseline_scaffold < ep is directionally consistent and whether the current sample is already large enough to support a strong inferential claim. At this stage, the answer is that the direction is visible, but the sample is still too small for a strong significance claim.")
    lines.append("")
    lines.append("## Success Intervals")
    lines.append("")
    for s in summaries:
        lines.append(
            f"{s['mode']} completed {s['successes']} of {s['total']} tasks, for a success rate of {fmt(s['success_rate'])}. "
            f"The Wilson 95% interval is [{fmt(s['ci_low'])}, {fmt(s['ci_high'])}]."
        )
        lines.append("")
    lines.append("These intervals are still wide because the smoke test contains only nine tasks. Even so, they already help frame the result correctly. EP is currently at full completion in this run, while baseline and baseline_scaffold remain below that level. The overlap issue is exactly why the next step should be a larger task pack rather than overclaiming from a tiny benchmark.")
    lines.append("")
    lines.append("A small benchmark can still be valuable, but its main role is engineering validation. It shows that the benchmark framework works, that mode separation is real, and that the task design is sensitive enough to reflect structural execution differences. It does not yet provide the statistical density needed for a strong external claim.")
    lines.append("")
    lines.append("## Paired Comparisons")
    lines.append("")
    for row in pair_rows:
        lines.append(
            f"For {row['comparison']}, the paired task count is {row['task_count']}. "
            f"The first mode wins alone on {row['a_only']} tasks, the second mode wins alone on {row['b_only']} tasks, "
            f"both succeed on {row['both_success']} tasks, and both fail on {row['both_fail']} tasks. "
            f"The exact paired two-sided p-value is {row['exact_sign_pvalue']:.6f}. "
            f"The observed directional advantage currently favors {row['effect_direction']}."
        )
        lines.append("")
    lines.append("These paired results should be interpreted cautiously. With only nine tasks, even a clean directional advantage may not yet cross a conventional significance threshold. That does not mean the effect is unimportant. It means the benchmark has not yet accumulated enough task mass for inferential confidence to match the engineering intuition.")
    lines.append("")
    lines.append("The key observation remains practical. The current smoke test already shows structural divergence in rerouting, checkpointing, rollback accounting, and invalid tool behavior. Statistical testing is therefore not replacing the benchmark result; it is contextualizing it. Right now the context is simple: the direction is promising, but the benchmark is still too small to support a strong p-value style claim.")
    lines.append("")
    lines.append("## Structural Metrics")
    lines.append("")
    lines.append(
        f"Average runtime is {fmt(avg_runtime['baseline'])} for baseline, {fmt(avg_runtime['baseline_scaffold'])} for baseline_scaffold, "
        f"and {fmt(avg_runtime['ep'])} for ep. Average steps are {fmt(avg_steps['baseline'])}, {fmt(avg_steps['baseline_scaffold'])}, "
        f"and {fmt(avg_steps['ep'])} respectively."
    )
    lines.append("")
    lines.append(
        f"Average invalid tool calls are {fmt(avg_invalid['baseline'])} for baseline, {fmt(avg_invalid['baseline_scaffold'])} for baseline_scaffold, "
        f"and {fmt(avg_invalid['ep'])} for ep. Average checkpoint counts are {fmt(avg_checkpoint['baseline'])}, "
        f"{fmt(avg_checkpoint['baseline_scaffold'])}, and {fmt(avg_checkpoint['ep'])}. Average rollback counts are "
        f"{fmt(avg_rollback['baseline'])}, {fmt(avg_rollback['baseline_scaffold'])}, and {fmt(avg_rollback['ep'])}."
    )
    lines.append("")
    lines.append("These structural metrics are crucial because they are the main reason EP should not be judged only by raw task completion. Even when success-rate gaps remain modest, checkpoint count, rollback count, and invalid tool behavior may reveal a deeper difference in execution quality. That is already visible in the current smoke test, especially on TOOL_006 and TOOL_013.")
    lines.append("")
    lines.append("As the benchmark expands, these structural metrics should become part of the formal evaluation story rather than staying as secondary notes. In many deployment settings, controlled recovery, explicit checkpointing, and reduced invalid action paths are at least as important as raw task completion. The benchmark is already well-positioned to capture that.")
    lines.append("")
    lines.append("## Recommended Next Step")
    lines.append("")
    lines.append("The correct next move is not to chase a better p-value from the same 9-task smoke test. The correct next move is to expand the benchmark to roughly 30 to 50 tasks while preserving the current paired trace structure. Once that larger task set exists, the same significance script can be rerun and the inferential meaning of the result will become much stronger.")
    lines.append("")
    lines.append("At the same time, more tasks should receive explicit mode splitting of the kind already introduced in TOOL_006 and TOOL_013. That will increase the benchmark’s sensitivity to the exact structural properties that EP is supposed to improve. Larger sample size and sharper mode separation should move together.")
    lines.append("")
    lines.append("For now, the honest conclusion is straightforward. The benchmark already shows directional evidence in favor of EP, but this smoke test remains too small for a strong statistical claim. The next phase should be expansion, not overstatement.")
    lines.append("")

    OUT_MD.parent.mkdir(parents=True, exist_ok=True)
    OUT_MD.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {OUT_CSV}")
    print(f"Wrote {OUT_MD}")

if __name__ == "__main__":
    main()
