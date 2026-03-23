#!/usr/bin/env python3
import argparse
import json
import subprocess
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
DEFAULT_MANIFEST = BASE / "configs/phase3_batch2_only_manifest.json"
RESULT_ROOT = BASE / "results/phase3_batch2_real"
RAW_DIR = RESULT_ROOT / "raw"
LOG_DIR = RESULT_ROOT / "logs"
SUMMARY_JSON = RESULT_ROOT / "phase3_batch2_real_summary.json"
SUMMARY_MD = RESULT_ROOT / "phase3_batch2_real_summary.md"


def load_manifest(path: Path):
    data = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(data, dict) and isinstance(data.get("tasks"), list):
        return data["tasks"]
    if isinstance(data, list):
        return data
    raise RuntimeError(f"Unsupported manifest structure: {path}")


def ensure_task_files(task: dict):
    required = ["task_id", "track", "task_dir", "grader"]
    for key in required:
        if key not in task:
            raise RuntimeError(f"Missing key '{key}' in task manifest entry: {task}")

    task_dir = Path(task["task_dir"])
    grader = Path(task["grader"])
    metadata = task_dir / "metadata.json"
    task_md = task_dir / "task.md"
    evidence = task_dir / "evidence_examples" / "pass.json"

    missing = [str(p) for p in [task_dir, grader, metadata, task_md, evidence] if not p.exists()]
    if missing:
        raise RuntimeError(f"Missing task files for {task['task_id']}: " + ", ".join(missing))

    return {
        "task_dir": task_dir,
        "grader": grader,
        "metadata": metadata,
        "task_md": task_md,
        "evidence": evidence,
    }


def run_grader(task: dict, files: dict):
    stdout_path = LOG_DIR / f"{task['task_id']}__grader.stdout.json"
    stderr_path = LOG_DIR / f"{task['task_id']}__grader.stderr.log"

    cmd = [
        "/usr/bin/python3",
        str(files["grader"]),
        "--evidence",
        str(files["evidence"]),
    ]

    proc = subprocess.run(
        cmd,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        encoding="utf-8",
        errors="replace",
    )

    stdout_path.write_text(proc.stdout, encoding="utf-8")
    stderr_path.write_text(proc.stderr, encoding="utf-8")

    parsed = None
    parse_error = ""
    if proc.stdout.strip():
        try:
            parsed = json.loads(proc.stdout)
        except Exception as exc:
            parse_error = str(exc)

    return {
        "returncode": proc.returncode,
        "stdout_path": str(stdout_path),
        "stderr_path": str(stderr_path),
        "parsed": parsed,
        "parse_error": parse_error,
        "command": cmd,
    }


def status_from_result(run_result: dict):
    if run_result["returncode"] != 0:
        return "runner_error"
    parsed = run_result["parsed"]
    if not isinstance(parsed, dict):
        return "unparsed"
    score = parsed.get("final_score")
    try:
        score = float(score)
    except Exception:
        return "unparsed"
    if score >= 1.0:
        return "pass"
    if score <= 0.0:
        return "fail"
    return "partial"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    if not manifest_path.exists():
        raise SystemExit(f"MISSING_MANIFEST: {manifest_path}")

    RESULT_ROOT.mkdir(parents=True, exist_ok=True)
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    tasks = load_manifest(manifest_path)

    results = []
    pass_count = 0
    fail_count = 0
    partial_count = 0
    error_count = 0

    for task in tasks:
        task_id = task.get("task_id", "")
        files = ensure_task_files(task)
        run_result = run_grader(task, files)
        status = status_from_result(run_result)

        parsed = run_result["parsed"] if isinstance(run_result["parsed"], dict) else {}
        final_score = parsed.get("final_score", None)
        failure_mode = parsed.get("failure_mode", "")
        failure_modes = parsed.get("failure_modes", [])

        if status == "pass":
            pass_count += 1
        elif status == "fail":
            fail_count += 1
        elif status == "partial":
            partial_count += 1
        else:
            error_count += 1

        task_result = {
            "task_id": task_id,
            "track": task.get("track", ""),
            "task_dir": task.get("task_dir", ""),
            "status": status,
            "final_score": final_score,
            "failure_mode": failure_mode,
            "failure_modes": failure_modes,
            "grader_stdout": run_result["stdout_path"],
            "grader_stderr": run_result["stderr_path"],
            "grader_returncode": run_result["returncode"],
            "grader_parse_error": run_result["parse_error"],
            "evidence_used": str(files["evidence"]),
        }

        raw_out = RAW_DIR / f"{task_id}__result.json"
        raw_out.write_text(json.dumps(task_result, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        results.append(task_result)

    summary = {
        "batch_id": "phase3_batch2_real",
        "manifest": str(manifest_path),
        "task_count": len(results),
        "pass_count": pass_count,
        "fail_count": fail_count,
        "partial_count": partial_count,
        "error_count": error_count,
        "tasks": results,
    }

    SUMMARY_JSON.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = []
    lines.append("# Phase 3 Batch 2 Real Runner Summary")
    lines.append("")
    lines.append(f"- Manifest: `{manifest_path}`")
    lines.append(f"- Task count: `{len(results)}`")
    lines.append(f"- Pass count: `{pass_count}`")
    lines.append(f"- Fail count: `{fail_count}`")
    lines.append(f"- Partial count: `{partial_count}`")
    lines.append(f"- Error count: `{error_count}`")
    lines.append("")
    lines.append("## Tasks")
    lines.append("")
    for item in results:
        lines.append(
            f"- `{item['task_id']}` | track=`{item['track']}` | status=`{item['status']}` | final_score=`{item['final_score']}`"
        )
    lines.append("")
    lines.append("## Output")
    lines.append("")
    lines.append(f"- Summary JSON: `{SUMMARY_JSON}`")
    lines.append(f"- Summary MD: `{SUMMARY_MD}`")
    lines.append(f"- Raw dir: `{RAW_DIR}`")
    lines.append(f"- Log dir: `{LOG_DIR}`")
    SUMMARY_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print("RUN_PHASE3_BATCH2_REAL_OK")
    print(f"SUMMARY_JSON={SUMMARY_JSON}")
    print(f"SUMMARY_MD={SUMMARY_MD}")
    print(f"PASS_COUNT={pass_count}")
    print(f"FAIL_COUNT={fail_count}")
    print(f"PARTIAL_COUNT={partial_count}")
    print(f"ERROR_COUNT={error_count}")


if __name__ == "__main__":
    main()
