# EP Benchmark External Summary

EP Benchmark v1 Phase 2 Complete is a fully executed 32-task internal benchmark comparing three execution modes:

- baseline
- baseline_scaffold
- ep

The benchmark covers three task families:
- terminal
- tool_routing
- swe

Final success rates:
- baseline: 0.4375
- baseline_scaffold: 0.8750
- ep: 0.9688

Paired significance:
- baseline vs baseline_scaffold: p = 0.000122
- baseline vs ep: p = 0.000015
- baseline_scaffold vs ep: p = 0.250000

Governance-oriented execution profile:
- invalid_tool_rate: baseline = 0.1875, baseline_scaffold = 0.0938, ep = 0.0000
- checkpoint_rate: baseline = 0.0000, baseline_scaffold = 0.0000, ep = 0.2500
- rollback_rate: baseline = 0.0312, baseline_scaffold = 0.1250, ep = 0.2500

Core conclusion:

Raw execution is weakest. Structured execution is much stronger. Governed execution is strongest.

Under the current fully executed 32-task internal benchmark, EP achieves the best completion rate and the strongest governance-oriented execution profile.
