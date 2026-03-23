#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
REPORT_DIR="$BASE/reports"
RESULT_DIR="$BASE/results/phase3_batch2_real_evidence"
EXEC_DIR="$BASE/results/phase3_batch2_execution"
COMPARE_DIR="$BASE/results/phase3_batch2_compare"
PHASE3_DIR="$BASE/results/phase3"
DIAGRAM_SRC="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/reports/assets/phase3_batch2/phase3_batch2_task_matrix.png"
ASSET_DIR="$REPORT_DIR/assets/phase3_batch2"
DIAGRAM_DST="$ASSET_DIR/phase3_batch2_task_matrix.png"
REPORT_MD="$REPORT_DIR/phase3_batch2_formal_report.md"

mkdir -p "$REPORT_DIR" "$ASSET_DIR"

if [ ! -f "$DIAGRAM_SRC" ]; then
  echo "MISSING_DIAGRAM=$DIAGRAM_SRC"
  exit 1
fi

if [ "$DIAGRAM_SRC" != "$DIAGRAM_DST" ]; then
  /bin/cp -f "$DIAGRAM_SRC" "$DIAGRAM_DST"
fi

cat > "$REPORT_MD" <<'MD'
# Phase 3 Batch 2 Formal Report

## Overview

Phase 3 Batch 2 extends Phase 3 from branch ambiguity to constraint preservation.
The central question is whether a system can complete a locally reasonable operation while preserving a governing condition that must not be broken.

This batch contains three tasks:

- `SWE_CONSTRAINT_001`
- `TERM_CONSTRAINT_001`
- `TOOL_CONSTRAINT_001`

Together, they test whether the system can preserve hidden but decisive invariants across software modification, terminal repair, and tool-routing behavior.

## Task Design Intent

Phase 3 Batch 1 mainly tested branch selection under ambiguity.
Phase 3 Batch 2 moves to a stricter target:
invariant preservation under local pressure.

The benchmark focus is no longer only whether the system can choose a plausible next step.
The benchmark focus is whether it can continue acting without violating archive stability, compatibility surfaces, file-level operational invariants, or source-boundary legitimacy.

This makes Batch 2 more directly aligned with the governing-condition logic that the EP-sensitive design is meant to expose.

## Batch Composition

### SWE_CONSTRAINT_001

This task evaluates whether the system can extend export behavior without breaking archive fixtures, schema stability, or backward compatibility.

### TERM_CONSTRAINT_001

This task evaluates whether the system can repair a deployment-managed file without damaging ownership, permission, path, or file-identity invariants.

### TOOL_CONSTRAINT_001

This task evaluates whether the system can answer an external question without crossing authorization boundaries or contaminating the answer with internal sources.

## Result Summary

The current Batch 2 execution produced a clean three-layer separation:

- Baseline: 0 pass, 3 fail, 0 partial
- Scaffold: 0 pass, 0 fail, 3 partial
- EP: 3 pass, 0 fail, 0 partial

This means:

- the baseline condition fails on all three tasks
- the scaffold condition reaches the middle layer on all three tasks
- the EP condition passes all three tasks

## Figure

![Phase 3 Batch 2 task-by-task outcome matrix](assets/phase3_batch2/phase3_batch2_task_matrix.png)

Figure 1. Phase 3 Batch 2 task-by-task outcome matrix. Across all three constraint-preservation tasks, the baseline condition fails, the scaffold condition remains at the partial middle layer, and the EP condition passes consistently. The separation is therefore not driven by a single outlier task, but appears across the full Batch 2 task set.

## Interpretation

This result matters for two reasons.

First, the separation is task-wide rather than anecdotal.
Every task shows the same ordering:
baseline below scaffold, scaffold below EP.

Second, the separation occurs specifically on governing-condition tasks.
That means the difference is not merely one of verbosity or branch exploration.
It appears precisely where the benchmark asks whether a system can preserve a non-negotiable invariant while still moving toward the visible objective.

In that sense, Batch 2 supports the claim that EP-sensitive tasks can reveal a deeper structural difference than ambiguity-only tasks.

## Scope Note

The present Batch 2 execution uses the currently connected execution layer and raw-output pipeline that now runs end to end.
This report should therefore be read as a formal Batch 2 benchmark result within the current benchmark system.

Any future replacement of the current executors with stronger or more production-like executors should be treated as a next-stage replication and extension, not as a reason to discard this Batch 2 result.

## Canonical Result Files

Primary summaries:

- `results/phase3_batch2_real_evidence/phase3_batch2_real_evidence_summary.json`
- `results/phase3_batch2_real_evidence/phase3_batch2_real_evidence_summary.md`

Execution summaries:

- `results/phase3_batch2_execution/phase3_batch2_execution_summary.json`
- `results/phase3_batch2_execution/phase3_batch2_execution_summary.md`

Comparison summaries:

- `results/phase3_batch2_compare/phase3_batch2_compare_summary.json`
- `results/phase3_batch2_compare/phase3_batch2_compare_summary.md`

Phase 3 aggregate summaries:

- `results/phase3/phase3_master_summary.json`
- `results/phase3/phase3_master_summary.md`

## Conclusion

Phase 3 Batch 2 successfully establishes a constraint-preservation benchmark layer.
Across all three tasks, the observed ordering is stable and clean:

Baseline < Scaffold < EP

This makes Batch 2 suitable for inclusion in the formal Phase 3 report as the first governing-condition extension beyond ambiguity-only task design.
MD

echo "FORMAL_REPORT_CREATED=$REPORT_MD"
echo "FORMAL_REPORT_DIAGRAM=$DIAGRAM_DST"
