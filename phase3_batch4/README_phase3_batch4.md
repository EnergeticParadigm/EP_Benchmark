# README — Phase 3 Batch 4

## Title
Phase 3 Batch 4 Measured Results  
Hierarchical-Governance Conflict

## Purpose
Phase 3 Batch 4 tests whether a system can correctly resolve hierarchical-governance conflict when multiple valid conditions are active at the same time. The central question is not whether the system can notice many factors, but whether it can determine which factor has final governing authority and route execution accordingly.

## Structural Focus
This batch targets a stricter and more operationally meaningful failure mode than ordinary ambiguity handling. A model may identify several real constraints and still fail if it treats them as flat or parallel considerations rather than as an ordered governance hierarchy. The evaluation therefore focuses on whether lower-order conditions truly yield to the higher-order governing condition.

## Task Set
The batch contains three tasks:

- `SWE_PRIORITY_001`
- `TERM_PRIORITY_001`
- `TOOL_PRIORITY_001`

These three tasks differ in domain surface but share the same benchmark structure:

- a locally attractive path exists,
- a higher-order governing condition is also present,
- correct performance requires priority collapse under governance rather than local optimization.

## Expected Separation Pattern
The intended separation pattern for this batch is:

- Baseline: fail-dominant
- Baseline Scaffold: partial-dominant
- EP: pass-dominant

This expectation reflects three different decision structures. Baseline systems tend to follow the most immediate productive route. Scaffolded systems often identify more relevant conditions but still keep the decision surface too flat. EP is expected to compress simultaneous conditions into a true governance ordering.

## Measured Results
Measured results match the intended separation pattern exactly.

- Baseline: 0/3 pass
- Baseline Scaffold: 3/3 partial
- EP: 3/3 pass

Per-task scores:

- `SWE_PRIORITY_001`: Baseline 0.0, Baseline Scaffold 0.5, EP 1.0
- `TERM_PRIORITY_001`: Baseline 0.0, Baseline Scaffold 0.5, EP 1.0
- `TOOL_PRIORITY_001`: Baseline 0.0, Baseline Scaffold 0.5, EP 1.0

## Interpretation
Batch 4 shows that the decisive difference is not merely whether a system can mention relevant constraints. The decisive difference is whether it can rank them correctly when several conditions are simultaneously valid. In all three tasks, EP reaches full governance compliance, while Baseline Scaffold improves over Baseline but remains structurally incomplete. This indicates that scaffold alone can increase awareness, yet still fail to produce full priority collapse under the highest governing condition.

## Why This Batch Matters
Earlier Phase 3 batches already separated systems on branch ambiguity, constraint preservation, and route recomputation after late updates. Batch 4 extends the benchmark into hierarchical-governance conflict, which is closer to real operational control. Many real failures are not failures of visibility but failures of ordering. Batch 4 therefore measures a deeper layer of route control: who or what actually governs the final route when multiple conditions are true.

## Files
This batch should include the following materials in the Phase 3 Batch 4 folder:

- task specification
- evaluation files
- measured results matrix
- formal report
- this README

## Core Claim Supported by Batch 4
When multiple valid conditions coexist, EP is more capable than both Baseline and Baseline Scaffold at identifying which condition has final governing authority and at ensuring that lower-order conditions truly yield during execution.
