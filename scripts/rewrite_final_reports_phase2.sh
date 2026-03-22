#!/bin/zsh
set -euo pipefail

REPORT1="/Users/wesleyshu/ep_benchmark_v1/results/reports/significance_report_v1.md"
REPORT2="/Users/wesleyshu/ep_benchmark_v1/results/reports/EP_benchmark_phase2_report_v1.md"

cat > "$REPORT1" <<'EOT'
# EP Significance Report v1

## Current Statistical Reading

This report applies a paired exact sign-style comparison to the current fully executed 32-task internal benchmark. The benchmark is no longer a small smoke test. All 32 tasks are now executed, which means the paired comparisons can be read as meaningful internal statistical evidence rather than as only directional engineering hints.

The comparison is paired at the task level. For each pair of modes, the report counts how many tasks are won by one mode and not the other. It then applies an exact two-sided binomial calculation over the discordant task count. This provides a clean way to test whether the observed separation between modes is large enough to matter under the current benchmark design.

The benchmark remains highly deterministic, so the purpose of this report is not to imitate a noisy public leaderboard setting. Its purpose is to measure whether structured execution differences remain visible once the task pack is fully executed. At the current 32-task scale, the answer is clear. The ordering baseline < baseline_scaffold < ep remains stable, and the separation between baseline and the other two modes is now statistically strong inside this internal benchmark.

## Success Intervals

baseline completed 14 of 32 tasks, for a success rate of 0.4375. The Wilson 95% interval is [0.2817, 0.6067].

baseline_scaffold completed 28 of 32 tasks, for a success rate of 0.8750. The Wilson 95% interval is [0.7193, 0.9503].

ep completed 31 of 32 tasks, for a success rate of 0.9688. The Wilson 95% interval is [0.8426, 0.9945].

These intervals still justify normal scientific caution, but they are now being computed over a fully executed 32-task benchmark rather than over a small exploratory pack. EP is near-complete in the current run, baseline_scaffold is clearly strong, and baseline remains far below both. The intervals therefore support the same practical reading as the raw success rates: the benchmark is no longer merely suggestive. It is now internally persuasive.

The benchmark is still internal and deterministic, so these intervals should not be overextended into claims about all future settings. But within the scope of this benchmark, they show that the present ordering is not a trivial artifact of a handful of tasks. The benchmark now has enough density to support a more confident comparative interpretation.

## Paired Comparisons

For baseline vs baseline_scaffold, the paired task count is 32. The first mode wins alone on 0 tasks, the second mode wins alone on 14 tasks, both succeed on 14 tasks, and both fail on 4 tasks. The exact paired two-sided p-value is 0.000122. The observed directional advantage currently favors baseline_scaffold.

For baseline vs ep, the paired task count is 32. The first mode wins alone on 0 tasks, the second mode wins alone on 17 tasks, both succeed on 14 tasks, and both fail on 1 tasks. The exact paired two-sided p-value is 0.000015. The observed directional advantage currently favors ep.

For baseline_scaffold vs ep, the paired task count is 32. The first mode wins alone on 0 tasks, the second mode wins alone on 3 tasks, both succeed on 28 tasks, and both fail on 1 tasks. The exact paired two-sided p-value is 0.250000. The observed directional advantage currently favors ep.

These paired comparisons are now the most important statistical result in the benchmark. Baseline is strongly separated from baseline_scaffold. Baseline is even more strongly separated from ep. The only comparison that does not yet reach conventional significance is baseline_scaffold versus ep. That result should not be hidden. It is an important part of the benchmark story, because it shows that the scaffolded middle mode already captures a substantial amount of execution improvement, while EP still remains the strongest mode overall.

The correct reading is therefore precise. The benchmark now strongly supports that both structured_baseline behavior and EP behavior outperform raw baseline. It also supports that EP is best in absolute terms. What it does not yet support statistically is a strong claim that ep is cleanly separated from baseline_scaffold under the current 32-task pack. That gap may narrow or widen in future expansions, but in the present benchmark it remains directionally favorable to EP without yet becoming statistically decisive.

## Structural Metrics

Average runtime is 0.0460 for baseline, 0.0525 for baseline_scaffold, and 0.0464 for ep. Average steps are 2.0000, 2.5000, and 2.5000 respectively.

Average invalid tool calls are 0.1875 for baseline, 0.0938 for baseline_scaffold, and 0.0000 for ep. Average checkpoint counts are 0.0000, 0.0000, and 0.2500. Average rollback counts are 0.0312, 0.1250, and 0.2500.

These structural metrics are central to the meaning of the benchmark. EP is not merely the mode with the highest success rate. It is also the mode with the cleanest execution profile. It eliminates invalid tool behavior entirely in the current run, and it shows the highest rates of checkpointing and rollback-aware recovery. That is exactly the kind of evidence this benchmark was built to capture.

