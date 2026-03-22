#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_028")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "file_path": cand.get("file_path") == KEY["expected_file_path"],
        "duplicated_key": cand.get("duplicated_key") == KEY["expected_duplicated_key"],
        "line_numbers": cand.get("line_numbers") == KEY["expected_line_numbers"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "file_path": KEY["expected_file_path"],
            "duplicated_key": KEY["expected_duplicated_key"],
            "line_numbers": KEY["expected_line_numbers"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
