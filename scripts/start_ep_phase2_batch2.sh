#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks"

TERM028="$BASE/terminal/TERM_028"
TERM052="$BASE/terminal/TERM_052"
TOOL033="$BASE/tool_routing/TOOL_033"
TOOL037="$BASE/tool_routing/TOOL_037"
SWE024="$BASE/swe/SWE_024"
SWE031="$BASE/swe/SWE_031"

###############################################################################
# TERM_028
###############################################################################
/bin/mkdir -p "$TERM028/env/config" "$TERM028/key" "$TERM028/evaluator"
/bin/cat > "$TERM028/env/config/app_main.ini" <<'EOT'
[server]
host=10.0.0.8
port=8080
timeout=30

[cache]
enabled=true
ttl=600
EOT
/bin/cat > "$TERM028/env/config/app_override.ini" <<'EOT'
[server]
host=10.0.0.9
port=8080
timeout=45
timeout=50

[logging]
level=info
EOT
/bin/cat > "$TERM028/key/answer.json" <<'EOT'
{
  "task_id": "TERM_028",
  "expected_file_path": "config/app_override.ini",
  "expected_duplicated_key": "timeout",
  "expected_line_numbers": [4, 5]
}
EOT
/bin/cat > "$TERM028/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_028")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "file_path": cand.get("file_path") == KEY["expected_file_path"],
        "duplicated_key": cand.get("duplicated_key") == KEY["expected_duplicated_key"],
        "line_numbers": cand.get("line_numbers") == KEY["expected_line_numbers"],
    }
    success = all(checks.values())
    print(json.dumps({
        "task_id": KEY["task_id"],
        "success": success,
        "checks": checks,
        "expected": {
            "file_path": KEY["expected_file_path"],
            "duplicated_key": KEY["expected_duplicated_key"],
            "line_numbers": KEY["expected_line_numbers"]
        },
        "candidate": cand
    }, indent=2))
    raise SystemExit(0 if success else 1)
if __name__ == "__main__":
    main()
EOT
/bin/chmod +x "$TERM028/evaluator/evaluate.py"

###############################################################################
# TERM_052
###############################################################################
/bin/mkdir -p "$TERM052/env/audit" "$TERM052/key" "$TERM052/evaluator"
/bin/cat > "$TERM052/env/audit/events.jsonl" <<'EOT'
{"actor":"alice","status":"ok","severity":"low","ts":"2026-03-11T08:01:00Z","critical":false}
{"actor":"bob","status":"failed","severity":"medium","ts":"2026-03-11T08:02:00Z","critical":false}
{"actor":"alice","status":"failed","severity":"high","ts":"2026-03-11T08:03:00Z","critical":true,"event":"db-lock"}
{"actor":"carl","status":"ok","severity":"low","ts":"2026-03-11T08:04:00Z","critical":false}
{"actor":"dina","status":"failed","severity":"critical","ts":"2026-03-11T08:05:00Z","critical":true,"event":"token-breach"}
EOT
/bin/cat > "$TERM052/key/answer.json" <<'EOT'
{
  "task_id": "TERM_052",
  "expected_actor_count": 4,
  "expected_failed_events": 3,
  "expected_latest_critical_event": "token-breach"
}
EOT
/bin/cat > "$TERM052/evaluator/evaluate.py" <<'EOT'
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
EOT
/bin/chmod +x "$TERM052/evaluator/evaluate.py"

###############################################################################
# TOOL_033
###############################################################################
/bin/mkdir -p "$TOOL033/env/retrieval" "$TOOL033/key" "$TOOL033/evaluator"
/bin/cat > "$TOOL033/env/retrieval/policy_note.txt" <<'EOT'
Verified status record

Service: Aurora Mail Gateway
Verified status: suspended

