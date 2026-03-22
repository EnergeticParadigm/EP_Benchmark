#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_001"
EVAL_DIR="$BASE/evaluator"

/bin/mkdir -p "$EVAL_DIR"

/bin/cat > "$EVAL_DIR/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_001")
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

    path_ok = candidate.get("relative_path") == key["expected_relative_path"]
    line_ok = candidate.get("line_number") == key["expected_line_number"]
    text_ok = candidate.get("exact_line") == key["expected_exact_line"]

    success = path_ok and line_ok and text_ok

    print(json.dumps({
        "task_id": key["task_id"],
        "success": success,
        "checks": {
            "relative_path": path_ok,
            "line_number": line_ok,
            "exact_line": text_ok
        },
        "expected": {
            "relative_path": key["expected_relative_path"],
            "line_number": key["expected_line_number"],
            "exact_line": key["expected_exact_line"]
        },
        "candidate": {
            "relative_path": candidate.get("relative_path"),
            "line_number": candidate.get("line_number"),
            "exact_line": candidate.get("exact_line")
        }
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_correct.json" <<'EOT'
{
  "relative_path": "logs/api/server.log",
  "line_number": 3,
  "exact_line": "2026-03-01T10:11:09Z ERROR 502 req-77A9 upstream timeout while calling profile-service"
}
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_wrong.json" <<'EOT'
{
  "relative_path": "logs/auth/auth.log",
  "line_number": 2,
  "exact_line": "2026-03-01T09:01:04Z ERROR 401 req-77A9 invalid otp"
}
EOT

/bin/chmod +x "$EVAL_DIR/evaluate.py"

echo "Built TERM_001 evaluator at $EVAL_DIR"
echo "Test with:"
echo "/usr/bin/python3 $EVAL_DIR/evaluate.py $EVAL_DIR/sample_candidate_correct.json"
echo "/usr/bin/python3 $EVAL_DIR/evaluate.py $EVAL_DIR/sample_candidate_wrong.json"
