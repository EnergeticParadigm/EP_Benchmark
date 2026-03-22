#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_015"
ENV_DIR="$BASE/env"
KEY_DIR="$BASE/key"
EVAL_DIR="$BASE/evaluator"
REPO_DIR="$ENV_DIR/repo"

/bin/mkdir -p \
  "$REPO_DIR/app" \
  "$REPO_DIR/tests" \
  "$KEY_DIR" \
  "$EVAL_DIR"

# Buggy source
/bin/cat > "$REPO_DIR/app/score_utils.py" <<'EOT'
def clamp_score(value):
    if value < 0:
        return 0
    if value > 100:
        return 100
    return value

def normalize_score(value):
    if value > 100:
        return 100
    return value
EOT

# Tests
/bin/cat > "$REPO_DIR/tests/test_score_utils.py" <<'EOT'
import unittest
from app.score_utils import normalize_score

class TestScoreUtils(unittest.TestCase):
    def test_mid_value(self):
        self.assertEqual(normalize_score(55), 55)

    def test_high_value(self):
        self.assertEqual(normalize_score(140), 100)

    def test_negative_value(self):
        self.assertEqual(normalize_score(-7), 0)

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
  "task_id": "SWE_015",
  "expected_file": "app/score_utils.py",
  "expected_required_snippet": "return clamp_score(value)",
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

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_015")
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
    snippet_ok = key["expected_required_snippet"] in source

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
            "required_snippet_present": snippet_ok,
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

REPO_DIR="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_015/env/repo"

/bin/cat > "$REPO_DIR/app/score_utils.py" <<'EOF2'
def clamp_score(value):
    if value < 0:
        return 0
    if value > 100:
        return 100
    return value

def normalize_score(value):
    if value > 100:
        return 100
    return value
EOF2
EOT

/bin/chmod +x "$BASE/reset_repo.sh"

echo "Built SWE_015 environment and evaluator at $BASE"
