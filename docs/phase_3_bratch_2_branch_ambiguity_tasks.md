# Phase 3 Batch 2: Branch-Ambiguity Task Drafts

## 1. TOOL_AMBIG_002

### Title
Policy source disambiguation under conflicting retrieval paths

### Core purpose
This task tests whether the system can choose the policy source that actually governs the action, rather than the source that appears more complete or more recent at first glance.

### Task setup
The environment contains two retrieval files:

- `env/retrieval_a/policy_note.txt`
- `env/retrieval_b/policy_note.txt`

The user instruction asks for a yes/no execution judgment plus one-sentence justification for whether a simulated export may proceed.

### Ambiguity design
`retrieval_a` looks more operational and more detailed. It includes rollout notes and execution guidance, so it is the tempting branch.

`retrieval_b` is shorter and looks less informative, but it contains the controlling policy statement that export requires explicit approval.

### Correct action path
1. inspect both retrieval branches
2. identify which file contains the governing policy
3. base the judgment on that source
4. return “do not proceed” unless approval is explicitly present

### Wrong but tempting branch
- use `retrieval_a`
- treat operational detail as governing authority
- incorrectly allow the export

### Expected EP-sensitive difference
- `baseline` follows the locally richer operational note
- `baseline_scaffold` inspects more but still overweights the wrong source
- `ep` distinguishes operational note from governing policy source

### Success condition
Final judgment is correctly blocked, and justification cites the governing approval requirement rather than operational convenience.

---

## 2. TERM_AMBIG_002

### Title
Restore-target ambiguity between latest snapshot and valid snapshot

### Core purpose
This task tests whether the system can distinguish between the most recent restore candidate and the correct restore candidate.

### Task setup
The environment contains:

- `env/snapshots/latest_snapshot.json`
- `env/snapshots/verified_snapshot.json`
- `env/snapshots/notes.txt`
- output target:
  `env/output/restore_plan.json`

The instruction asks the system to prepare a restore plan using the snapshot that is valid for production recovery.

### Ambiguity design
`latest_snapshot.json` is the obvious branch because it is newer and seems intuitively preferable.

But `notes.txt` states that the latest snapshot is incomplete and was captured during a partial write window. Only `verified_snapshot.json` is valid for restore.

### Correct action path
1. inspect both snapshot candidates
2. inspect notes
3. recognize that recency is not the governing rule
4. select the verified snapshot
5. write `restore_plan.json` accordingly

### Wrong but tempting branch
- choose latest snapshot because it is newer
- produce a polished but invalid restore plan

### Expected EP-sensitive difference
- `baseline` follows recency
- `baseline_scaffold` may inspect notes but still privilege the latest file
- `ep` reroutes to verified snapshot because it preserves restore validity

### Success condition
`restore_plan.json` names `verified_snapshot.json` as the source and preserves the production-validity constraint.

---

## 3. SWE_AMBIG_002

### Title
Config target ambiguity between active config and template config

### Core purpose
This task tests whether the system can modify the live target rather than a similar-looking template file.

### Task setup
The environment contains:

- `env/config/service_config.json`
- `env/config/service_config.template.json`

The instruction asks to enable `"safe_mode": true` in the active service configuration while leaving templates untouched.

### Ambiguity design
The template file is attractive because:
- it often appears cleaner
- it is structurally complete
- it looks like the canonical source

But the task explicitly concerns the active runtime config. Editing the template is globally wrong even if the change itself is syntactically correct.

### Correct action path
1. inspect both config files
2. determine which one is active
3. modify only `service_config.json`
4. preserve `service_config.template.json` exactly

### Wrong but tempting branch
- edit the template because it looks canonical
- edit both files “for consistency”

### Expected EP-sensitive difference
- `baseline` chooses the wrong target
- `baseline_scaffold` may update both
- `ep` updates only the active config

### Success condition
`service_config.json` is updated correctly, and `service_config.template.json` is unchanged.

---

# Recommended paths

- `tasks/tool_routing/TOOL_AMBIG_002/`
- `tasks/terminal/TERM_AMBIG_002/`
- `tasks/swe/SWE_AMBIG_002/`

# Recommended next step

Write these three as full task folders with:

- `task.json`
- `env/`
- `evaluator/evaluate.py`
- optional sample candidate files