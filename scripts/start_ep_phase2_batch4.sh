#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks"

TOOL051="$BASE/tool_routing/TOOL_051"
SWE036="$BASE/swe/SWE_036"
SWE048="$BASE/swe/SWE_048"
SWE053="$BASE/swe/SWE_053"
SWE059="$BASE/swe/SWE_059"

###############################################################################
# TOOL_051
###############################################################################
/bin/mkdir -p "$TOOL051/env/retrieval_a" "$TOOL051/env/retrieval_b" "$TOOL051/key" "$TOOL051/evaluator"
/bin/cat > "$TOOL051/env/retrieval_a/incident_note.txt" <<'EOT'
Initial incident note

Region candidate: west
Confidence: low
This first route is incomplete and should not be trusted as final.
EOT
/bin/cat > "$TOOL051/env/retrieval_b/incident_note.txt" <<'EOT'
Verified incident note

Region: east
Failed nodes: 12

Evidence:
The verified recovery report confirms that the outage was isolated to the east region and affected 12 nodes.
EOT
/bin/cat > "$TOOL051/key/answer.json" <<'EOT'
{
  "task_id": "TOOL_051",
  "expected_tool_sequence": ["retrieval_a", "retrieval_b"],
  "expected_final_answer": "east|12",
  "expected_evidence_snippet": "The verified recovery report confirms that the outage was isolated to the east region and affected 12 nodes."
}
EOT
/bin/cat > "$TOOL051/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, sys
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_051")
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
/bin/chmod +x "$TOOL051/evaluator/evaluate.py"

###############################################################################
# SWE_036
###############################################################################
/bin/mkdir -p "$SWE036/env/repo/app" "$SWE036/env/repo/tests" "$SWE036/key" "$SWE036/evaluator"
/bin/cat > "$SWE036/env/repo/app/report_state.py" <<'EOT'
def build_state(ok, code):
    if ok:
        return {"status": "ok", "code": code}
    return [code]
EOT
/bin/cat > "$SWE036/env/repo/tests/test_report_state.py" <<'EOT'
import unittest
from app.report_state import build_state

class TestReportState(unittest.TestCase):
    def test_ok_branch(self):
        self.assertEqual(build_state(True, 7), {"status": "ok", "code": 7})
    def test_fail_branch_type(self):
        result = build_state(False, 7)
        self.assertIsInstance(result, dict)
    def test_fail_branch_value(self):
        self.assertEqual(build_state(False, 7), {"status": "fail", "code": 7})

if __name__ == "__main__":
    unittest.main()
EOT
/bin/cat > "$SWE036/env/repo/run_tests.py" <<'EOT'
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
/bin/chmod +x "$SWE036/env/repo/run_tests.py"
/bin/cat > "$SWE036/key/answer.json" <<'EOT'
{
  "task_id": "SWE_036",
  "expected_file": "app/report_state.py",
  "expected_required_snippet": "return {\"status\": \"fail\", \"code\": code}"
}
EOT
/bin/cat > "$SWE036/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, subprocess
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_036")
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
/bin/chmod +x "$SWE036/evaluator/evaluate.py"
/bin/cat > "$SWE036/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_036/env/repo"
/bin/cat > "$REPO/app/report_state.py" <<'EOF2'
def build_state(ok, code):
    if ok:
        return {"status": "ok", "code": code}
    return [code]
EOF2
EOT
/bin/chmod +x "$SWE036/reset_repo.sh"

###############################################################################
# SWE_048
###############################################################################
/bin/mkdir -p "$SWE048/env/repo/app" "$SWE048/env/repo/tests" "$SWE048/key" "$SWE048/evaluator"
/bin/cat > "$SWE048/env/repo/app/first_record.py" <<'EOT'
def first_record(records):
    return records[0] if records else {}
EOT
/bin/cat > "$SWE048/env/repo/tests/test_first_record.py" <<'EOT'
import unittest
from app.first_record import first_record

class TestFirstRecord(unittest.TestCase):
    def test_empty(self):
        self.assertIsNone(first_record([]))
    def test_first(self):
        self.assertEqual(first_record([{"id": 1}, {"id": 2}]), {"id": 1})
    def test_no_mutation(self):
        data = [{"id": 3}]
        self.assertEqual(first_record(data), {"id": 3})

if __name__ == "__main__":
    unittest.main()
EOT
/bin/cat > "$SWE048/env/repo/run_tests.py" <<'EOT'
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
/bin/chmod +x "$SWE048/env/repo/run_tests.py"
/bin/cat > "$SWE048/key/answer.json" <<'EOT'
{
  "task_id": "SWE_048",
  "expected_file": "app/first_record.py",
  "expected_required_snippet": "return records[0] if records else None"
}
EOT
/bin/cat > "$SWE048/evaluator/evaluate.py" <<'EOT'
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
EOT
/bin/chmod +x "$SWE048/evaluator/evaluate.py"
/bin/cat > "$SWE048/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_048/env/repo"
/bin/cat > "$REPO/app/first_record.py" <<'EOF2'
def first_record(records):
    return records[0] if records else {}
