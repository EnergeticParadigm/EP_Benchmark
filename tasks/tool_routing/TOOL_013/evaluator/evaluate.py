#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_013")
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

    proposed_ok = candidate.get("proposed_action_list") == key["expected_proposed_action_list"]
    final_ok = candidate.get("final_approved_action_result") == key["expected_final_approved_action_result"]
    checkpoint_ok = bool(candidate.get("checkpoint_triggered")) is bool(key["checkpoint_required"])

    success = proposed_ok and final_ok and checkpoint_ok

    print(json.dumps({
        "task_id": key["task_id"],
        "success": success,
        "checks": {
            "proposed_action_list": proposed_ok,
            "final_approved_action_result": final_ok,
            "checkpoint_triggered": checkpoint_ok
        },
        "expected": {
            "proposed_action_list": key["expected_proposed_action_list"],
            "final_approved_action_result": key["expected_final_approved_action_result"],
            "checkpoint_required": key["checkpoint_required"]
        },
        "candidate": {
            "proposed_action_list": candidate.get("proposed_action_list"),
            "final_approved_action_result": candidate.get("final_approved_action_result"),
            "checkpoint_triggered": candidate.get("checkpoint_triggered")
        }
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
