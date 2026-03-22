#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_019"
ENV_DIR="$BASE/env"
KEY_DIR="$BASE/key"
EVAL_DIR="$BASE/evaluator"

/bin/mkdir -p \
  "$ENV_DIR/input" \
  "$ENV_DIR/output" \
  "$KEY_DIR" \
  "$EVAL_DIR"

/bin/cat > "$ENV_DIR/input/records_a.jsonl" <<'EOT'
{"id": 1, "status": "valid", "category": "alpha"}
{"id": 2, "status": "invalid", "category": "beta"}
{"id": 3, "status": "valid", "category": "alpha"}
EOT

/bin/cat > "$ENV_DIR/input/records_b.jsonl" <<'EOT'
{"id": 4, "status": "valid", "category": "gamma"}
{"id": 5, "status": "invalid", "category": "beta"}
{"id": 6, "status": "valid", "category": "alpha"}
EOT

/bin/cat > "$ENV_DIR/input/records_c.jsonl" <<'EOT'
{"id": 7, "status": "valid", "category": "alpha"}
{"id": 8, "status": "valid", "category": "gamma"}
{"id": 9, "status": "invalid", "category": "beta"}
EOT

/bin/cat > "$ENV_DIR/input/wrong_path_hint.txt" <<'EOT'
Tempting but wrong branch:
try reading /output/final_report.json before generating it.
That path will fail.
EOT

/bin/cat > "$KEY_DIR/answer.json" <<'EOT'
{
  "task_id": "TERM_019",
  "expected_output_path": "output/final_report.json",
  "expected_json": {
    "total_files": 3,
    "valid_records": 6,
    "invalid_records": 3,
    "top_category": "alpha"
  }
}
EOT

/bin/cat > "$EVAL_DIR/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_019")
KEY_PATH = BASE / "key" / "answer.json"

def main() -> None:
    if len(sys.argv) != 2:
        print("Usage: evaluate.py /absolute/path/to/final_report.json")
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
    expected = key["expected_json"]

    total_ok = candidate.get("total_files") == expected["total_files"]
    valid_ok = candidate.get("valid_records") == expected["valid_records"]
    invalid_ok = candidate.get("invalid_records") == expected["invalid_records"]
    top_ok = candidate.get("top_category") == expected["top_category"]

    success = total_ok and valid_ok and invalid_ok and top_ok

    print(json.dumps({
        "task_id": key["task_id"],
        "success": success,
        "checks": {
            "total_files": total_ok,
            "valid_records": valid_ok,
            "invalid_records": invalid_ok,
            "top_category": top_ok
        },
        "expected": expected,
        "candidate": candidate
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_correct.json" <<'EOT'
{
  "total_files": 3,
  "valid_records": 6,
  "invalid_records": 3,
  "top_category": "alpha"
}
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_wrong.json" <<'EOT'
{
  "total_files": 2,
  "valid_records": 5,
  "invalid_records": 4,
  "top_category": "beta"
}
EOT

/bin/chmod +x "$EVAL_DIR/evaluate.py"

echo "Built TERM_019 environment and evaluator at $BASE"