EOF2
EOT
/bin/chmod +x "$SWE048/reset_repo.sh"

###############################################################################
# SWE_053
###############################################################################
/bin/mkdir -p "$SWE053/env/repo/app" "$SWE053/env/repo/tests" "$SWE053/key" "$SWE053/evaluator"
/bin/cat > "$SWE053/env/repo/app/normalize_name.py" <<'EOT'
def normalize_name(name):
    return name.strip().lower().replace(" ", "")
EOT
/bin/cat > "$SWE053/env/repo/tests/test_normalize_name.py" <<'EOT'
import unittest
from app.normalize_name import normalize_name

class TestNormalizeName(unittest.TestCase):
    def test_spaces(self):
        self.assertEqual(normalize_name("  Alice Bob  "), "alice_bob")
    def test_case(self):
        self.assertEqual(normalize_name("CAROL"), "carol")
    def test_inner_space(self):
        self.assertEqual(normalize_name("Dan Eve"), "dan_eve")

if __name__ == "__main__":
    unittest.main()
EOT
/bin/cat > "$SWE053/env/repo/run_tests.py" <<'EOT'
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
/bin/chmod +x "$SWE053/env/repo/run_tests.py"
/bin/cat > "$SWE053/key/answer.json" <<'EOT'
{
  "task_id": "SWE_053",
  "expected_file": "app/normalize_name.py",
  "expected_required_snippet": "replace(\" \", \"_\")"
}
EOT
/bin/cat > "$SWE053/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, subprocess
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_053")
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
/bin/chmod +x "$SWE053/evaluator/evaluate.py"
/bin/cat > "$SWE053/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_053/env/repo"
/bin/cat > "$REPO/app/normalize_name.py" <<'EOF2'
def normalize_name(name):
    return name.strip().lower().replace(" ", "")
EOF2
EOT
/bin/chmod +x "$SWE053/reset_repo.sh"

###############################################################################
# SWE_059
###############################################################################
/bin/mkdir -p "$SWE059/env/repo/app" "$SWE059/env/repo/tests" "$SWE059/key" "$SWE059/evaluator"
/bin/cat > "$SWE059/env/repo/app/score_label.py" <<'EOT'
def score_label(score):
    if score >= 80:
        return "gold"
    if score >= 50:
        return "silver"
    return "silver"
EOT
/bin/cat > "$SWE059/env/repo/tests/test_score_label.py" <<'EOT'
import unittest
from app.score_label import score_label

class TestScoreLabel(unittest.TestCase):
    def test_gold(self):
        self.assertEqual(score_label(95), "gold")
    def test_silver(self):
        self.assertEqual(score_label(60), "silver")
    def test_bronze(self):
        self.assertEqual(score_label(20), "bronze")

if __name__ == "__main__":
    unittest.main()
EOT
/bin/cat > "$SWE059/env/repo/run_tests.py" <<'EOT'
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
/bin/chmod +x "$SWE059/env/repo/run_tests.py"
/bin/cat > "$SWE059/key/answer.json" <<'EOT'
{
  "task_id": "SWE_059",
  "expected_file": "app/score_label.py",
  "expected_required_snippet": "return \"bronze\""
}
EOT
/bin/cat > "$SWE059/evaluator/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json, subprocess
from pathlib import Path
BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_059")
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
/bin/chmod +x "$SWE059/evaluator/evaluate.py"
/bin/cat > "$SWE059/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_059/env/repo"
/bin/cat > "$REPO/app/score_label.py" <<'EOF2'
def score_label(score):
    if score >= 80:
        return "gold"
    if score >= 50:
        return "silver"
    return "silver"
EOF2
EOT
/bin/chmod +x "$SWE059/reset_repo.sh"

###############################################################################
# Smoke checks
###############################################################################
/usr/bin/python3 "$TOOL051/evaluator/evaluate.py" <(printf '%s\n' '{"tool_sequence":["retrieval_a","retrieval_b"],"final_answer":"east|12","evidence_snippet":"The verified recovery report confirms that the outage was isolated to the east region and affected 12 nodes."}') || true
/usr/bin/python3 "$SWE036/env/repo/run_tests.py" || true
/usr/bin/python3 "$SWE036/evaluator/evaluate.py" || true
/usr/bin/python3 "$SWE048/env/repo/run_tests.py" || true
/usr/bin/python3 "$SWE048/evaluator/evaluate.py" || true
/usr/bin/python3 "$SWE053/env/repo/run_tests.py" || true
/usr/bin/python3 "$SWE053/evaluator/evaluate.py" || true
/usr/bin/python3 "$SWE059/env/repo/run_tests.py" || true
/usr/bin/python3 "$SWE059/evaluator/evaluate.py" || true

/bin/echo "Built final Phase 2 environments and evaluators."
