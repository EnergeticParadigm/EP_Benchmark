#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_052")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "actor_count": cand.get("actor_count") == KEY["expected_actor_count"],
        "failed_events": cand.get("failed_events") == KEY["expected_failed_events"],
        "latest_critical_event": cand.get("latest_critical_event") == KEY["expected_latest_critical_event"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "actor_count": KEY["expected_actor_count"],
            "failed_events": KEY["expected_failed_events"],
            "latest_critical_event": KEY["expected_latest_critical_event"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
