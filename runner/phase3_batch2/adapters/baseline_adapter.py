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
