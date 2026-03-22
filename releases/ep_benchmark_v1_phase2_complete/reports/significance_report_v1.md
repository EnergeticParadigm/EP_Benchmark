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
