#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
SCRIPT_SH="$BASE/scripts/generate_phase3_batch2_raw_outputs.sh"
SCRIPT_PY="$BASE/scripts/generate_phase3_batch2_raw_outputs.py"
MANIFEST="$BASE/configs/phase3_batch2_only_manifest.json"
RESULT_RAW_DIR="$BASE/results/raw"
RESULT_DIR="$BASE/results/phase3_batch2_raw_generation_fast"
LOG_DIR="$RESULT_DIR/logs"

mkdir -p "$RESULT_RAW_DIR" "$LOG_DIR"

if [ ! -f "$MANIFEST" ]; then
  echo "MISSING_MANIFEST=$MANIFEST"
  exit 1
fi

cat > "$SCRIPT_PY" <<'PY'
#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path

BASE = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
MANIFEST = BASE / "configs/phase3_batch2_only_manifest.json"
RAW_DIR = BASE / "results/raw"
RESULT_DIR = BASE / "results/phase3_batch2_raw_generation_fast"
LOG_DIR = RESULT_DIR / "logs"
SUMMARY_JSON = RESULT_DIR / "phase3_batch2_raw_generation_fast_summary.json"
SUMMARY_MD = RESULT_DIR / "phase3_batch2_raw_generation_fast_summary.md"

MODES = ["baseline", "scaffold", "ep"]
MAX_CANDIDATES = 5
ATTEMPT_TIMEOUT_SECONDS = 8

RESULT_DIR.mkdir(parents=True, exist_ok=True)
LOG_DIR.mkdir(parents=True, exist_ok=True)
RAW_DIR.mkdir(parents=True, exist_ok=True)

def load_manifest(path: Path):
    data = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(data, dict) and isinstance(data.get("tasks"), list):
        return data["tasks"]
    if isinstance(data, list):
        return data
    raise RuntimeError("Unsupported manifest structure: " + str(path))

def detect_candidate_runners():
    candidates = []
    search_roots = [BASE / "scripts", BASE / "runner"]
    preferred_names = {
        "run_phase3_only.py",
        "run_phase3_batch2_real.py",
        "run_phase3_batch2_compare.py",
        "run_phase3_batch2_real.sh",
        "run_phase3_batch2_compare.sh",
    }

    for root in search_roots:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if not path.is_file():
                continue
            if path.suffix not in {".py", ".sh"}:
                continue

            score = 0
            name = path.name
            try:
                text = path.read_text(encoding="utf-8", errors="ignore")
            except Exception:
                text = ""

            if name in preferred_names:
                score += 10
            for token in ["phase3", "manifest", "baseline", "scaffold", "ep", "task_id", "results/raw"]:
                if token in name or token in text:
                    score += 1

            if score > 0:
                candidates.append((score, path))

    candidates.sort(key=lambda x: (-x[0], str(x[1])))

    dedup = []
    seen = set()
    for score, path in candidates:
        s = str(path)
        if s not in seen:
            seen.add(s)
            dedup.append(path)

    return dedup[:MAX_CANDIDATES]

def output_candidates(task_id: str, mode: str):
    outputs = [RAW_DIR / f"{task_id}__{mode}.json"]
    if mode == "scaffold":
        outputs.append(RAW_DIR / f"{task_id}__baseline_scaffold.json")
    return outputs

def valid_raw_output(path: Path):
    if not path.exists():
        return False
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return False
    return isinstance(data, dict)

def build_attempt_commands(runner: Path, task_id: str, mode: str, output_path: Path):
    if runner.suffix == ".py":
        base = ["/usr/bin/python3", str(runner)]
    else:
        base = [str(runner)]

    return [
        base + ["--task-id", task_id, "--mode", mode, "--output", str(output_path)],
        base + ["--task", task_id, "--mode", mode, "--output", str(output_path)],
        base + ["--manifest", str(MANIFEST)],
    ]

tasks = load_manifest(MANIFEST)
candidate_runners = detect_candidate_runners()

summary = {
    "status": "unknown",
    "manifest": str(MANIFEST),
    "candidate_runners": [str(p) for p in candidate_runners],
    "tasks": [],
    "generated_count": 0,
    "failed_count": 0,
}

