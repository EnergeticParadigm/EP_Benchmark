# Phase 3 Batch 6 Result Report

Phase 3 Batch 6 tests one specific capability: when a decisive constraint appears late, can the system recognize that the old route is no longer viable, discard it, and rebuild a new route while still preserving the original objective.

The restored Batch 6 files do not contain empirical model runs. They contain synthetic design-validation results. So the only valid claim here is about benchmark design: whether this batch can separate three different reasoning styles in principle.

In that synthetic setup, the score per task is out of 14. A score of 14 does not mean general quality. It means the route was handled correctly on all seven Batch 6 criteria. A score of 12 means the route was partly repaired but still retained structural weakness. A score of 9 means the system kept moving toward the goal but failed to properly re-govern the path after the late constraint appeared.

## What the three scores mean

A score of 9 means the system notices that something changed, but still tries to preserve too much of the old plan. It adjusts locally rather than rebuilding globally. The final answer may still sound reasonable, but structurally it is weak, because the earlier route should already have been treated as broken.

A score of 12 means the system does recognize the new constraint and does some real replanning, but it does not fully sever itself from the dead path. Some residue of the original broken route remains. This is better than ordinary continuation, but still short of full recomputation.

A score of 14 means the system clearly states that the previous route is no longer viable, preserves the governing objective, and constructs a fresh feasible route aligned with the late constraint. Nothing essential from the broken path is dragged forward.

So the real meaning of the synthetic Batch 6 result is this:

- Baseline corresponds to local continuation.
- Scaffold corresponds to partial recomputation.
- EP corresponds to full recomputation.

## Why Batch 6 matters

This batch is not testing ordinary instruction following. It is testing whether a system can respond correctly when a late reveal changes global feasibility.

That distinction matters because many weak systems can still sound competent after a late constraint appears. They do not stop and rebuild. They simply patch. Batch 6 is designed to expose exactly that difference.

Under the synthetic scoring design, Baseline fails because it treats the earlier route as something to preserve. Scaffold improves because it treats the earlier route as something to revise. EP succeeds because it treats the earlier route as something to invalidate and replace.

That is the actual conclusion of the restored report: Phase 3 Batch 6 successfully separates three modes of reasoning about late constraint collapse.

## What it does not show

This report does not show measured model performance. It does not prove that a real baseline system will score 9, a real scaffold system will score 12, or a real EP system will score 14. It only shows that the benchmark, as designed, is capable of expressing those distinctions cleanly.

## Final conclusion

Phase 3 Batch 6 is a valid EP-sensitive benchmark family because it isolates one core difference:

- whether a system continues the old path,
- whether it partially repairs the old path,
- or whether it discards the broken path and recomputes from the governing condition.

That is the real content of the current Batch 6 report.
