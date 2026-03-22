#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks"

###############################################################################
# TERM_022
###############################################################################
TERM022="$BASE/terminal/TERM_022"
TERM041="$BASE/terminal/TERM_041"
TOOL024="$BASE/tool_routing/TOOL_024"
TOOL029="$BASE/tool_routing/TOOL_029"
SWE021="$BASE/swe/SWE_021"
SWE027="$BASE/swe/SWE_027"

/bin/mkdir -p "$TERM022/env/logs/app" "$TERM022/key" "$TERM022/evaluator"
/bin/cat > "$TERM022/env/logs/app/runtime.log" <<'EOT'
2026-03-02T08:00:01Z INFO gateway warmup complete
2026-03-02T08:04:11Z WARN cache latency elevated
2026-03-02T08:05:17Z INFO worker heartbeat ok
2026-03-02T08:06:30Z ERROR crash component=invoice-worker signal=11
2026-03-02T08:06:31Z ERROR crash component=invoice-worker stack frame 1
2026-03-02T08:06:32Z ERROR crash component=invoice-worker stack frame 2
2026-03-02T08:06:33Z ERROR crash component=invoice-worker stack frame 3
2026-03-02T08:06:34Z ERROR crash component=invoice-worker shutdown complete
2026-03-02T08:08:12Z INFO recovery process started
EOT
/bin/cat > "$TERM022/key/answer.json" <<'EOT'
{
  "task_id": "TERM_022",
  "expected_start_timestamp": "2026-03-02T08:06:30Z",
  "expected_end_timestamp": "2026-03-02T08:06:34Z",
  "expected_crash_component": "invoice-worker"
}
EOT
/bin/cat > "$TERM022/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_022")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "start_timestamp": cand.get("start_timestamp") == KEY["expected_start_timestamp"],
        "end_timestamp": cand.get("end_timestamp") == KEY["expected_end_timestamp"],
        "crash_component": cand.get("crash_component") == KEY["expected_crash_component"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "start_timestamp": KEY["expected_start_timestamp"],
            "end_timestamp": KEY["expected_end_timestamp"],
            "crash_component": KEY["expected_crash_component"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
EOT
/bin/chmod +x "$TERM022/evaluator/evaluate.py"

###############################################################################
# TERM_041
###############################################################################
/bin/mkdir -p "$TERM041/env/archive" "$TERM041/env/current" "$TERM041/key" "$TERM041/evaluator"
/bin/cat > "$TERM041/env/archive/deploy_state.json" <<'EOT'
{
  "deployment_target": "blue-cluster",
  "build_number": "8841",
  "active_environment": "staging"
}
EOT
/bin/cat > "$TERM041/env/current/deploy_state.json" <<'EOT'
{
  "deployment_target": "green-cluster",
  "build_number": "9107",
  "active_environment": "production"
}
EOT
/bin/cat > "$TERM041/key/answer.json" <<'EOT'
{
  "task_id": "TERM_041",
  "expected_deployment_target": "green-cluster",
  "expected_build_number": "9107",
  "expected_active_environment": "production"
}
EOT
/bin/cat > "$TERM041/evaluator/evaluate.py" <<'EOT'
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
EOT
/bin/chmod +x "$TERM041/evaluator/evaluate.py"

###############################################################################
# TOOL_024
###############################################################################
/bin/mkdir -p "$TOOL024/env/retrieval_a" "$TOOL024/env/retrieval_b" "$TOOL024/key" "$TOOL024/evaluator"
/bin/cat > "$TOOL024/env/retrieval_a/result.txt" <<'EOT'
Primary source note

Product: Polaris Edge
Status: draft
Possible release month: April 2023
This source does not contain the verified public confirmation line.
EOT
/bin/cat > "$TOOL024/env/retrieval_b/result.txt" <<'EOT'
Verified public note

Polaris Edge became generally available in May 2023.

Evidence snippet:
Polaris Edge became generally available in May 2023 after the controlled rollout concluded in April.
EOT
/bin/cat > "$TOOL024/key/answer.json" <<'EOT'
{
  "task_id": "TOOL_024",
  "expected_tool_sequence": ["retrieval_a", "retrieval_b"],
  "expected_final_answer": "May 2023",
  "expected_evidence_snippet": "Polaris Edge became generally available in May 2023 after the controlled rollout concluded in April."
}
EOT
/bin/cat > "$TOOL024/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_024")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "tool_sequence": cand.get("tool_sequence") == KEY["expected_tool_sequence"],
        "final_answer": cand.get("final_answer") == KEY["expected_final_answer"],
        "evidence_snippet": cand.get("evidence_snippet") == KEY["expected_evidence_snippet"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "tool_sequence": KEY["expected_tool_sequence"],
            "final_answer": KEY["expected_final_answer"],
            "evidence_snippet": KEY["expected_evidence_snippet"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
EOT
/bin/chmod +x "$TOOL024/evaluator/evaluate.py"

###############################################################################
# TOOL_029
###############################################################################
/bin/mkdir -p "$TOOL029/env/files" "$TOOL029/key" "$TOOL029/evaluator"
/bin/cat > "$TOOL029/env/files/overwrite_manifest.json" <<'EOT'
{
  "targets": [
    {"path": "files/service_config.yaml", "overwrite": true},
    {"path": "files/readme.txt", "overwrite": false}
  ]
}
EOT
/bin/cat > "$TOOL029/key/answer.json" <<'EOT'
{
  "task_id": "TOOL_029",
  "expected_overwrite_target": "files/service_config.yaml",
  "expected_checkpoint_triggered": true,
  "expected_final_approved_result": "files/service_config.yaml"
}
EOT
/bin/cat > "$TOOL029/evaluator/evaluate.py" <<'EOT'
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
EOT
/bin/chmod +x "$TOOL029/evaluator/evaluate.py"

###############################################################################
# SWE_021
###############################################################################
/bin/mkdir -p "$SWE021/env/repo/app" "$SWE021/env/repo/tests" "$SWE021/key" "$SWE021/evaluator"
/bin/cat > "$SWE021/env/repo/app/boundary.py" <<'EOT'
def first_items(values, n):
    return values[: n + 1]
EOT
/bin/cat > "$SWE021/env/repo/tests/test_boundary.py" <<'EOT'
import unittest
from app.boundary import first_items

class TestBoundary(unittest.TestCase):
    def test_three(self):
        self.assertEqual(first_items([1,2,3,4], 3), [1,2,3])
    def test_zero(self):
        self.assertEqual(first_items([8,9], 0), [])
    def test_one(self):
        self.assertEqual(first_items([5,6,7], 1), [5])

if __name__ == "__main__":
    unittest.main()
EOT
/bin/cat > "$SWE021/env/repo/run_tests.py" <<'EOT'
#!/usr/bin/env python3
import subprocess, sys
from pathlib import Path
repo = Path(__file__).resolve().parent
proc = subprocess.run(
    [sys.executable, "-m", "unittest", "discover", "-s", str(repo / "tests"), "-v"],
    cwd=str(repo), text=True, capture_output=True
)
print(proc.stdout, end="")
print(proc.stderr, end="")
sys.exit(proc.returncode)
EOT
/bin/chmod +x "$SWE021/env/repo/run_tests.py"
/bin/cat > "$SWE021/key/answer.json" <<'EOT'
{
  "task_id": "SWE_021",
  "expected_file": "app/boundary.py",
  "expected_required_snippet": "return values[:n]"
}
EOT
/bin/cat > "$SWE021/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, subprocess, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_021")
REPO = BASE / "env" / "repo"
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    source = (REPO / KEY["expected_file"]).read_text(encoding="utf-8").replace(" ", "")
    snippet_ok = KEY["expected_required_snippet"].replace(" ", "") in source
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
EOT
/bin/chmod +x "$SWE021/evaluator/evaluate.py"
/bin/cat > "$SWE021/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_021/env/repo"
/bin/cat > "$REPO/app/boundary.py" <<'EOF2'
def first_items(values, n):
    return values[: n + 1]
EOF2
EOT
/bin/chmod +x "$SWE021/reset_repo.sh"

###############################################################################
# SWE_027
###############################################################################
/bin/mkdir -p "$SWE027/env/repo/app" "$SWE027/env/repo/tests" "$SWE027/key" "$SWE027/evaluator"
/bin/cat > "$SWE027/env/repo/app/parser.py" <<'EOT'
import re

def extract_order_id(text):
    m = re.search(r"order-\d+", text)
    return None if m is None else m.group(0)
EOT
/bin/cat > "$SWE027/env/repo/tests/test_parser.py" <<'EOT'
import unittest
from app.parser import extract_order_id

class TestParser(unittest.TestCase):
    def test_good(self):
        self.assertEqual(extract_order_id("id=order-1234 done"), "order-1234")
    def test_bad_suffix(self):
        self.assertIsNone(extract_order_id("id=order-1234x done"))
    def test_missing(self):
        self.assertIsNone(extract_order_id("nothing here"))

if __name__ == "__main__":
    unittest.main()
EOT
/bin/cat > "$SWE027/env/repo/run_tests.py" <<'EOT'
#!/usr/bin/env python3
import subprocess, sys
from pathlib import Path
repo = Path(__file__).resolve().parent
proc = subprocess.run(
    [sys.executable, "-m", "unittest", "discover", "-s", str(repo / "tests"), "-v"],
    cwd=str(repo), text=True, capture_output=True
)
print(proc.stdout, end="")
print(proc.stderr, end="")
sys.exit(proc.returncode)
EOT
/bin/chmod +x "$SWE027/env/repo/run_tests.py"
/bin/cat > "$SWE027/key/answer.json" <<'EOT'
{
  "task_id": "SWE_027",
  "expected_file": "app/parser.py",
  "expected_required_snippet": "r\"order-\\d+(?![A-Za-z0-9_])\""
}
EOT
/bin/cat > "$SWE027/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, subprocess, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_027")
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
EOT
/bin/chmod +x "$SWE027/evaluator/evaluate.py"
/bin/cat > "$SWE027/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_027/env/repo"
/bin/cat > "$REPO/app/parser.py" <<'EOF2'
import re

def extract_order_id(text):
    m = re.search(r"order-\d+", text)
    return None if m is None else m.group(0)
EOF2
EOT
/bin/chmod +x "$SWE027/reset_repo.sh"

###############################################################################
# Smoke checks
###############################################################################
/usr/bin/python3 "$TERM022/evaluator/evaluate.py" <(printf '%s\n' '{"start_timestamp":"2026-03-02T08:06:30Z","end_timestamp":"2026-03-02T08:06:34Z","crash_component":"invoice-worker"}') || true
/usr/bin/python3 "$TERM041/evaluator/evaluate.py" <(printf '%s\n' '{"deployment_target":"green-cluster","build_number":"9107","active_environment":"production"}') || true
/usr/bin/python3 "$TOOL024/evaluator/evaluate.py" <(printf '%s\n' '{"tool_sequence":["retrieval_a","retrieval_b"],"final_answer":"May 2023","evidence_snippet":"Polaris Edge became generally available in May 2023 after the controlled rollout concluded in April."}') || true
/usr/bin/python3 "$TOOL029/evaluator/evaluate.py" <(printf '%s\n' '{"overwrite_target":"files/service_config.yaml","checkpoint_triggered":true,"final_approved_result":"files/service_config.yaml"}') || true
/usr/bin/python3 "$SWE021/env/repo/run_tests.py" || true
/usr/bin/python3 "$SWE021/evaluator/evaluate.py" || true
/usr/bin/python3 "$SWE027/env/repo/run_tests.py" || true
/usr/bin/python3 "$SWE027/evaluator/evaluate.py" || true

/bin/echo "Built Phase 2 batch 1 environments and evaluators."
