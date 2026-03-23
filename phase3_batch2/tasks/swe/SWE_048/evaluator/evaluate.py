#!/usr/bin/env python3
import json, subprocess
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_048")
REPO = BASE / "env" / "repo"
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    source = (REPO / KEY["expected_file"]).read_text(encoding="utf-8")
    snippet_ok = KEY["expected_required_snippet"] in source
    proc = subprocess.run(["/usr/bin/python3", "run_tests.py"], cwd=str(REPO), text=True, capture_output=True)
    success = snippet_ok and proc.returncode == 0
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": {
            "required_snippet_present": snippet_ok,
            "tests_pass": proc.returncode == 0
        },
        "test_output": proc.stdout + proc.stderr
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
