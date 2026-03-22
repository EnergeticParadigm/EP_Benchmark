#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_044")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "tool_sequence": cand.get("tool_sequence") == KEY["expected_tool_sequence"],
        "final_answer": cand.get("final_answer") == KEY["expected_final_answer"]
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "tool_sequence": KEY["expected_tool_sequence"],
            "final_answer": KEY["expected_final_answer"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