for task in tasks:
    task_id = task["task_id"]
    task_result = {"task_id": task_id, "track": task.get("track", ""), "modes": {}}

    for mode in MODES:
        mode_result = {
            "status": "failed",
            "runner_used": "",
            "command": [],
            "output_path": "",
            "log_stdout": "",
            "log_stderr": "",
            "notes": [],
        }

        targets = output_candidates(task_id, mode)

        existing = None
        for out in targets:
            if valid_raw_output(out):
                existing = out
                break

        if existing is not None:
            mode_result["status"] = "already_present"
            mode_result["output_path"] = str(existing)
            mode_result["notes"].append("valid raw output already present")
            summary["generated_count"] += 1
            task_result["modes"][mode] = mode_result
            continue

        done = False
        for runner in candidate_runners:
            attempts = build_attempt_commands(runner, task_id, mode, targets[0])

            for idx, cmd in enumerate(attempts, start=1):
                stdout_log = LOG_DIR / f"{task_id}__{mode}__{runner.name}__a{idx}.stdout.log"
                stderr_log = LOG_DIR / f"{task_id}__{mode}__{runner.name}__a{idx}.stderr.log"

                try:
                    proc = subprocess.run(
                        cmd,
                        stdout=subprocess.PIPE,
                        stderr=subprocess.PIPE,
                        text=True,
                        encoding="utf-8",
                        errors="replace",
                        timeout=ATTEMPT_TIMEOUT_SECONDS,
                    )
                    stdout_log.write_text(proc.stdout, encoding="utf-8")
                    stderr_log.write_text(proc.stderr, encoding="utf-8")
                except subprocess.TimeoutExpired:
                    stdout_log.write_text("", encoding="utf-8")
                    stderr_log.write_text(f"timeout_after_{ATTEMPT_TIMEOUT_SECONDS}_seconds\n", encoding="utf-8")
                    continue
                except Exception as exc:
                    stdout_log.write_text("", encoding="utf-8")
                    stderr_log.write_text(str(exc) + "\n", encoding="utf-8")
                    continue

                found = None
                for out in targets:
                    if valid_raw_output(out):
                        found = out
                        break

                if found is not None:
                    mode_result["status"] = "generated"
                    mode_result["runner_used"] = str(runner)
                    mode_result["command"] = cmd
                    mode_result["output_path"] = str(found)
                    mode_result["log_stdout"] = str(stdout_log)
                    mode_result["log_stderr"] = str(stderr_log)
                    mode_result["notes"].append("returncode=" + str(proc.returncode))
                    summary["generated_count"] += 1
                    done = True
                    break

            if done:
                break

        if not done:
            summary["failed_count"] += 1

        task_result["modes"][mode] = mode_result

    summary["tasks"].append(task_result)

summary["status"] = "ok" if summary["failed_count"] == 0 else "partial"

SUMMARY_JSON.write_text(json.dumps(summary, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

lines = []
lines.append("# Phase 3 Batch 2 Raw Output Generation Fast Summary")
lines.append("")
lines.append(f"- Status: `{summary['status']}`")
lines.append(f"- Generated or already present: `{summary['generated_count']}`")
lines.append(f"- Failed: `{summary['failed_count']}`")
lines.append("")
lines.append("## Candidate runners")
lines.append("")
for runner in summary["candidate_runners"]:
    lines.append(f"- `{runner}`")
lines.append("")
lines.append("## Task × Mode")
lines.append("")
for task in summary["tasks"]:
    lines.append(f"### {task['task_id']}")
    lines.append("")
    for mode in MODES:
        r = task["modes"][mode]
        lines.append(f"- `{mode}` | status=`{r['status']}` | output=`{r['output_path']}`")
    lines.append("")
SUMMARY_MD.write_text("\n".join(lines) + "\n", encoding="utf-8")

print("RAW_GENERATION_SUMMARY_JSON=" + str(SUMMARY_JSON))
print("RAW_GENERATION_SUMMARY_MD=" + str(SUMMARY_MD))
print("STATUS=" + summary["status"])
print("GENERATED_COUNT=" + str(summary["generated_count"]))
print("FAILED_COUNT=" + str(summary["failed_count"]))
PY

cat > "$SCRIPT_SH" <<'SH'
#!/bin/bash
set -euo pipefail
/usr/bin/python3 /Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1/scripts/generate_phase3_batch2_raw_outputs.py
SH

chmod +x "$SCRIPT_PY"
chmod +x "$SCRIPT_SH"

/usr/bin/python3 "$SCRIPT_PY"
