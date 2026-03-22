#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_029")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "overwrite_target": cand.get("overwrite_target") == KEY["expected_overwrite_target"],
        "checkpoint_triggered": bool(cand.get("checkpoint_triggered")) is bool(KEY["expected_checkpoint_triggered"]),
        "final_approved_result": cand.get("final_approved_result") == KEY["expected_final_approved_result"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "overwrite_target": KEY["expected_overwrite_target"],
            "checkpoint_triggered": KEY["expected_checkpoint_triggered"],
            "final_approved_result": KEY["expected_final_approved_result"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