The scaffolded middle mode also matters. It cuts invalid tool behavior relative to baseline and materially improves success rate. That confirms that extra procedure already helps. EP then adds a further governance-oriented layer on top of that procedural improvement. The statistics and the structural metrics therefore tell the same story from different angles.

## Recommended Next Step

The benchmark no longer needs to prove that it is real. That stage is over. The immediate next move is to formalize the present result through clean reporting and mode-definition clarity.

The significance report should now be read together with the Phase 2 benchmark report, because the statistical reading is strongest when placed beside the task-family structure, execution coverage, and governance metrics. The main takeaway is already stable: under the current fully executed 32-task internal benchmark, baseline is strongly outperformed by both baseline_scaffold and ep, and ep remains the strongest overall mode.

The next benchmark expansion, if pursued, should not be described as basic benchmark activation. It should be described as refinement. That refinement should focus on creating more tasks that specifically distinguish baseline_scaffold from ep, especially in governance-sensitive settings where procedural structure alone may be insufficient.

## Conclusion

Under the current fully executed 32-task internal benchmark, EP achieves a success rate of 0.9688, compared with 0.8750 for baseline_scaffold and 0.4375 for baseline. Baseline_scaffold strongly outperforms baseline with a paired exact p-value of 0.000122. EP even more strongly outperforms baseline with a paired exact p-value of 0.000015.

At the same time, EP maintains the strongest governance-oriented execution profile in the benchmark: zero invalid tool calls, the highest checkpoint rate, and the highest rollback rate. The benchmark therefore supports a clear internal conclusion. EP is not only the strongest mode by completion. It is also the strongest mode by governed execution structure.
EOT

cat > "$REPORT2" <<'EOT'
# EP Benchmark Phase 2 Report v1

## Benchmark Scope

This report summarizes the completed Phase 2 state of the EP internal benchmark. The benchmark now contains a fully executed 32-task internal pack and compares three modes over the same task set: baseline, baseline_scaffold, and ep. Unlike the original smoke-test phase, this benchmark is no longer a partial or exploratory construction. Every task in the current pack is executed, scored, and included in the final comparison.

The benchmark spans three task families. The terminal family measures exact extraction, log reading, file inspection, structured counting, and recovery from stale branches. The tool_routing family measures tool ordering, rerouting, rejection of unsafe shortcuts, checkpoint-sensitive execution, escalation logic, and recomputation after route change. The swe family measures controlled source repair, semantic consistency, delegation to existing helpers, rollback from wrong patches, and edge-case correctness. This breadth matters because it makes the benchmark a comparative execution system rather than a narrow demo.

The benchmark is still internal, deterministic, and intentionally structured. It is not being presented as a public leaderboard substitute. But it is now large enough and complete enough to function as serious internal evidence. Phase 2 should therefore be understood as the first full benchmark phase, not as a warm-up.

## Mode Definitions

The benchmark uses three modes for a reason. Baseline is raw execution with minimal structure. It attempts to solve the task directly without special control logic. Baseline_scaffold is a structured baseline. It adds extra procedure such as better step ordering, cleaner decomposition, and simple rerouting, but it does not add EP-style governance logic. EP is governed execution. It includes procedural structure, but it also adds checkpoint-sensitive behavior, rollback-aware recovery, and stronger route control in governance-relevant tasks.

This distinction is important because baseline_scaffold is not half-functional EP. It is not partial EP. It is a non-EP procedural control condition designed to isolate the value of generic structure. That allows the benchmark to distinguish three questions. Can plain execution work at all. Does extra organization already help. Does governance-aware execution help even more.

The current results show that these three modes are meaningfully different. Baseline is weakest, baseline_scaffold is much stronger, and ep is strongest overall. That is exactly the separation the benchmark was designed to test.

## Current Results

The current success rates are clear. Baseline completes 14 of 32 tasks, for a success rate of 0.4375. Baseline_scaffold completes 28 of 32 tasks, for a success rate of 0.8750. EP completes 31 of 32 tasks, for a success rate of 0.9688. The ordering is therefore stable and emphatic: baseline < baseline_scaffold < ep.

These numbers are especially important because they are now based on the full task pack rather than on a partially executed benchmark. There are no remaining incomplete_execution placeholders. That means the benchmark no longer carries unresolved coverage debt. The result is a full comparative run, not an interim estimate.

The failure taxonomy reinforces the same conclusion. Baseline records six wrong_route failures, six wrong_tool failures, and six final_answer_wrong failures. Baseline_scaffold records no wrong_route failures, three wrong_tool failures, and only one final_answer_wrong result. EP records no wrong_route failures, no wrong_tool failures, and only one final_answer_wrong result. The pattern is not random. It reflects progressively stronger execution discipline as the mode becomes more structured and more governed.

