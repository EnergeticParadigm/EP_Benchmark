#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_015")
KEY_PATH = BASE / "key" / "answer.json"
REPO_DIR = BASE / "env" / "repo"

def main() -> None:
    key = json.loads(KEY_PATH.read_text(encoding="utf-8"))
    target_file = REPO_DIR / key["expected_file"]

    if not target_file.exists():
        print(json.dumps({
            "task_id": key["task_id"],
            "success": False,
            "error": "target_file_not_found"
        }, indent=2))
        sys.exit(1)

    source = target_file.read_text(encoding="utf-8")
    snippet_ok = key["expected_required_snippet"] in source

    proc = subprocess.run(
        ["/usr/bin/python3", "run_tests.py"],
        cwd=str(REPO_DIR),
        text=True,
        capture_output=True
    )

    tests_ok = proc.returncode == 0

    print(json.dumps({
        "task_id": key["task_id"],
        "success": bool(snippet_ok and tests_ok),
        "checks": {
            "required_snippet_present": snippet_ok,
            "tests_pass": tests_ok
        },
        "expected": {
            "file": key["expected_file"],
            "required_snippet": key["expected_required_snippet"]
        },
        "test_output": proc.stdout + proc.stderr
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if (snippet_ok and tests_ok) else 1)

if __name__ == "__main__":
    main()
