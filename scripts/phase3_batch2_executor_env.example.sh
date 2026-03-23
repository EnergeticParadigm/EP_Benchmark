#!/bin/bash
set -euo pipefail

export EP_BENCH_BASELINE_EXEC_CMD='/absolute/path/to/baseline_executor --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
export EP_BENCH_SCAFFOLD_EXEC_CMD='/absolute/path/to/scaffold_executor --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
export EP_BENCH_EP_EXEC_CMD='/absolute/path/to/ep_executor --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
