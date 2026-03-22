#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_010"
ENV_DIR="$BASE/env"
KEY_DIR="$BASE/key"
EVAL_DIR="$BASE/evaluator"

/bin/mkdir -p \
  "$ENV_DIR/logs/tests" \
  "$KEY_DIR" \
  "$EVAL_DIR"

/bin/cat > "$ENV_DIR/logs/tests/test_run.log" <<'EOT'
============================= test session starts =============================
platform darwin -- Python 3.11.7
collected 8 items

tests/test_auth.py::test_login_ok PASSED
tests/test_auth.py::test_logout_ok PASSED
tests/test_profile.py::test_profile_summary PASSED
tests/test_profile.py::test_profile_avatar_warning WARNING low disk cache
tests/test_orders.py::test_order_list PASSED
tests/test_orders.py::test_order_total FAILED
tests/test_orders.py::test_order_archive SKIPPED
tests/test_health.py::test_healthcheck PASSED

___________________________________ FAILURES ___________________________________

________________________ test_order_total ________________________

    def test_order_total():
        items = [{"price": 19.5}, {"price": 20.0}]
>       assert compute_total(items) == 39.5
E       TypeError: unsupported operand type(s) for +: 'float' and 'str'

app/orders/calc.py:27: TypeError

=========================== short test summary info ===========================
FAILED tests/test_orders.py::test_order_total - TypeError: unsupported operand type(s) for +: 'float' and 'str'
============= 1 failed, 6 passed, 1 skipped, 1 warning in 0.82s =============
EOT

/bin/cat > "$KEY_DIR/answer.json" <<'EOT'
{
  "task_id": "TERM_010",
  "expected_failing_test_name": "tests/test_orders.py::test_order_total",
  "expected_error_type": "TypeError",
  "expected_first_stacktrace_file_path": "app/orders/calc.py:27"
}
EOT

/bin/cat > "$EVAL_DIR/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_010")
KEY_PATH = BASE / "key" / "answer.json"

def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: evaluate.py /absolute/path/to/candidate.json")
        sys.exit(2)

    candidate_path = Path(sys.argv[1])
    if not candidate_path.exists():
        print(json.dumps({
            "success": False,
            "error": "candidate_file_not_found"
        }, indent=2))
        sys.exit(1)

    key = json.loads(KEY_PATH.read_text(encoding="utf-8"))
    candidate = json.loads(candidate_path.read_text(encoding="utf-8"))

    test_ok = candidate.get("failing_test_name") == key["expected_failing_test_name"]
    err_ok = candidate.get("error_type") == key["expected_error_type"]
    path_ok = candidate.get("first_stacktrace_file_path") == key["expected_first_stacktrace_file_path"]

    success = test_ok and err_ok and path_ok

    print(json.dumps({
        "task_id": key["task_id"],
        "success": success,
        "checks": {
            "failing_test_name": test_ok,
            "error_type": err_ok,
            "first_stacktrace_file_path": path_ok
        },
        "expected": {
            "failing_test_name": key["expected_failing_test_name"],
            "error_type": key["expected_error_type"],
            "first_stacktrace_file_path": key["expected_first_stacktrace_file_path"]
        },
        "candidate": {
            "failing_test_name": candidate.get("failing_test_name"),
            "error_type": candidate.get("error_type"),
            "first_stacktrace_file_path": candidate.get("first_stacktrace_file_path")
        }
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_correct.json" <<'EOT'
{
  "failing_test_name": "tests/test_orders.py::test_order_total",
  "error_type": "TypeError",
  "first_stacktrace_file_path": "app/orders/calc.py:27"
}
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_wrong.json" <<'EOT'
{
  "failing_test_name": "tests/test_profile.py::test_profile_avatar_warning",
  "error_type": "WARNING",
  "first_stacktrace_file_path": "tests/test_profile.py:14"
}
EOT

/bin/chmod +x "$EVAL_DIR/evaluate.py"

echo "Built TERM_010 environment and evaluator at $BASE"
