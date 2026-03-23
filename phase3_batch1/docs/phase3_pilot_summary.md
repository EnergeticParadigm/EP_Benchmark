
# Phase 3 Pilot Summary

The first Phase 3 pilot pack focused on branch-ambiguity tasks designed to separate `baseline_scaffold` from `ep` more sharply than the Phase 2 pack.

The pilot included three tasks:

- `TOOL_AMBIG_001`
- `TERM_AMBIG_001`
- `SWE_AMBIG_001`

Results:

- `baseline`: 0/3
- `baseline_scaffold`: 0/3
- `ep`: 3/3

Interpretation:

The pilot confirms that branch-ambiguity tasks are highly EP-sensitive. In all three cases, raw execution failed, scaffolded execution also failed, and only EP-governed execution preserved the globally correct action path.

This is important because the unresolved comparison after Phase 2 was not `baseline` versus `ep`, but `baseline_scaffold` versus `ep`. The pilot shows that when one branch is locally plausible but globally wrong, scaffolded procedure alone is not enough. Stronger governed execution remains measurable and operationally distinct.

Observed pattern:

- `baseline` followed the locally attractive branch
- `baseline_scaffold` often inspected more than one branch, but still failed to preserve the governing constraint
- `ep` rerouted correctly and preserved the task-level constraint through checkpoint-sensitive recovery logic

Conclusion:

The Phase 3 direction is validated. The next step is to expand from this 3-task pilot to a 10–15 task EP-sensitive pack, beginning with additional branch-ambiguity tasks and then extending into irreversible-action simulations and governance-pressure tasks.