Supporting note:
Aurora Mail Gateway remains suspended pending the completion of the external review.
EOT
/bin/cat > "$TOOL033/key/answer.json" <<'EOT'
{
  "task_id": "TOOL_033",
  "expected_tool_sequence": ["retrieval"],
  "expected_final_answer": "suspended"
}
EOT
/bin/cat > "$TOOL033/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_033")
KEY = json.loads((BASE / "key" / "answer.json").read_text(encoding="utf-8"))
def main():
    if len(sys.argv) != 2:
        print("Usage: evaluate.py candidate.json")
        raise SystemExit(2)
    cand = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    checks = {
        "tool_sequence": cand.get("tool_sequence") == KEY["expected_tool_sequence"],
        "final_answer": cand.get("final_answer") == KEY["expected_final_answer"],
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
EOT
/bin/chmod +x "$TOOL033/evaluator/evaluate.py"

###############################################################################
# TOOL_037
###############################################################################
/bin/mkdir -p "$TOOL037/env/files" "$TOOL037/key" "$TOOL037/evaluator"
/bin/cat > "$TOOL037/env/files/delete_manifest.json" <<'EOT'
{
  "files": [
    {"path":"files/cache.tmp","safe_delete":true,"ambiguous":false},
    {"path":"files/session.lock","safe_delete":true,"ambiguous":false},
    {"path":"files/customer_archive.zip","safe_delete":false,"ambiguous":true}
  ]
}
EOT
/bin/cat > "$TOOL037/key/answer.json" <<'EOT'
{
  "task_id": "TOOL_037",
  "expected_safe_deletion_list": ["files/cache.tmp", "files/session.lock"],
  "expected_escalation_flag": true,
  "expected_final_approved_action_list": ["files/cache.tmp", "files/session.lock"]
}
EOT
/bin/cat > "$TOOL037/evaluator/evaluate.py" <<'EOT'
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
EOT
/bin/chmod +x "$TOOL037/evaluator/evaluate.py"

###############################################################################
# SWE_024
###############################################################################
/bin/mkdir -p "$SWE024/env/repo/app" "$SWE024/env/repo/tests" "$SWE024/key" "$SWE024/evaluator"
/bin/cat > "$SWE024/env/repo/app/result_shape.py" <<'EOT'
def build_result(values):
    if not values:
        return None
    return {"count": len(values), "items": values}
EOT
/bin/cat > "$SWE024/env/repo/tests/test_result_shape.py" <<'EOT'
import unittest
from app.result_shape import build_result

class TestResultShape(unittest.TestCase):
    def test_empty(self):
        self.assertEqual(build_result([]), {"count": 0, "items": []})
    def test_non_empty(self):
        self.assertEqual(build_result([1,2]), {"count": 2, "items": [1,2]})
    def test_keys(self):
        self.assertEqual(set(build_result([]).keys()), {"count", "items"})

if __name__ == "__main__":
    unittest.main()
EOT
/bin/cat > "$SWE024/env/repo/run_tests.py" <<'EOT'
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
/bin/chmod +x "$SWE024/env/repo/run_tests.py"
/bin/cat > "$SWE024/key/answer.json" <<'EOT'
{
  "task_id": "SWE_024",
  "expected_file": "app/result_shape.py",
  "expected_required_snippet": "return {\"count\": 0, \"items\": []}"
}
EOT
/bin/cat > "$SWE024/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, subprocess
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_024")
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
/bin/chmod +x "$SWE024/evaluator/evaluate.py"
/bin/cat > "$SWE024/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_024/env/repo"
/bin/cat > "$REPO/app/result_shape.py" <<'EOF2'
def build_result(values):
    if not values:
        return None
    return {"count": len(values), "items": values}
EOF2
EOT
/bin/chmod +x "$SWE024/reset_repo.sh"

###############################################################################
# SWE_031
###############################################################################
/bin/mkdir -p "$SWE031/env/repo/app" "$SWE031/env/repo/tests" "$SWE031/key" "$SWE031/evaluator"
/bin/cat > "$SWE031/env/repo/app/cache_key.py" <<'EOT'
def make_cache_key(user_id, region):
    return f"{user_id}"

def build_payload(user_id, region):
    return {"cache_key": make_cache_key(user_id, region)}
EOT
/bin/cat > "$SWE031/env/repo/tests/test_cache_key.py" <<'EOT'
import unittest
from app.cache_key import build_payload

class TestCacheKey(unittest.TestCase):
    def test_us(self):
        self.assertEqual(build_payload("u17", "us")["cache_key"], "u17:us")
    def test_eu(self):
        self.assertEqual(build_payload("u17", "eu")["cache_key"], "u17:eu")
    def test_distinct(self):
        self.assertNotEqual(build_payload("u17", "us")["cache_key"], build_payload("u17", "eu")["cache_key"])

if __name__ == "__main__":
    unittest.main()
EOT
/bin/cat > "$SWE031/env/repo/run_tests.py" <<'EOT'
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
/bin/chmod +x "$SWE031/env/repo/run_tests.py"
/bin/cat > "$SWE031/key/answer.json" <<'EOT'
{
  "task_id": "SWE_031",
  "expected_file": "app/cache_key.py",
  "expected_required_snippet": "return f\"{user_id}:{region}\""
}
EOT
/bin/cat > "$SWE031/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, subprocess
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_031")
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
/bin/chmod +x "$SWE031/evaluator/evaluate.py"
/bin/cat > "$SWE031/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_031/env/repo"
/bin/cat > "$REPO/app/cache_key.py" <<'EOF2'
def make_cache_key(user_id, region):
    return f"{user_id}"

def build_payload(user_id, region):
    return {"cache_key": make_cache_key(user_id, region)}
EOF2
EOT
/bin/chmod +x "$SWE031/reset_repo.sh"

###############################################################################
# Smoke checks
###############################################################################
/usr/bin/python3 "$TERM028/evaluator/evaluate.py" <(printf '%s\n' '{"file_path":"config/app_override.ini","duplicated_key":"timeout","line_numbers":[4,5]}') || true
/usr/bin/python3 "$TERM052/evaluator/evaluate.py" <(printf '%s\n' '{"actor_count":4,"failed_events":3,"latest_critical_event":"token-breach"}') || true
/usr/bin/python3 "$TOOL033/evaluator/evaluate.py" <(printf '%s\n' '{"tool_sequence":["retrieval"],"final_answer":"suspended"}') || true
/usr/bin/python3 "$TOOL037/evaluator/evaluate.py" <(printf '%s\n' '{"safe_deletion_list":["files/cache.tmp","files/session.lock"],"escalation_flag":true,"final_approved_action_list":["files/cache.tmp","files/session.lock"]}') || true
/usr/bin/python3 "$SWE024/env/repo/run_tests.py" || true
/usr/bin/python3 "$SWE024/evaluator/evaluate.py" || true
/usr/bin/python3 "$SWE031/env/repo/run_tests.py" || true
/usr/bin/python3 "$SWE031/evaluator/evaluate.py" || true

/bin/echo "Built Phase 2 batch 2 environments and evaluators."
