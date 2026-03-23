#!/bin/bash
set -euo pipefail

export EP_BENCH_BASELINE_EXEC_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/adapters/baseline_adapter.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
export EP_BENCH_SCAFFOLD_EXEC_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/adapters/scaffold_adapter.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
export EP_BENCH_EP_EXEC_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/adapters/ep_adapter.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'

export EP_BENCH_BASELINE_INNER_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/minimal_executors/baseline_minimal_executor.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
export EP_BENCH_SCAFFOLD_INNER_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/minimal_executors/scaffold_minimal_executor.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
export EP_BENCH_EP_INNER_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/minimal_executors/ep_minimal_executor.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
