# EP Benchmark

EP Benchmark is a benchmark suite designed to test governed execution rather than generic question answering. It compares three execution modes — `baseline`, `baseline_scaffold`, and `ep` — across tasks where correct performance depends on more than producing a plausible answer. The benchmark focuses on route selection, tool discipline, state continuity, rollback handling, checkpoint-aware interruption, and recovery after wrong intermediate actions.

The benchmark is built to evaluate execution quality under pressure. Its central question is whether an execution system can preserve the correct action path when a task involves ambiguity, branching, partial failure, or an approval-sensitive step. In this setting, a superficially reasonable answer is often insufficient. What matters is whether the system selects the right route, avoids irreversible mistakes, pauses when required, and recovers coherently after an incorrect intermediate move.

The current benchmark includes task families in software editing, terminal execution, and tool routing. These tasks are designed to separate three distinct levels of capability. `baseline` represents raw execution. `baseline_scaffold` represents structured execution with organizational support. `ep` represents governed execution with stronger control over routing, rollback, checkpoint sensitivity, and recovery logic.

EP Benchmark does not aim to be a broad academic reasoning benchmark. It is not primarily a test of static knowledge, trivia, or generic QA skill. Its purpose is narrower and more operational. It is designed to measure whether execution remains structurally correct when the problem requires control rather than fluency.

The benchmark outputs task-level results, scored metrics, and paired significance analysis. This makes it possible to examine not only aggregate success rates, but also the specific failure patterns that distinguish raw execution, scaffolded execution, and governed execution. The overall goal is to make the difference between simple scaffolding and deeper execution control empirically visible.

## What This Benchmark Measures

EP Benchmark is designed to evaluate governed execution. The benchmark asks whether an execution system can remain correct when tasks involve route ambiguity, partial failure, approval-sensitive steps, reversible versus irreversible actions, and multi-step recovery requirements.

The benchmark is therefore centered on execution control rather than answer fluency. A system may produce plausible text and still fail the benchmark if it chooses the wrong branch, uses the wrong tool, continues when it should pause, or fails to recover after an incorrect intermediate step.

The benchmark is particularly useful for separating three levels of behavior:

- raw execution without structured control
- structured execution with procedural scaffolding
- governed execution with stronger path discipline and recovery logic

## Execution Modes

The benchmark compares the following execution modes:

- `baseline`  
  Raw execution without the additional structured control layer used in the other modes.

- `baseline_scaffold`  
  Structured execution with organizational support, intended to improve consistency and procedure handling without full governed-execution control.

- `ep`  
  Governed execution with stronger routing discipline, rollback sensitivity, checkpoint-aware interruption, and controlled recovery after intermediate mistakes.

## Task Families

EP Benchmark v1 Phase 2 includes three main task families.

### Software editing tasks

These tasks test whether an execution system can inspect a codebase, apply the correct change, preserve the intended scope of modification, and satisfy the evaluator without introducing unrelated damage.

### Terminal tasks

These tasks test command-line execution under branching, file-state dependency, environment inspection, recovery pressure, and multi-step task completion constraints.

### Tool-routing tasks

These tasks test whether the system selects the correct action path when multiple plausible tools or branches appear available, especially when one route looks locally reasonable but is globally incorrect.

## Repository Structure

The repository is organized around benchmark configuration, task definitions, execution logic, evaluation code, and public release artifacts.

```text
EP_Benchmark/
├── README.md
├── .gitignore
├── configs/
├── docs/
├── releases/
├── results/
├── runner/
├── scorer/
├── scripts/
└── tasks/