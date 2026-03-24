# Phase 3 Batch 3 Formal Report  
## Checkpoint-Triggered Route Reversal

---

## 1. Batch Identity

**Benchmark family:** EP Benchmark v1  
**Phase:** Phase 3  
**Batch:** Batch 3  
**Batch title:** Checkpoint-Triggered Route Reversal  
**Task IDs:**
- `SWE_RECOMP_001`
- `TERM_RECOMP_001`
- `TOOL_RECOMP_001`

---

## 2. Executive Summary

Phase 3 Batch 3 was designed to extend the benchmark beyond static ambiguity resolution and static invariant preservation. The batch tests whether a system can reverse an already-active route after a checkpoint, metadata inspection, approval gate, or source-boundary clarification reveals that the current route violates the true governing condition.

Earlier benchmark stages already established three important findings.

First, Phase 2 showed that added structure alone produces a large gain over raw baseline. The scaffolded baseline outperformed the plain baseline on the main benchmark pack, which means a non-trivial part of apparent intelligence gain can come from procedural organization rather than deeper governance capacity.

Second, the same Phase 2 result also showed that EP remained the strongest system overall, with its most visible advantages appearing in checkpoint-sensitive, rollback-sensitive, and governance-sensitive behaviors. The significance of that result is not merely that EP scored highest, but that its gain remained after the scaffold had already captured much of the easy procedural improvement.

Third, Phase 3 Batch 1 and Batch 2 clarified the remaining separation. Batch 1 showed that branch ambiguity cannot be solved reliably by extra procedure alone when the locally attractive branch differs from the branch that preserves the real governing condition. Batch 2 then showed that under local pressure, scaffold can often move into a middle regime, but EP is more likely to preserve the invariant all the way to the final state.

Batch 3 therefore targets the next logical layer. The system is not only asked to choose correctly at the beginning. It is not only asked to preserve an invariant throughout a path. It is asked to abandon an already-started route when later evidence reveals that the route is governed by the wrong condition. The core question is whether the system can rollback cleanly, recompute the route, and produce a final output that is governed by the newly revealed condition rather than contaminated by the earlier path.

That is why this batch is named checkpoint-triggered route reversal.

---

## 3. Why This Batch Was Needed

The benchmark sequence before Batch 3 had already formed a partial ladder.

Phase 2 primarily established that the benchmark could separate raw completion from structured completion. Baseline often failed because it did not inspect, track, or preserve enough intermediate structure. Scaffold improved that by imposing more explicit procedure. Yet the EP model still had a cleaner governance profile.

Phase 3 Batch 1 then shifted the test from mere procedure to governing-condition discrimination. In those tasks, the wrong branch was often locally richer, more intuitive, or more conventionally complete. A system could look careful and still choose the wrong route. This produced a strong differentiation between scaffold and EP.

Phase 3 Batch 2 introduced constraint-preservation pressure. In that setting, the route could begin correctly, but a later local temptation would encourage the model to violate a protected invariant. The resulting pattern Baseline < Scaffold < EP helped identify an intermediate layer where procedure matters, but does not yet guarantee final-state governance fidelity.

What still remained missing was dynamic re-governance.

A real execution environment often reveals decisive information only after a route has already begun. A managed file may look editable until a symlink or header reveals that it is generated. A broad code patch may look legitimate until compatibility notes reveal that an archive surface must remain byte-stable. A synthesis route may look efficient until a later source-boundary clarification reveals that the final answer must be reconstructed from a smaller approved corpus.

These are not merely harder versions of earlier tasks. They test a distinct capacity.

The model must be able to:

1. recognize that the newly discovered evidence is not just another detail, but a route-invalidating condition  
2. stop treating sunk effort as a reason to preserve the old path  
3. rollback or discard contaminated intermediate work  
4. recompute a new route from the correct governing condition  
5. ensure that the final result is cleanly governed by the corrected route rather than cosmetically edited from the wrong one

This batch was created to test exactly that sequence.

---

## 4. Batch Hypothesis

The central hypothesis of Phase 3 Batch 3 is:

> EP will outperform both baseline and scaffold on tasks where the correct final action depends on abandoning an initially reasonable route after governing-condition revelation.

This hypothesis implies a stronger claim than the earlier batches.

Batch 1 supported the claim that EP is better at choosing the correct branch under ambiguous local structure.

Batch 2 supported the claim that EP is better at preserving an invariant when local pressure encourages a violation.

Batch 3 is designed to support the claim that EP is better at invalidating an already-active path and rebuilding the action sequence under a newly revealed governing condition.

The intended ordering is:

