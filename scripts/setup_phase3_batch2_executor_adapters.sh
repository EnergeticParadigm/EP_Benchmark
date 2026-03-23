#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
ADAPTER_DIR="$BASE/runner/phase3_batch2/adapters"
SCRIPTS_DIR="$BASE/scripts"

mkdir -p "$ADAPTER_DIR"
mkdir -p "$SCRIPTS_DIR"

cat > "$ADAPTER_DIR/baseline_adapter.py" <<'PY'
#!/usr/bin/env python3
import argparse
import os
import shlex
import subprocess
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--task-id", required=True)
    parser.add_argument("--track", required=True)
    parser.add_argument("--task-dir", required=True)
    parser.add_argument("--task-md", required=True)
    parser.add_argument("--metadata", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    template = os.environ.get("EP_BENCH_BASELINE_INNER_CMD", "").strip()
    if not template:
        print("MISSING_ENV=EP_BENCH_BASELINE_INNER_CMD", file=sys.stderr)
        return 2

    mapping = {
        "task_id": args.task_id,
        "track": args.track,
        "task_dir": args.task_dir,
        "task_md": args.task_md,
        "metadata": args.metadata,
        "output": args.output,
    }

    cmd = shlex.split(template.format(**mapping))
    proc = subprocess.run(cmd)
    return proc.returncode

if __name__ == "__main__":
    raise SystemExit(main())
PY

cat > "$ADAPTER_DIR/scaffold_adapter.py" <<'PY'
#!/usr/bin/env python3
import argparse
import os
import shlex
import subprocess
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--task-id", required=True)
    parser.add_argument("--track", required=True)
    parser.add_argument("--task-dir", required=True)
    parser.add_argument("--task-md", required=True)
    parser.add_argument("--metadata", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    template = os.environ.get("EP_BENCH_SCAFFOLD_INNER_CMD", "").strip()
    if not template:
        print("MISSING_ENV=EP_BENCH_SCAFFOLD_INNER_CMD", file=sys.stderr)
        return 2

    mapping = {
        "task_id": args.task_id,
        "track": args.track,
        "task_dir": args.task_dir,
        "task_md": args.task_md,
        "metadata": args.metadata,
        "output": args.output,
    }

    cmd = shlex.split(template.format(**mapping))
    proc = subprocess.run(cmd)
    return proc.returncode

if __name__ == "__main__":
    raise SystemExit(main())
PY

cat > "$ADAPTER_DIR/ep_adapter.py" <<'PY'
#!/usr/bin/env python3
import argparse
import os
import shlex
import subprocess
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--task-id", required=True)
    parser.add_argument("--track", required=True)
    parser.add_argument("--task-dir", required=True)
    parser.add_argument("--task-md", required=True)
    parser.add_argument("--metadata", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()

    template = os.environ.get("EP_BENCH_EP_INNER_CMD", "").strip()
    if not template:
        print("MISSING_ENV=EP_BENCH_EP_INNER_CMD", file=sys.stderr)
        return 2

    mapping = {
        "task_id": args.task_id,
        "track": args.track,
        "task_dir": args.task_dir,
        "task_md": args.task_md,
        "metadata": args.metadata,
        "output": args.output,
    }

    cmd = shlex.split(template.format(**mapping))
    proc = subprocess.run(cmd)
    return proc.returncode

if __name__ == "__main__":
    raise SystemExit(main())
PY

chmod +x "$ADAPTER_DIR/baseline_adapter.py"
chmod +x "$ADAPTER_DIR/scaffold_adapter.py"
chmod +x "$ADAPTER_DIR/ep_adapter.py"

cat > "$SCRIPTS_DIR/phase3_batch2_executor_env.sh" <<'SH'
#!/bin/bash
set -euo pipefail

export EP_BENCH_BASELINE_EXEC_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/adapters/baseline_adapter.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
export EP_BENCH_SCAFFOLD_EXEC_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/adapters/scaffold_adapter.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'
export EP_BENCH_EP_EXEC_CMD='/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/runner/phase3_batch2/adapters/ep_adapter.py --task-id {task_id} --track {track} --task-dir {task_dir} --task-md {task_md} --metadata {metadata} --output {output}'

# Fill these three with the REAL underlying executors.
# They must create a JSON object at {output}.

export EP_BENCH_BASELINE_INNER_CMD=''
export EP_BENCH_SCAFFOLD_INNER_CMD=''
export EP_BENCH_EP_INNER_CMD=''
SH

chmod +x "$SCRIPTS_DIR/phase3_batch2_executor_env.sh"

cat > "$SCRIPTS_DIR/validate_phase3_batch2_executor_setup.sh" <<'SH'
#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
ENV_FILE="$BASE/scripts/phase3_batch2_executor_env.sh"

if [ ! -f "$ENV_FILE" ]; then
  echo "MISSING_ENV_FILE=$ENV_FILE"
  exit 1
fi

source "$ENV_FILE"

FAIL=0

for key in \
  EP_BENCH_BASELINE_EXEC_CMD \
  EP_BENCH_SCAFFOLD_EXEC_CMD \
  EP_BENCH_EP_EXEC_CMD \
  EP_BENCH_BASELINE_INNER_CMD \
  EP_BENCH_SCAFFOLD_INNER_CMD \
  EP_BENCH_EP_INNER_CMD
do
  value="${!key:-}"
  if [ -z "$value" ]; then
    echo "MISSING_OR_EMPTY=$key"
    FAIL=1
  else
    echo "OK=$key"
  fi
done

if [ $FAIL -ne 0 ]; then
  exit 2
fi

echo "VALIDATION_OK"
SH

chmod +x "$SCRIPTS_DIR/validate_phase3_batch2_executor_setup.sh"

echo "SETUP_OK"
echo "ENV_FILE=$SCRIPTS_DIR/phase3_batch2_executor_env.sh"
echo "VALIDATOR=$SCRIPTS_DIR/validate_phase3_batch2_executor_setup.sh"
