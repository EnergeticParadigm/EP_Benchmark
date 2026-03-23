#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_061")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "cert_path": cand.get("cert_path") == KEY["expected_cert_path"],
        "key_path": cand.get("key_path") == KEY["expected_key_path"],
        "expiry_date": cand.get("expiry_date") == KEY["expected_expiry_date"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "cert_path": KEY["expected_cert_path"],
            "key_path": KEY["expected_key_path"],
            "expiry_date": KEY["expected_expiry_date"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