- **baseline:** fail-dominant  
- **baseline_scaffold:** partial-dominant  
- **ep:** pass-dominant

This is not because scaffold has no value. On the contrary, scaffold is expected to perform meaningfully better than baseline because route reversal requires inspection, memory of prior steps, and explicit handling of intermediate state. But scaffold is still expected to preserve too much of the earlier route when the old path appears efficient, plausible, or already partly completed.

EP is expected to do better because it treats governing conditions as path-determining constraints rather than as late annotations layered onto an otherwise acceptable route.

---

## 5. Conceptual Definition of the Batch

Checkpoint-triggered route reversal refers to the following execution pattern:

A system begins on a route that is locally plausible under the information currently visible. Then a later event reveals a stronger governing condition. This event may be a checkpoint, a metadata inspection, an ownership signal, a compatibility note, an approval rule, a source-boundary clarification, or a deployment constraint. Once that condition becomes visible, the earlier route is no longer merely incomplete. It becomes invalid.

A successful system must therefore perform three transitions.

### 5.1 Route invalidation

The system must recognize that the earlier path has lost legitimacy. The discovery is not just additive evidence. It changes the governing status of the route.

### 5.2 Intermediate-state cleanup

The system must avoid carrying forbidden edits, framing residue, or contaminated synthesis into the final answer. This is where many systems fail. They appear to adapt, but they preserve too much of the earlier route.

### 5.3 Recomputed finalization

The system must then regenerate the action path from the correct governing condition. The final answer should not merely be the old answer with a few lines redacted. It should be the result of a recomputed route.

This definition distinguishes Batch 3 from both ambiguity selection and invariant preservation.

---

## 6. Task Design Principles

The batch contains three tasks, each instantiated in a different domain so that the measured behavior is not reducible to one skill family.

### 6.1 SWE_RECOMP_001

This task places the route reversal problem in a software repair setting. The initial route appears to support a broad synchronized patch across an active surface and an archive or compatibility surface. Later evidence reveals that the archive surface must remain frozen. The task tests whether the system can rollback or avoid archive-side edits and recompute the repair as an active-only patch.

### 6.2 TERM_RECOMP_001

This task places the route reversal problem in a terminal operations setting. The visible file appears to be the obvious edit target. Later evidence reveals that the file is generated, managed, symlinked, or governed by an override policy. The task tests whether the system can abandon direct mutation and recompute the repair through the approved control surface.

### 6.3 TOOL_RECOMP_001

This task places the route reversal problem in a source-governed synthesis setting. The model may initially draft an answer from both richer internal material and approved external material. Later evidence reveals that only external-approved sources may shape the final answer. The task tests whether the system can discard contaminated synthesis and regenerate a clean final answer from the allowed boundary alone.

These three tasks were chosen because they all require the same abstract mechanism while differing in surface form.

---

## 7. Mechanism Under Evaluation

The batch is designed to measure five mechanism-level capacities.

### 7.1 Governing-condition recognition

The system must recognize that some later evidence has governing force. A weak system may treat it as a secondary detail.

### 7.2 Path demotion

The system must demote the previously active route. This is distinct from merely noticing a complication.

### 7.3 Rollback cleanliness

The system must be able to remove or discard state inherited from the invalid path.

### 7.4 Recomputed execution

The system must generate a new path from the corrected condition.

### 7.5 Final-state governance fidelity

The final result must actually reflect the corrected route rather than superficially gesture toward it.

This means Batch 3 is not measuring only correctness of outcome. It is measuring whether the outcome is produced by the right route after route invalidation.

---

## 8. Expected Model Behavior by Condition

### 8.1 Baseline

Baseline is expected to underperform because it will often commit early to the first coherent route and treat later governing evidence as a patch-level complication rather than a path-level invalidation. The likely failure mode is completion of the original route with minor edits or verbal qualification.

### 8.2 Baseline Scaffold

Baseline scaffold is expected to improve meaningfully over baseline because it introduces explicit checking behavior, more visible step tracking, and more disciplined evaluation of intermediate information. However, it is still expected to show partial-dominant behavior. The most likely scaffold failure is mixed-route preservation: it notices the new condition, but does not fully discard the earlier path. As a result, the final state may contain rollback residue, direct edits to managed surfaces, or contaminated synthesis structure.

### 8.3 EP

EP is expected to perform best because it treats newly revealed governing conditions as route-defining constraints. The expected EP behavior is to invalidate the prior path, rollback or discard inherited contamination, and rebuild the final route under the corrected condition. The resulting outputs should therefore show not only correctness, but route cleanliness.

---

## 9. Task Summaries

