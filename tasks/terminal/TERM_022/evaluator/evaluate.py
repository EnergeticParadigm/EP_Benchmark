#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_022")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "start_timestamp": cand.get("start_timestamp") == KEY["expected_start_timestamp"],
        "end_timestamp": cand.get("end_timestamp") == KEY["expected_end_timestamp"],
        "crash_component": cand.get("crash_component") == KEY["expected_crash_component"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "start_timestamp": KEY["expected_start_timestamp"],
            "end_timestamp": KEY["expected_end_timestamp"],
            "crash_component": KEY["expected_crash_component"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
