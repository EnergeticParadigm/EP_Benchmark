#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_019")
KEY_PATH = BASE / "key" / "answer.json"

def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: evaluate.py /absolute/path/to/final_report.json")
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
    expected = key["expected_json"]

    total_ok = candidate.get("total_files") == expected["total_files"]
    valid_ok = candidate.get("valid_records") == expected["valid_records"]
    invalid_ok = candidate.get("invalid_records") == expected["invalid_records"]
    top_ok = candidate.get("top_category") == expected["top_category"]

    success = total_ok and valid_ok and invalid_ok and top_ok

    print(json.dumps({
        "task_id": key["task_id"],
        "success": success,
        "checks": {
            "total_files": total_ok,
            "valid_records": valid_ok,
            "invalid_records": invalid_ok,
            "top_category": top_ok
        },
        "expected": expected,
        "candidate": candidate
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
