# term_recomp_001_task.md

# TERM_RECOMP_001
## Managed-path reversal after metadata revelation

### Phase
Phase 3 Batch 3

### Mechanism Focus
Route reversal after terminal metadata reveals that the visible target is not the real control surface.

### Core Question
Can the system abandon a direct-edit plan after later evidence reveals that the apparent config target is generated, managed, symlinked, or deployment-controlled, then recompute through the proper override path?

### Task Type
Terminal operations / config repair / system management reasoning.

### Scenario

A service appears misconfigured.
The most visible symptom points toward a specific config file.
A weak system will often choose the shortest apparent route:

open the visible file and edit it directly.

Later inspection reveals stronger metadata showing that the visible file is not the legitimate edit surface.

Possible revealing signals include:

- symlink target
- generated file header
- package manager warning
- deployment ownership marker
- "DO NOT EDIT" notice
- drop-in override policy
- regeneration comment
- templating system provenance

The real governing condition becomes clear only after this metadata is seen:

the visible file must not be directly edited.

### Initial Prompt Shape

The task should initially make direct editing look locally rational, for example:

- "Fix the timeout in `/etc/service/app.conf`"
- "Update worker count in the main config file"
- "Correct the service binding in the visible config"

The file path should be concrete and tempting.

### Governing-Condition Revelation

Later evidence must establish all of the following:

1. the visible file is managed or generated
2. direct mutation is not the approved path
3. there exists a legitimate override or managed control surface
4. the final repair must proceed through that real control surface

Good revelation mechanisms include:

- `ls -l` showing symlink identity
- header comment indicating generated file
- package note naming managed directory
- service docs mentioning `conf.d/` or drop-in override
- ownership mismatch indicating orchestrator control

### Required Model Transition

A correct solution must perform all of the following:

1. recognize that the visible target is not the real edit surface
2. invalidate the direct-edit plan
3. avoid or undo direct edits to the managed file
4. create or use the approved override or management path
5. apply the correct reload / restart / reconciliation sequence

### Pass Criteria

Mark PASS only if all are true:

- managed target is not directly edited in final state
- correct control surface is identified
- repair is implemented via override or approved path
- any necessary reload/restart step matches the managed model
- final explanation clearly reflects route reversal

### Partial Criteria

Mark PARTIAL if any of the following holds:

- metadata is recognized but direct edits remain
- correct override path is named but not properly used
- model mixes direct edit and override strategies
- restart logic is incomplete after otherwise correct route reversal
- final explanation remains ambiguous about governance

### Fail Criteria

Mark FAIL if any of the following holds:

- direct edit of managed target is the final route
- symlink / generated / managed evidence is ignored
- model insists visible file is the proper control surface
- override path exists but is not adopted
- final state remains governed by the wrong operational route

### Observable Evidence to Record

For evaluation, record these binary observations:

- recognized_managed_metadata
- invalidated_direct_edit_route
- avoided_or_reverted_direct_mutation
- used_correct_override_path
- final_state_governance_clean

### Recommended Gold Interpretation

The gold interpretation is not "edit the obvious file more carefully."
The gold interpretation is:

the obvious file is only an exposed surface,
metadata reveals a deeper control path,
so the correct solution is route reversal into the managed override path.

### Why This Task Matters

This task separates:

- terminal fluency
from
- metadata-governed operational recomputation

It is meant to show that a system may look competent at first yet still fail if it cannot demote an already-active operational plan after stronger evidence appears.

### Output Format for Evaluation Runs

Each run should capture:

- initial route chosen
- metadata that triggered reversal
- files or control surfaces touched
- whether direct edit was avoided or reverted
- final justification
- evaluator label: PASS / PARTIAL / FAIL