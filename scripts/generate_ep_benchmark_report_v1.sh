#!/bin/zsh
set -euo pipefail

BASE="/Users/wesleyshu/ep_benchmark_v1"
REPORT="$BASE/results/reports/EP_benchmark_smoke_test_report_v1.md"

/bin/cat > "$REPORT" <<'EOT'
# EP Benchmark Smoke Test Report v1

## Scope

This report summarizes the first internal smoke-test benchmark for EP benchmark v1.

The benchmark compares three execution modes over the same 9-task smoke-test pack:

- baseline
- baseline_scaffold
- ep

The smoke-test pack contains:

- TERM_001
- TERM_010
- TERM_019
- TOOL_001
- TOOL_006
- TOOL_013
- SWE_001
- SWE_010
- SWE_015

All 9 tasks are now connected to real execution.  
There are no remaining placeholder-only tasks in this smoke-test run.

## Core Result

The benchmark now shows meaningful separation across the three modes.

### Main Metrics

- baseline: success_rate=0.7778, avg_tokens=0.0, avg_runtime=0.051, avg_steps=2.4444, invalid_tool_rate=0.1111, rollback_rate=0.1111, checkpoint_rate=0.0
- baseline_scaffold: success_rate=0.8889, avg_tokens=0.0, avg_runtime=0.0457, avg_steps=2.6667, invalid_tool_rate=0.1111, rollback_rate=0.1111, checkpoint_rate=0.0
- ep: success_rate=1.0, avg_tokens=0.0, avg_runtime=0.0469, avg_steps=2.6667, invalid_tool_rate=0.0, rollback_rate=0.2222, checkpoint_rate=0.2222

### Failure Taxonomy

- baseline: wrong_route=1, wrong_tool=1, too_many_steps=0, state_loss=0, unrecovered_error=0, final_answer_wrong=0, incomplete_execution=0
- baseline_scaffold: wrong_route=0, wrong_tool=1, too_many_steps=0, state_loss=0, unrecovered_error=0, final_answer_wrong=0, incomplete_execution=0
- ep: wrong_route=0, wrong_tool=0, too_many_steps=0, state_loss=0, unrecovered_error=0, final_answer_wrong=0, incomplete_execution=0

## Interpretation

This benchmark no longer measures only whether tasks can be completed.  
It now captures structural execution differences.

The main pattern is clear:

Baseline is weakest on rerouting and governance-sensitive steps.

Baseline_scaffold improves some execution behavior, especially rerouting, but still does not introduce proper checkpoint control.

EP achieves the best result across the three modes.  
It reaches full task completion, eliminates invalid tool behavior in this smoke-test run, and introduces explicit checkpoint and rollback behavior where governance-sensitive execution requires it.

This matters because EP is not being evaluated only as a higher-score answerer.  
It is being evaluated as an execution structure that changes how the system routes, recovers, pauses, and resumes.

## Task-Level Reading

### TERM tasks

TERM_001, TERM_010, and TERM_019 all execute successfully under the current run.

TERM_019 is especially important because it already records recovery behavior:
- rollback_count
- route_change_count

That task demonstrates that the benchmark can measure recovery structure rather than only final correctness.

### TOOL tasks

TOOL_001 executes successfully across all modes in its current setup.

TOOL_006 is the first strong separation task.
- baseline stays on retrieval_a and does not reroute
- baseline_scaffold reroutes
- ep reroutes with explicit checkpoint and rollback accounting

TOOL_013 is the first strong governance task.
- baseline skips checkpoint and fails
- baseline_scaffold still skips checkpoint and fails
- ep triggers checkpoint and succeeds

These two tasks are currently the clearest evidence that EP changes execution quality rather than merely output formatting.

### SWE tasks

SWE_001, SWE_010, and SWE_015 execute successfully under the current run.

SWE_015 is particularly valuable because it encodes an explicit wrong-first-path pattern:
- superficial patch
- failed evaluation
- rollback
- correct patch

That gives the benchmark another place where structural recovery can be measured.

## What This Benchmark Already Proves

This smoke-test benchmark now proves four things.

First, the benchmark framework itself is operational.

Second, all 9 smoke-test tasks are wired into real execution.

Third, the benchmark can capture execution-structure metrics beyond correctness, including:
- invalid tool usage
- checkpoint count
- rollback count
- route changes

Fourth, the benchmark already shows mode separation:
baseline < baseline_scaffold < ep

## What This Benchmark Does Not Yet Prove

This benchmark does not yet prove broad superiority on public leaderboards.

It is still an internal smoke-test pack.

It also does not yet use model-driven natural-language reasoning as the primary executor.  
Several tasks are still implemented as controlled deterministic execution flows inside the benchmark harness.

So the current result should be described as:

EP benchmark smoke-test evidence of execution-structure advantage under controlled internal tasks.

That is already valuable, but it should not yet be overstated.

## Recommended Next Step

The strongest next step is to build Benchmark Phase 2.

Phase 2 should expand in two directions:

1. More mode separation  
Apply baseline vs scaffold vs ep differences to additional tasks, especially TERM_019 and SWE_015 in more explicit ways.

2. Larger task pack  
Expand from 9 smoke-test tasks to a broader internal benchmark set, while preserving the same trace schema and scoring logic.

A practical target is:

- 30 to 50 tasks
- same three modes
- same reporting format
- same structural metrics

## Short Conclusion

EP benchmark smoke-test v1 is complete.

The framework is live.  
All 9 tasks execute.  
Mode separation is visible.  
EP currently achieves the best result in this internal smoke-test pack, especially on rerouting, checkpointing, and governance-sensitive execution.
EOT

/bin/echo "Wrote report to $REPORT"
