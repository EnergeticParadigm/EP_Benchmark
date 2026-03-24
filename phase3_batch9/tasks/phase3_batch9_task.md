# Phase 3 Batch 9 — Recovery Path Adequacy under Partial Failure

## Benchmark Intent

Phase 3 Batch 9 tests whether a system can judge whether an apparent recovery path is actually sufficient after partial failure.

This batch is designed to distinguish among three different reasoning patterns:

1. accepting any visible fallback as adequate recovery;
2. recognizing some limits in the fallback but underestimating the depth of repair required; and
3. correctly judging whether the recovery path truly restores function, governance, and viability.

## EP-Sensitive Mechanism

This batch is EP-sensitive because the main failure is not failure blindness. The main failure is shallow recovery acceptance.

A weak response sees a fallback and assumes the problem is solved.  
A stronger response notices that the fallback has limits, but still treats partial recovery as sufficient.  
A strong EP-sensitive response evaluates whether the recovery path actually restores operational viability, governance integrity, and structural continuity.

## Task Family Definition

Each task contains five structural parts:

1. primary route partially fails;
2. fallback or recovery path is proposed;
3. fallback appears plausible on the surface;
4. hidden reason the fallback is still inadequate;
5. required final judgment or redesign.

The fallback should look workable enough to tempt ordinary reasoning. It should not be obviously invalid at first glance.

## What This Batch Tests

This batch measures whether a system can:

- recognize the real failure state;
- assess the fallback rather than merely acknowledge its existence;
- judge whether the fallback is actually adequate;
- redesign for true restoration rather than symptom masking;
- preserve consistency; and
- remain aligned with the governing requirements of the task.

## Main Failure Modes

- shallow_recovery_acceptance
- fallback_overtrust
- adequacy_misjudgment
- symptom_level_repair
- restoration_gap_ignored
- governance_misalignment
- contradiction_with_failure_state

## Scoring Dimensions

Each item is scored on seven dimensions, each from 0 to 2.

1. failure_state_recognition  
   Did the response correctly identify the real partial-failure condition?

2. fallback_assessment  
   Did the response explicitly assess the proposed fallback rather than merely repeat it?

3. adequacy_judgment  
   Did the response correctly judge whether the fallback is sufficient?

4. redesign_quality  
   Did the response provide a meaningful redesign or strengthened recovery path?

5. contradiction_control  
   Did the response remain consistent with the scenario and its own reasoning?

6. restoration_depth_awareness  
   Did the response distinguish symptom restoration from full restoration?

7. governance_alignment  
   Did the final recommendation remain aligned with the governing requirements?

Maximum per item: 14 points.  
Maximum for 8 items: 112 points.

## Outcome Labels

- valid_recovery_reassessment
- partial_recovery_recognition
- shallow_recovery_acceptance
- fallback_overtrust
- restoration_gap_failure
- governance_overabort

## Batch Task Summaries

### P3B9-T01 — Backup Approval without Full Authority
A backup approval route exists, but backup staff cannot legally approve the highest-risk cases.

### P3B9-T02 — Rollback without Data Integrity
Rollback exists, but it restores surface access without restoring underlying transaction integrity.

### P3B9-T03 — Manual Reporting without Sustained Capacity
A manual reporting fallback exists, but it cannot sustain actual daily operational volume.

### P3B9-T04 — Alternate Vendor without Full Compliance
An alternate supplier exists, but the substitute part fails a required compliance condition.

### P3B9-T05 — Emergency Queue without Endurance
An emergency queue keeps support moving briefly, but service quality degrades after 48 hours.

### P3B9-T06 — Temporary Access without Audit Trail
A workaround restores access, but breaks logging and auditability.

### P3B9-T07 — Partial Communication Recovery
A secondary channel exists, but it reaches only part of the stakeholder set that actually needs the message.

### P3B9-T08 — Incident Recovery without Root Repair
A recovery workflow resolves the visible incident, but the original dependency remains unstable.

## Concise Benchmark Note

Phase 3 Batch 9 tests recovery-path adequacy under partial failure. The core benchmark signal is whether a system can judge that an apparent fallback is still insufficient. The target capability is recovery adequacy judgment rather than simple fallback acceptance.
