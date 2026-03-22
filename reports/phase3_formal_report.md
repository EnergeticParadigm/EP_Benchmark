# Phase 3 Formal Report

## Included Batches

- [AMBIG_001 Batch](#ambig_001-batch)

## AMBIG_001 Batch

## 1. Purpose

This Phase 3 batch was designed to test a narrower and more discriminative question than the earlier benchmark phases. The goal was not merely to show that a plain baseline fails. The goal was to determine whether a scaffolded baseline can match EP on tasks where the system must distinguish between superficially richer branches and the branch that actually preserves the governing condition.

The benchmark therefore targeted branch ambiguity. In these tasks, the incorrect branch is not obviously absurd. It is often longer, more detailed, or more locally plausible. A weak model tends to follow it. A scaffolded model may inspect more than one branch, but still fail to preserve the governing condition at the point of final selection. EP is expected to succeed because it changes the routing logic itself rather than only adding extra procedural depth.

## 2. Test Set

This report covers three Phase 3 tasks:

- `SWE_AMBIG_001`
- `TERM_AMBIG_001`
- `TOOL_AMBIG_001`

Each task was evaluated under three modes:

- `baseline`
- `baseline_scaffold`
- `ep`

This produced nine raw result files in total.

## 3. Core Result

The result pattern is fully separated across all three tasks:

- baseline: `0 / 3`
- baseline_scaffold: `0 / 3`
- ep: `3 / 3`

This is the clearest outcome that Phase 3 was meant to produce. The scaffolded baseline did not close the gap. It added steps, checkpoints, and route changes in some cases, but it still failed to preserve the correct governing condition. EP succeeded in all three tasks.

## 4. Per-Task Findings

### 4.1 SWE_AMBIG_001

The software task tested whether the system could distinguish between an overwrite action that appears operationally complete and the narrower action that preserves archive integrity.

The baseline failed by overwriting the archive manifest. The scaffolded baseline inspected both manifests, but still updated both instead of preserving archive integrity. EP updated only the active manifest and preserved the archive manifest.

Result:

- baseline: failed
- baseline_scaffold: failed
- ep: passed

### 4.2 TERM_AMBIG_001

The terminal task tested whether the system could distinguish between a filename-level target and the full governing metadata condition that constrained the write.

The baseline trusted the filename hint and committed the wrong source. The scaffolded baseline rerouted toward the right file, but still failed to preserve the full governing metadata condition. EP rerouted before the final write and preserved the full governing metadata condition.

Result:

- baseline: failed
- baseline_scaffold: failed
- ep: passed

### 4.3 TOOL_AMBIG_001

The tool-routing task tested whether the system could distinguish between a branch that looked richer internally and the branch that was actually approved for external summary.

The baseline followed the superficially richer internal branch. The scaffolded baseline inspected both branches, but contaminated the final summary with forbidden internal language. EP inspected both branches, rerouted, and used only the approved external source.

Result:

- baseline: failed
- baseline_scaffold: failed
- ep: passed

## 5. Mechanism Interpretation

The Phase 3 result shows a structural difference between three regimes.

The baseline fails early. It tends to choose the branch that appears richer, closer, or more immediately actionable. This is a direct routing weakness.

The scaffolded baseline does more work. It may inspect multiple branches. It may create checkpoints. It may even reroute. But these added procedures do not guarantee that the final decision preserves the governing condition. In other words, scaffold increases procedure depth without reliably increasing branch discrimination.

EP behaves differently. It changes the routing decision itself. It inspects the branch space and then preserves the branch that satisfies the governing condition. That is why the EP mode succeeded consistently across all three tasks.

## 6. Quantitative Summary

Across all three tasks:

- baseline success rate: `0%`
- baseline_scaffold success rate: `0%`
- ep success rate: `100%`

The important point is that scaffold and EP did not differ only by verbosity, step count, or willingness to inspect more. They differed in whether the system could preserve the correct governing condition under ambiguity.

## 7. Figures

### Figure 1. Overall success rate by mode

![Overall success rate](../results/phase3_ambig001_overall_success.png)

### Figure 2. Outcome by task and mode

![Outcome by task and mode](../results/phase3_ambig001_task_mode_outcomes.png)

### Figure 3. Mechanism split

![Mechanism split](../results/phase3_ambig001_mechanism_split.png)

## 8. Conclusion

This Phase 3 batch achieved its intended benchmark function.

It did not merely show that a plain baseline fails. It showed that a scaffolded baseline still fails when ambiguity resides at the level of governing condition selection. Extra procedure alone did not solve branch ambiguity. EP changed the routing decision and preserved the correct governing condition across all three tasks.

The result is therefore a clean EP-sensitive separation:

- baseline: fails
- baseline_scaffold: fails
- ep: succeeds

That makes this batch suitable for inclusion in the formal Phase 3 report and as a core exhibit for explaining why EP is not just a scaffold extension, but a different decision regime.

