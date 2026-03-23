#!/usr/bin/env python3
import argparse
import json
import subprocess
from pathlib import Path

BASE = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
DEFAULT_MANIFEST = BASE / "configs/phase3_batch2_only_manifest.json"
RESULT_ROOT = BASE / "results/phase3_batch2_compare"
RAW_DIR = RESULT_ROOT / "raw"
LOG_DIR = RESULT_ROOT / "logs"
SUMMARY_JSON = RESULT_ROOT / "phase3_batch2_compare_summary.json"
SUMMARY_MD = RESULT_ROOT / "phase3_batch2_compare_summary.md"

MODES = ["baseline", "scaffold", "ep"]


def load_manifest(path: Path):
    data = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(data, dict) and isinstance(data.get("tasks"), list):
        return data["tasks"]
    if isinstance(data, list):
        return data
    raise RuntimeError(f"Unsupported manifest structure: {path}")


def run_grader(task_id: str, grader_path: Path, evidence_path: Path, mode: str):
    stdout_path = LOG_DIR / f"{task_id}__{mode}__grader.stdout.json"
    stderr_path = LOG_DIR / f"{task_id}__{mode}__grader.stderr.log"

    cmd = [
        "/usr/bin/python3",
        str(grader_path),
        "--evidence",
        str(evidence_path),
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
        "command": cmd,
        "returncode": proc.returncode,
        "stdout_path": str(stdout_path),
        "stderr_path": str(stderr_path),
        "parsed": parsed,
        "parse_error": parse_error,
    }


def status_from_parsed(parsed, returncode):
    if returncode != 0:
        return "runner_error"
    if not isinstance(parsed, dict):
        return "unparsed"
    try:
        score = float(parsed.get("final_score"))
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
        raise SystemExit(f"MISSING_MANIFEST={manifest_path}")

    RESULT_ROOT.mkdir(parents=True, exist_ok=True)
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    LOG_DIR.mkdir(parents=True, exist_ok=True)

    tasks = load_manifest(manifest_path)

    comparison = []
    totals = {
        "baseline": {"pass": 0, "fail": 0, "partial": 0, "runner_error": 0, "unparsed": 0, "missing_evidence": 0},
        "scaffold": {"pass": 0, "fail": 0, "partial": 0, "runner_error": 0, "unparsed": 0, "missing_evidence": 0},
        "ep": {"pass": 0, "fail": 0, "partial": 0, "runner_error": 0, "unparsed": 0, "missing_evidence": 0},
    }

    for task in tasks:
        task_id = task["task_id"]
        track = task["track"]
        task_dir = Path(task["task_dir"])
        grader_path = Path(task["grader"])

        if not grader_path.exists():
            raise RuntimeError(f"MISSING_GRADER={grader_path}")

        task_row = {
            "task_id": task_id,
            "track": track,
            "task_dir": str(task_dir),
            "modes": {}
        }

        for mode in MODES:
            evidence_path = task_dir / "evidence_examples" / f"{mode}.json"

            if not evidence_path.exists():
                result = {
                    "status": "missing_evidence",
                    "final_score": None,
                    "failure_mode": "",
                    "failure_modes": [],
                    "evidence_path": str(evidence_path),
                    "grader_stdout": "",
                    "grader_stderr": "",
                    "grader_returncode": None,
                    "grader_parse_error": "",
                }
                totals[mode]["missing_evidence"] += 1
            else:
                run = run_grader(task_id, grader_path, evidence_path, mode)
                parsed = run["parsed"] if isinstance(run["parsed"], dict) else {}
                status = status_from_parsed(run["parsed"], run["returncode"])
                result = {
                    "status": status,
                    "final_score": parsed.get("final_score"),
                    "failure_mode": parsed.get("failure_mode", ""),
                    "failure_modes": parsed.get("failure_modes", []),
                    "evidence_path": str(evidence_path),
                    "grader_stdout": run["stdout_path"],
                    "grader_stderr": run["stderr_path"],
                    "grader_returncode": run["returncode"],
                    "grader_parse_error": run["parse_error"],
                }
                totals[mode][status] += 1

            task_row["modes"][mode] = result

        raw_path = RAW_DIR / f"{task_id}__comparison.json"
        raw_path.write_text(json.dumps(task_row, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        comparison.append(task_row)

    summary = {
        "batch_id": "phase3_batch2_compare",
        "manifest": str(manifest_path),
        "modes": MODES,
        "task_count": len(comparison),
        "totals": totals,
        "tasks": comparison,
    }

    SUMMARY_JSON.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    lines = []
    lines.append("# Phase 3 Batch 2 Comparative Summary")
    lines.append("")
    lines.append(f"- Manifest: `{manifest_path}`")
    lines.append(f"- Task count: `{len(comparison)}`")
    lines.append("")
    lines.append("## Mode Totals")
    lines.append("")
    for mode in MODES:
        t = totals[mode]
        lines.append(
            f"- `{mode}` | pass=`{t['pass']}` | fail=`{t['fail']}` | partial=`{t['partial']}` | "
            f"runner_error=`{t['runner_error']}` | unparsed=`{t['unparsed']}` | missing_evidence=`{t['missing_evidence']}`"
        )
    lines.append("")
    lines.append("## Task-by-Task")
    lines.append("")
    for row in comparison:
        lines.append(f"### {row['task_id']}  ({row['track']})")
        lines.append("")
        for mode in MODES:
            r = row["modes"][mode]
            lines.append(
                f"- `{mode}` | status=`{r['status']}` | final_score=`{r['final_score']}` | evidence=`{r['evidence_path']}`"
            )
        lines.append("")
    SUMMARY_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

    print("RUN_PHASE3_BATCH2_COMPARE_OK")
    print(f"SUMMARY_JSON={SUMMARY_JSON}")
    print(f"SUMMARY_MD={SUMMARY_MD}")
    for mode in MODES:
        t = totals[mode]
        print(
            f"{mode.upper()}_TOTALS="
            f"pass:{t['pass']},fail:{t['fail']},partial:{t['partial']},"
            f"runner_error:{t['runner_error']},unparsed:{t['unparsed']},missing_evidence:{t['missing_evidence']}"
        )


if __name__ == "__main__":
    main()
