#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_037")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "safe_deletion_list": cand.get("safe_deletion_list") == KEY["expected_safe_deletion_list"],
        "escalation_flag": bool(cand.get("escalation_flag")) is bool(KEY["expected_escalation_flag"]),
        "final_approved_action_list": cand.get("final_approved_action_list") == KEY["expected_final_approved_action_list"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "safe_deletion_list": KEY["expected_safe_deletion_list"],
            "escalation_flag": KEY["expected_escalation_flag"],
            "final_approved_action_list": KEY["expected_final_approved_action_list"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
