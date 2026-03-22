#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_010"
ENV_DIR="$BASE/env"
KEY_DIR="$BASE/key"
EVAL_DIR="$BASE/evaluator"
REPO_DIR="$ENV_DIR/repo"

/bin/mkdir -p \
  "$REPO_DIR/app" \
  "$REPO_DIR/tests" \
  "$KEY_DIR" \
  "$EVAL_DIR"

#/ Buggy source
/bin/cat > "$REPO_DIR/app/formatter.py" <<'EOT'
def normalize_result(flag, value):
    if flag:
        return {"result": value}
    return [value]
EOT

# Tests
/bin/cat > "$REPO_DIR/tests/test_formatter.py" <<'EOT'
import unittest
from app.formatter import normalize_result

class TestFormatter(unittest.TestCase):
    def test_true_branch(self):
        self.assertEqual(normalize_result(True, 7), {"result": 7})

    def test_false_branch_type(self):
        result = normalize_result(False, 9)
        self.assertIsInstance(result, dict)
        self.assertEqual(result, {"result": 9})

    def test_consistent_shape(self):
        a = normalize_result(True, 3)
        b = normalize_result(False, 3)
        self.assertEqual(set(a.keys()), set(b.keys()))

if __name__ == "__main__":
    unittest.main()
EOT

/bin/cat > "$REPO_DIR/run_tests.py" <<'EOT'
#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

repo = Path(__file__).resolve().parent
proc = subprocess.run(
    [sys.executable, "-m", "unittest", "discover", "-s", str(repo / "tests"), "-v"],
    cwd=str(repo),
    text=True,
    capture_output=True
)
print(proc.stdout, end="")
print(proc.stderr, end="")
sys.exit(proc.returncode)
EOT

/bin/chmod +x "$REPO_DIR/run_tests.py"

# Answer key
/bin/cat > "$KEY_DIR/answer.json" <<'EOT'
{
  "task_id": "SWE_010",
  "expected_file": "app/formatter.py",
  "expected_required_snippet": "return {\"result\": value}",
  "tests_command": "/usr/bin/python3 run_tests.py"
}
EOT

# Evaluator
/bin/cat > "$EVAL_DIR/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json
import subprocess
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_010")
KEY_PATH = BASE / "key" / "answer.json"
REPO_DIR = BASE / "env" / "repo"

def main() -> None:
    key = json.loads(KEY_PATH.read_text(encoding="utf-8"))
    target_file = REPO_DIR / key["expected_file"]

    if not target_file.exists():
        print(json.dumps({
            "task_id": key["task_id"],
            "success": False,
            "error": "target_file_not_found"
        }, indent=2))
        sys.exit(1)

    source = target_file.read_text(encoding="utf-8")
    snippet_ok = source.count(key["expected_required_snippet"]) >= 2

    proc = subprocess.run(
        ["/usr/bin/python3", "run_tests.py"],
        cwd=str(REPO_DIR),
        text=True,
        capture_output=True
    )

    tests_ok = proc.returncode == 0

    print(json.dumps({
        "task_id": key["task_id"],
        "success": bool(snippet_ok and tests_ok),
        "checks": {
            "required_snippet_present_twice": snippet_ok,
            "tests_pass": tests_ok
        },
        "expected": {
            "file": key["expected_file"],
            "required_snippet": key["expected_required_snippet"]
        },
        "test_output": proc.stdout + proc.stderr
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if (snippet_ok and tests_ok) else 1)

if __name__ == "__main__":
    main()
EOT

/bin/chmod +x "$EVAL_DIR/evaluate.py"

# Reset script
/bin/cat > "$BASE/reset_repo.sh" <<'EOT'
#!/bin/zsh
set -euo pipefail

REPO_DIR="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_010/env/repo"

/bin/cat > "$REPO_DIR/app/formatter.py" <<'EOF2'
def normalize_result(flag, value):
    if flag:
        return {"result": value}
    return [value]
EOF2
EOT

/bin/chmod +x "$BASE/reset_repo.sh"

echo "Built SWE_010 environment and evaluator at $BASE"
