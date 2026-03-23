#!/usr/bin/env python3
import argparse
import json
import os
import shlex
import subprocess
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
DEFAULT_MANIFEST = BASE / "configs/phase3_batch2_only_manifest.json"
RESULT_ROOT = BASE / "results/phase3_batch2_execution"
RAW_DIR = BASE / "results/raw"
LOG_DIR = RESULT_ROOT / "logs"
SUMMARY_JSON = RESULT_ROOT / "phase3_batch2_execution_summary.json"
SUMMARY_MD = RESULT_ROOT / "phase3_batch2_execution_summary.md"

MODES = ["baseline", "scaffold", "ep"]
ENV_KEYS = {
    "baseline": "EP_BENCH_BASELINE_EXEC_CMD",
    "scaffold": "EP_BENCH_SCAFFOLD_EXEC_CMD",
    "ep": "EP_BENCH_EP_EXEC_CMD",
}


def load_manifest(path: Path):
    data = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(data, dict) and isinstance(data.get("tasks"), list):
        return data["tasks"]
    if isinstance(data, list):
        return data
    raise RuntimeError("Unsupported manifest structure: " + str(path))


def output_path_for(task_id: str, mode: str) -> Path:
    if mode == "scaffold":
        return RAW_DIR / f"{task_id}__baseline_scaffold.json"
    return RAW_DIR / f"{task_id}__{mode}.json"


def parse_cmd_template(template: str, mapping: dict):
    rendered = template.format(**mapping)
    return shlex.split(rendered)


def valid_json_object(path: Path):
    if not path.exists():
        return False
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return False
    return isinstance(data, dict)


def run_one(task: dict, mode: str):
    task_id = task["task_id"]
    track = task["track"]
    task_dir = Path(task["task_dir"])
    task_md = task_dir / "task.md"
    metadata = task_dir / "metadata.json"
    output_path = output_path_for(task_id, mode)
    stdout_log = LOG_DIR / f"{task_id}__{mode}.stdout.log"
    stderr_log = LOG_DIR / f"{task_id}__{mode}.stderr.log"

    env_key = ENV_KEYS[mode]
    template = os.environ.get(env_key, "").strip()

    result = {
        "task_id": task_id,
        "track": track,
        "mode": mode,
        "env_key": env_key,
        "status": "blocked",
        "command": [],
        "output_path": str(output_path),
        "stdout_log": str(stdout_log),
        "stderr_log": str(stderr_log),
        "returncode": None,
        "notes": [],
    }

    if output_path.exists() and valid_json_object(output_path):
        result["status"] = "already_present"
        result["notes"].append("valid raw output already exists")
        return result

    if not template:
        result["notes"].append("missing executor env var")
        return result

    mapping = {
        "base": str(BASE),
        "task_id": task_id,
        "track": track,
        "task_dir": str(task_dir),
        "task_md": str(task_md),
        "metadata": str(metadata),
        "output": str(output_path),
        "mode": mode,
    }

    cmd = parse_cmd_template(template, mapping)
    result["command"] = cmd

    proc = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    stdout_log.write_text(proc.stdout, encoding="utf-8")
    stderr_log.write_text(proc.stderr, encoding="utf-8")
    result["returncode"] = proc.returncode

    if proc.returncode == 0 and valid_json_object(output_path):
        result["status"] = "generated"
    else:
        result["status"] = "failed"
        if proc.returncode != 0:
            result["notes"].append("executor_returned_nonzero")
        if not valid_json_object(output_path):
            result["notes"].append("output_missing_or_invalid")

    return result


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    args = parser.parse_args()

    manifest = Path(args.manifest)
    if not manifest.exists():
        raise SystemExit("MISSING_MANIFEST=" + str(manifest))

    RESULT_ROOT.mkdir(parents=True, exist_ok=True)
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    RAW_DIR.mkdir(parents=True, exist_ok=True)

    tasks = load_manifest(manifest)
    rows = []
    totals = {mode: {"generated": 0, "already_present": 0, "failed": 0, "blocked": 0} for mode in MODES}

    for task in tasks:
        task_row = {
            "task_id": task["task_id"],
            "track": task["track"],
            "task_dir": task["task_dir"],
            "modes": {},
        }
        for mode in MODES:
            result = run_one(task, mode)
            task_row["modes"][mode] = result
            totals[mode][result["status"]] += 1
        rows.append(task_row)

    summary = {
        "manifest": str(manifest),
        "task_count": len(rows),
        "modes": MODES,
        "totals": totals,
        "tasks": rows,
    }
    SUMMARY_JSON.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = []
    lines.append("# Phase 3 Batch 2 Execution Summary")
    lines.append("")
    lines.append(f"- Manifest: `{manifest}`")
    lines.append(f"- Task count: `{len(rows)}`")
    lines.append("")
    lines.append("## Mode Totals")
    lines.append("")
    for mode in MODES:
        t = totals[mode]
        lines.append(
            f"- `{mode}` | generated=`{t['generated']}` | already_present=`{t['already_present']}` | failed=`{t['failed']}` | blocked=`{t['blocked']}`"
        )
    lines.append("")
    lines.append("## Tasks")
    lines.append("")
    for row in rows:
        lines.append(f"### {row['task_id']}  ({row['track']})")
        lines.append("")
        for mode in MODES:
            r = row["modes"][mode]
            lines.append(
                f"- `{mode}` | status=`{r['status']}` | output=`{r['output_path']}` | env=`{r['env_key']}`"
            )
        lines.append("")
    SUMMARY_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print("SUMMARY_JSON=" + str(SUMMARY_JSON))
    print("SUMMARY_MD=" + str(SUMMARY_MD))
    for mode in MODES:
        t = totals[mode]
        print(
            mode.upper()
            + "="
            + "generated:" + str(t["generated"])
            + ",already_present:" + str(t["already_present"])
            + ",failed:" + str(t["failed"])
            + ",blocked:" + str(t["blocked"])
        )


if __name__ == "__main__":
    main()
