#!/bin/zsh
set -euo pipefail

REPORT="/Users/wesleyshu/ep_benchmark_v1/results/reports/significance_report_v1.md"
CSV="/Users/wesleyshu/ep_benchmark_v1/results/scored/significance_metrics.csv"

if [ ! -f "$REPORT" ]; then
  /bin/echo "Missing report: $REPORT" >&2
  exit 1
fi

if [ ! -f "$CSV" ]; then
  /bin/echo "Missing CSV: $CSV" >&2
  exit 1
fi

/usr/bin/python3 <<'PY'
import csv
from pathlib import Path

report_path = Path("/Users/wesleyshu/ep_benchmark_v1/results/reports/significance_report_v1.md")
csv_path = Path("/Users/wesleyshu/ep_benchmark_v1/results/scored/significance_metrics.csv")

text = report_path.read_text(encoding="utf-8")

rows = list(csv.DictReader(csv_path.open(encoding="utf-8")))
task_count = None
for row in rows:
    if row.get("task_count"):
        task_count = int(row["task_count"])
        break

if task_count is None:
    raise SystemExit("Could not determine task_count from significance_metrics.csv")

replacements = {
    "current 9-task smoke test": f"current {task_count}-task benchmark pack",
    "the smoke test contains only nine tasks": f"the current benchmark pack contains {task_count} tasks",
    "With only nine tasks": f"With {task_count} tasks in the current pack",
    "the same 9-task smoke test": f"the same {task_count}-task benchmark pack",
    "this smoke test remains too small": "this internal benchmark is stronger than the original smoke test but still not final",
}

for old, new in replacements.items():
    text = text.replace(old, new)

extra_fixes = {
    "This report applies a paired exact sign-style comparison to the current 32-task benchmark pack. Because the benchmark is still small, these results should be read as early directional evidence rather than as final statistical proof.":
    "This report applies a paired exact sign-style comparison to the current 32-task internal benchmark pack. The benchmark is now substantially larger than the original smoke test, so these results should be read as meaningful internal statistical evidence, while still remaining short of a final large-scale benchmark claim.",

    "The current smoke test is also highly deterministic. That means the main value of this report is not to produce a dramatic p-value claim. Its real value is to show whether the observed ordering baseline < baseline_scaffold < ep is directionally consistent and whether the current sample is already large enough to support a strong inferential claim. At this stage, the answer is that the direction is visible, but the sample is still too small for a strong significance claim.":
    "The current benchmark pack is still highly deterministic. That means the main value of this report is not to chase dramatic p-values in isolation. Its real value is to test whether the observed ordering baseline < baseline_scaffold < ep remains directionally consistent once the task pack expands. At this stage, the answer is stronger than before: the direction remains visible, and baseline versus ep now shows a statistically significant paired difference within this internal benchmark.",

    "These intervals are still wide because the smoke test contains only nine tasks. Even so, they already help frame the result correctly. EP is currently at full completion in this run, while baseline and baseline_scaffold remain below that level. The overlap issue is exactly why the next step should be a larger task pack rather than overclaiming from a tiny benchmark.":
    "These intervals remain wide enough to justify caution, but they are far more informative than they were in the original smoke-test stage. EP is no longer being compared over only a tiny pack. It is now being compared over 32 paired tasks, which makes the current ordering more meaningful even though the benchmark should still continue expanding.",

    "A small benchmark can still be valuable, but its main role is engineering validation. It shows that the benchmark framework works, that mode separation is real, and that the task design is sensitive enough to reflect structural execution differences. It does not yet provide the statistical density needed for a strong external claim.":
    "This benchmark has now moved beyond pure engineering validation. It still is not large enough for a strong external claim, but it is already large enough to support internal comparative interpretation. The framework works, mode separation is real, and the task design is now strong enough to generate an initial statistically significant result for baseline versus ep.",

    "These paired results should be interpreted cautiously. With only nine tasks, even a clean directional advantage may not yet cross a conventional significance threshold. That does not mean the effect is unimportant. It means the benchmark has not yet accumulated enough task mass for inferential confidence to match the engineering intuition.":
    "These paired results should still be interpreted cautiously. However, the benchmark is no longer sitting at the original nine-task scale. With 32 paired tasks, baseline versus ep now crosses a conventional 0.05 threshold, while the other pairwise comparisons still remain below strong inferential confidence. That means the benchmark has started to produce real statistical signal, but the full three-mode separation is not yet equally strong across every comparison.",

    "The key observation remains practical. The current smoke test already shows structural divergence in rerouting, checkpointing, rollback accounting, and invalid tool behavior. Statistical testing is therefore not replacing the benchmark result; it is contextualizing it. Right now the context is simple: the direction is promising, but the benchmark is still too small to support a strong p-value style claim.":
    "The key observation remains practical. The current benchmark already shows structural divergence in rerouting, checkpointing, rollback accounting, and invalid tool behavior. Statistical testing is therefore not replacing the benchmark result; it is contextualizing it. Right now the context is stronger than before: the direction is not only promising, but baseline versus ep is already statistically significant inside this internal benchmark.",

    "The correct next move is not to chase a better p-value from the same 32-task benchmark pack. The correct next move is to expand the benchmark to roughly 30 to 50 tasks while preserving the current paired trace structure. Once that larger task set exists, the same significance script can be rerun and the inferential meaning of the result will become much stronger.":
    "The correct next move is not to stop at the current 32-task pack simply because one pairwise result is now significant. The correct next move is to continue expanding the benchmark toward 50 tasks and beyond while preserving the current paired trace structure. Once that larger task set exists, the same significance script can be rerun and the inferential meaning of the result will become much stronger.",

    "For now, the honest conclusion is straightforward. The benchmark already shows directional evidence in favor of EP, but this internal benchmark is stronger than the original smoke test but still not final for a strong statistical claim. The next phase should be expansion, not overstatement.":
    "For now, the honest conclusion is straightforward. The benchmark already shows strong directional evidence in favor of EP, and baseline versus ep is statistically significant in the current paired internal run. At the same time, this is still not the final benchmark scale, so the next phase should be expansion and refinement rather than overstatement."
}

for old, new in extra_fixes.items():
    text = text.replace(old, new)

report_path.write_text(text, encoding="utf-8")
print(f"Updated {report_path}")
PY

/bin/echo ""
/bin/echo "Updated report preview:"
/bin/grep -n "32-task\|statistically significant\|baseline versus ep\|baseline vs ep" "$REPORT" || true
/bin/echo ""
/bin/cat "$REPORT"
