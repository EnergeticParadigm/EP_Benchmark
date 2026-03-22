#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_041")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "deployment_target": cand.get("deployment_target") == KEY["expected_deployment_target"],
        "build_number": cand.get("build_number") == KEY["expected_build_number"],
        "active_environment": cand.get("active_environment") == KEY["expected_active_environment"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "deployment_target": KEY["expected_deployment_target"],
            "build_number": KEY["expected_build_number"],
            "active_environment": KEY["expected_active_environment"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
