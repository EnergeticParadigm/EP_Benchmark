#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_010")
KEY_PATH = BASE / "key" / "answer.json"

def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: evaluate.py /absolute/path/to/candidate.json")
        sys.exit(2)

    candidate_path = Path(sys.argv[1])
    if not candidate_path.exists():
        print(json.dumps({
            "success": False,
            "error": "candidate_file_not_found"
        }, indent=2))
        sys.exit(1)

    key = json.loads(KEY_PATH.read_text(encoding="utf-8"))
    candidate = json.loads(candidate_path.read_text(encoding="utf-8"))

    test_ok = candidate.get("failing_test_name") == key["expected_failing_test_name"]
    err_ok = candidate.get("error_type") == key["expected_error_type"]
    path_ok = candidate.get("first_stacktrace_file_path") == key["expected_first_stacktrace_file_path"]

    success = test_ok and err_ok and path_ok

    print(json.dumps({
        "task_id": key["task_id"],
        "success": success,
        "checks": {
            "failing_test_name": test_ok,
            "error_type": err_ok,
            "first_stacktrace_file_path": path_ok
        },
        "expected": {
            "failing_test_name": key["expected_failing_test_name"],
            "error_type": key["expected_error_type"],
            "first_stacktrace_file_path": key["expected_first_stacktrace_file_path"]
        },
        "candidate": {
            "failing_test_name": candidate.get("failing_test_name"),
            "error_type": candidate.get("error_type"),
            "first_stacktrace_file_path": candidate.get("first_stacktrace_file_path")
        }
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
