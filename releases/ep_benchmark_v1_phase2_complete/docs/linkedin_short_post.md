EP Benchmark Phase 2 is now frozen as a complete 32-task internal benchmark.

We tested three execution modes on the same fully executed task pack:

baseline  
baseline_scaffold  
ep

Final success rates:

baseline = 0.4375  
baseline_scaffold = 0.8750  
ep = 0.9688

The benchmark also captured execution quality, not just completion. EP finished with zero invalid tool behavior, the highest checkpoint rate, and the highest rollback rate.

Paired comparisons are now strong:

baseline vs baseline_scaffold  
p = 0.000122

baseline vs ep  
p = 0.000015

This means the benchmark has moved beyond a concept demo. It is now a stable internal baseline for comparing raw execution, structured execution, and governed execution.

Raw execution is weakest.  
Structured execution is much stronger.  
Governed execution is strongest.
