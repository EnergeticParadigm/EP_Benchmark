# Benchmark Summary

## Main Metrics

- baseline: success_rate=0.4375, avg_tokens=0.0, avg_runtime=0.046, avg_steps=2.0, invalid_tool_rate=0.1875, rollback_rate=0.0312, checkpoint_rate=0.0
- baseline_scaffold: success_rate=0.875, avg_tokens=0.0, avg_runtime=0.0525, avg_steps=2.5, invalid_tool_rate=0.0938, rollback_rate=0.125, checkpoint_rate=0.0
- ep: success_rate=0.9688, avg_tokens=0.0, avg_runtime=0.0464, avg_steps=2.5, invalid_tool_rate=0.0, rollback_rate=0.25, checkpoint_rate=0.25

## Failure Taxonomy

- baseline: wrong_route=6, wrong_tool=6, too_many_steps=0, state_loss=0, unrecovered_error=0, final_answer_wrong=6, incomplete_execution=0
- baseline_scaffold: wrong_route=0, wrong_tool=3, too_many_steps=0, state_loss=0, unrecovered_error=0, final_answer_wrong=1, incomplete_execution=0
- ep: wrong_route=0, wrong_tool=0, too_many_steps=0, state_loss=0, unrecovered_error=0, final_answer_wrong=1, incomplete_execution=0
