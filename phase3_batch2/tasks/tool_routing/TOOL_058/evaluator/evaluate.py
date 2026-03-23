#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_058")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "export_target": cand.get("export_target") == KEY["expected_export_target"],
        "checkpoint_state": bool(cand.get("checkpoint_state")) is bool(KEY["expected_checkpoint_state"]),
        "final_export_status": cand.get("final_export_status") == KEY["expected_final_export_status"]
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "export_target": KEY["expected_export_target"],
            "checkpoint_state": KEY["expected_checkpoint_state"],
            "final_export_status": KEY["expected_final_export_status"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
