# EP Benchmark v1

This benchmark compares three modes under the same base model and same task set:

- baseline
- baseline_scaffold
- ep

This repository currently includes:
- 9 smoke-test task definitions
- benchmark folder structure
- runner skeleton
- scorer skeleton
- task manifest
- trace schema

## Current Frozen Release

Release name: ep_benchmark_v1_phase2_complete

This is the current frozen benchmark baseline.

Benchmark status:
- 32 tasks
- fully executed
- three modes: baseline, baseline_scaffold, ep

Final success rates:
- baseline: 0.4375
- baseline_scaffold: 0.8750
- ep: 0.9688

Paired significance:
- baseline vs baseline_scaffold: p = 0.000122
- baseline vs ep: p = 0.000015
- baseline_scaffold vs ep: p = 0.250000

Governance metrics:
- invalid_tool_rate: baseline = 0.1875, baseline_scaffold = 0.0938, ep = 0.0000
- checkpoint_rate: baseline = 0.0000, baseline_scaffold = 0.0000, ep = 0.2500
- rollback_rate: baseline = 0.0312, baseline_scaffold = 0.1250, ep = 0.2500

Key files:
- reports: /Users/wesleyshu/ep_benchmark_v1/results/reports
- frozen release: /Users/wesleyshu/ep_benchmark_v1/releases/ep_benchmark_v1_phase2_complete
