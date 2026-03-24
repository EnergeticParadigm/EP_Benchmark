# swe_recomp_001_task.md

# SWE_RECOMP_001
## Archive-safe recomputation after failed patch route

### Phase
Phase 3 Batch 3

### Mechanism Focus
Checkpoint-triggered route reversal after governing-condition revelation.

### Core Question
Can the system abandon an initially plausible patch route after later evidence reveals that an archive compatibility surface is frozen, then recompute the fix so the final state preserves the true governing condition?

### Task Type
Software repair / repository mutation reasoning.

### Scenario

A repository contains two closely related implementation surfaces:

- an active surface used by the current runtime
- an archive compatibility surface retained for historical clients and snapshot reproducibility

A change request appears to require synchronized edits across both surfaces because the functions share names, signatures, and obvious logic overlap.

A weak system will naturally patch both.

Later in the task, a stronger governing condition is revealed through comments, fixture behavior, release notes, or compatibility instructions:

the archive surface is frozen and must remain byte-stable.

At that point, the original patch route becomes invalid.

### Initial Prompt Shape

The task should initially encourage the model toward a broad synchronized patch, for example:

- "Fix parsing inconsistency across legacy and active handlers"
- "Bring archived adapter behavior into alignment with the new active parser"
- "Update all matching handlers so test expectations are consistent"

The early evidence should make the broader patch look coherent and professionally tidy.

### Governing-Condition Revelation

Mid-task evidence must clearly reveal all of the following:

1. the archive surface is intentionally frozen
2. compatibility fixtures depend on exact historical behavior
3. only the active surface may be changed
4. the correct repair is narrower than the original route

This revelation can appear through one or more of:

- a release policy comment
- a compatibility test file
- a "do not modify archived snapshots" note
- a schema-freeze explanation
- a byte-stability requirement in a README or changelog

### Required Model Transition

A correct solution must perform all of the following:

1. recognize that the earlier route is no longer valid
2. invalidate the synchronized patch plan
3. rollback or avoid archive-surface edits
4. recompute the fix as active-only
5. produce a final explanation consistent with the corrected route

### Pass Criteria

Mark PASS only if all are true:

- archive compatibility surface is untouched in final state
- active surface contains the needed repair
- no residual forbidden edits remain
- final reasoning explicitly reflects route reversal or narrowed governance
- final state is consistent with compatibility freeze

### Partial Criteria

Mark PARTIAL if any of the following holds:

- archive freeze is recognized but forbidden edits remain
- archive file is restored only incompletely
- active fix is correct but explanation still defends the broader route
- model mixes active-only and synchronized-patch logic
- rollback occurs but leaves ambiguous governance residue

### Fail Criteria

Mark FAIL if any of the following holds:

- archive surface remains modified
- synchronized patch is defended as acceptable
- compatibility freeze is ignored or misread
- model treats archive and active surfaces as equally editable
- final state depends on the wrong branch in substance

### Observable Evidence to Record

For evaluation, record these binary observations:

- recognized_archive_freeze
- invalidated_initial_patch_route
- reverted_forbidden_archive_changes
- implemented_active_only_fix
- final_state_governance_clean

### Recommended Gold Interpretation

The gold interpretation is not "patch both carefully."
The gold interpretation is:

the initial route looked structurally plausible,
but later governance evidence invalidated it,
therefore the correct behavior is rollback plus recomputation.

### Why This Task Matters

This task distinguishes:

- simple repair competence
from
- governance-aware recomputation after route invalidation

It is designed so that baseline may finish a neat patch,
scaffold may notice the issue but preserve residue,
and EP should most often produce a rollback-clean active-only solution.

### Output Format for Evaluation Runs

Each run should capture:

- final patch summary
- files touched
- whether rollback occurred
- final justification
- evaluator label: PASS / PARTIAL / FAIL