## Statistical Reading

The paired comparisons are now strong enough to support a clear internal statistical claim. Baseline versus baseline_scaffold yields a paired exact two-sided p-value of 0.000122. Baseline versus ep yields a paired exact two-sided p-value of 0.000015. Baseline_scaffold versus ep yields a p-value of 0.250000.

This means two things with confidence. First, structured baseline behavior strongly outperforms raw baseline under the current benchmark. Second, EP even more strongly outperforms raw baseline under the same benchmark. These are no longer weak directional hints. They are strong statistical separations within the current paired internal design.

At the same time, the benchmark also says something more subtle. Baseline_scaffold versus ep remains directionally favorable to EP, but the difference is not statistically significant in the current 32-task pack. That is an important result, not a weakness to hide. It shows that structured procedure already captures a substantial part of the improvement over raw baseline, while EP remains the strongest absolute mode and the strongest governance-oriented mode.

## Structural Governance Profile

The benchmark was never intended to be judged by correctness alone. That is why the structural metrics matter. Average invalid tool rate is 0.1875 for baseline, 0.0938 for baseline_scaffold, and 0.0000 for ep. Average checkpoint rate is 0.0000 for baseline, 0.0000 for baseline_scaffold, and 0.2500 for ep. Average rollback rate is 0.0312 for baseline, 0.1250 for baseline_scaffold, and 0.2500 for ep.

This is the strongest internal evidence that EP is not merely another answer-generation mode. It is the mode with the cleanest governed execution profile. It reaches the highest completion rate while also eliminating invalid tool behavior entirely and showing the strongest checkpoint and rollback pattern.

The scaffolded middle mode again serves an important interpretive role. It reduces invalid tool behavior and sharply increases success relative to baseline. That confirms that extra procedure matters. EP then adds a further layer of governance-sensitive execution. The benchmark therefore distinguishes the value of organization from the value of governance, and the present data support both.

## Interpretation

Phase 2 shows that the benchmark has moved beyond proof of concept. The framework is complete, the task pack is fully executed, the three modes separate meaningfully, and the benchmark now produces strong internal statistical evidence rather than only engineering impressions. This is a substantial change from the earlier smoke-test stage.

The core interpretation is straightforward. Baseline is inadequate for this benchmark. Raw execution without additional structure produces too many wrong routes, wrong tools, and final failures. Baseline_scaffold is a major improvement. Extra procedure alone dramatically improves the result. EP is best overall, because it combines procedural strength with the strongest governance-oriented execution profile.

The benchmark therefore supports a very specific internal claim. EP is not only the best mode by completion. It is also the mode that best preserves disciplined execution under pressure, especially in tasks involving rerouting, checkpoint-sensitive action, and rollback-aware recovery.

## Limits

This benchmark is fully executed, but it is still internal. The tasks are deterministic and intentionally controlled. The purpose of the benchmark is to compare execution structures under a consistent internal design, not to simulate every possible public benchmark condition. That scope should remain explicit.

The second limitation is interpretive. Because baseline_scaffold and ep are not statistically separated in the current pack, the benchmark does not yet support a strong claim that EP is decisively beyond scaffolded execution in every measurable sense. It does support that EP is strongest overall and strongest in governance profile. It does not yet support a strong inferential separation between those two structured modes.

The third limitation is naming clarity. The label baseline_scaffold can easily be misunderstood as partial EP. It is not. It is a structured baseline. Future documents may benefit from renaming it to structured_baseline so the comparison becomes conceptually cleaner.

## Final Conclusion

Under the current fully executed 32-task internal benchmark, baseline achieves a success rate of 0.4375, baseline_scaffold achieves 0.8750, and ep achieves 0.9688. Baseline_scaffold strongly outperforms baseline with a paired exact p-value of 0.000122. EP strongly outperforms baseline with a paired exact p-value of 0.000015.

EP also maintains the strongest governance-oriented execution profile in the benchmark: zero invalid tool calls, the highest checkpoint rate, and the highest rollback rate. The completed Phase 2 benchmark therefore supports a clear internal conclusion. Raw execution is insufficient. Structured execution is much better. Governed execution is best.

The benchmark is now in a state where reporting should catch up with execution. The significance report and the formal Phase 2 report are now aligned with the completed 32-task benchmark. That alignment matters because the benchmark has crossed the threshold from construction to evidence.
EOT

echo "Wrote $REPORT1"
echo "Wrote $REPORT2"
echo
cat "$REPORT1"
echo
cat "$REPORT2"
