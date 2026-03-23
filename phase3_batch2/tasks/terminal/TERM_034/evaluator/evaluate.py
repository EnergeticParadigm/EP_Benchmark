#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_034")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "bugfix_count": cand.get("bugfix_count") == KEY["expected_bugfix_count"],
        "security_count": cand.get("security_count") == KEY["expected_security_count"],
        "docs_count": cand.get("docs_count") == KEY["expected_docs_count"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "bugfix_count": KEY["expected_bugfix_count"],
            "security_count": KEY["expected_security_count"],
            "docs_count": KEY["expected_docs_count"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