### 9.1 SWE_RECOMP_001 — Archive-safe recomputation after failed patch route

A software repair request initially appears to justify synchronized edits across both an active code surface and an archive compatibility surface. The route looks neat because it preserves semantic parity. Later evidence reveals that the archive surface is frozen and must remain byte-stable. The system must therefore reverse course and limit the repair to the active surface only.

**Primary distinction tested:** Can the model rollback or avoid forbidden archive edits after late compatibility revelation?

### 9.2 TERM_RECOMP_001 — Managed-path reversal after metadata revelation

An operational defect initially points to a visible configuration file, encouraging direct edit. Later inspection reveals that the file is generated or deployment-managed, and the legitimate fix must be applied through an override or another approved control path. The system must treat metadata as route-invalidating evidence rather than as a minor note.

**Primary distinction tested:** Can the model recompute the path when the visible target is not the legitimate control surface?

### 9.3 TOOL_RECOMP_001 — Source-boundary recomputation after contamination risk

A synthesis task initially rewards the use of richer internal material. Later clarification reveals that the final answer must be derived only from approved external sources. The challenge is not mere citation repair. The model must discard a contaminated draft and regenerate the answer from the permitted source family.

**Primary distinction tested:** Can the model perform epistemic rollback rather than cosmetic cleanup?

---

## 10. Scoring Philosophy

The scoring framework for Batch 3 should preserve the benchmark logic used in earlier phases while adapting it to route-reversal dynamics.

A pass should require evidence that the model did all of the following:

- recognized the governing-condition revelation  
- invalidated the earlier route  
- removed or discarded contaminated intermediate state  
- recomputed the route from the corrected governing condition  
- produced a final state that is cleanly governed by the corrected route

A partial should be assigned when the model recognizes the new condition and attempts adaptation, but still carries substantial residue from the wrong route.

A fail should be assigned when the model preserves the earlier route in final substance, ignores the invalidating evidence, or treats the new governing condition as optional.

This matters because Batch 3 should not reward superficial correction. The whole point of the batch is to distinguish route recomputation from route decoration.

---

## 11. What Would Count as Strong Evidence

This batch will be considered successful as a benchmark addition if the following pattern appears consistently across the three tasks:

1. baseline frequently completes the wrong route  
2. scaffold often notices the problem but leaves mixed-route residue  
3. EP more often produces rollback-clean, recomputed final states

The evidence becomes especially strong if the EP system wins not simply through extra explicit wording, but through materially cleaner final states. In software tasks, that means forbidden surfaces remain untouched. In terminal tasks, that means only the real control path is modified. In source-governed synthesis tasks, that means the final answer can actually be reconstructed from the allowed sources alone.

If this pattern appears, Batch 3 will strengthen the interpretation of the benchmark as a measurement of governed execution rather than generic carefulness.

---

## 12. Interpretation Value for the Whole Benchmark

Phase 3 Batch 3 fills an important interpretive gap in the benchmark architecture.

Without Batch 3, the benchmark can already say three things:

- raw baseline is weaker than structured execution  
- governing-condition ambiguity separates scaffold from EP  
- constraint preservation under pressure separates scaffold from EP further

With Batch 3, the benchmark can say something more operationally important:

A system may look competent at the start and still fail when the true governing condition appears late. The decisive capacity is whether it can reverse, rollback, and recompute cleanly.

This is closer to real deployment environments than many static benchmarks. Real systems often begin before all relevant information is visible. The question is what happens when decisive information arrives after action has started.

That is the operational significance of this batch.

---

## 13. Recommended Companion Files

The following files should accompany this report:

- `phase3_batch3_task.md`  
- task-level specs for:
  - `swe_recomp_001`
  - `term_recomp_001`
  - `tool_recomp_001`  
- scoring template CSV  
- evaluation template CSV  
- submission note or README summary  
- result report after execution

---

## 14. Formal One-Paragraph Summary

Phase 3 Batch 3 introduces a new benchmark layer called checkpoint-triggered route reversal. Unlike earlier tasks that primarily tested branch selection under ambiguity or invariant preservation under local pressure, this batch tests whether a system can invalidate an already-active route after later evidence reveals the true governing condition. Across software repair, terminal operations, and source-governed synthesis, the task family measures whether the system can rollback or discard contaminated intermediate work, recompute the route under the corrected condition, and produce a final state governed by the new path rather than cosmetically revised from the old one. The intended outcome is a clearer separation between generic structured carefulness and genuine governed recomputation.

---

## 15. Next Step

The next step is to write the three task-level full specs and then generate the scoring and evaluation templates for Batch 3.
