#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_001"
ENV_DIR="$BASE/env"
KEY_DIR="$BASE/key"
EVAL_DIR="$BASE/evaluator"

/bin/mkdir -p \
  "$ENV_DIR/materials" \
  "$KEY_DIR" \
  "$EVAL_DIR"

/bin/cat > "$ENV_DIR/materials/company_metrics.txt" <<'EOT'
Quarterly Operations Snapshot

Region A completed orders: 184
Region B completed orders: 46

Instruction:
Compute Region B as a percentage of Region A.
Return the final ratio with exactly two decimal places and a trailing percent sign.
EOT

/bin/cat > "$KEY_DIR/answer.json" <<'EOT'
{
  "task_id": "TOOL_001",
  "expected_tool_sequence": ["retrieval", "calculator"],
  "expected_final_answer": "25.00%"
}
EOT

/bin/cat > "$EVAL_DIR/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_001")
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

    seq_ok = candidate.get("tool_sequence") == key["expected_tool_sequence"]
    ans_ok = candidate.get("final_answer") == key["expected_final_answer"]
    success = seq_ok and ans_ok

    print(json.dumps({
        "task_id": key["task_id"],
        "success": success,
        "checks": {
            "tool_sequence": seq_ok,
            "final_answer": ans_ok
        },
        "expected": {
            "tool_sequence": key["expected_tool_sequence"],
            "final_answer": key["expected_final_answer"]
        },
        "candidate": {
            "tool_sequence": candidate.get("tool_sequence"),
            "final_answer": candidate.get("final_answer")
        }
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_correct.json" <<'EOT'
{
  "tool_sequence": ["retrieval", "calculator"],
  "final_answer": "25.00%"
}
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_wrong.json" <<'EOT'
{
  "tool_sequence": ["calculator", "retrieval"],
  "final_answer": "400.00%"
}
EOT

/bin/chmod +x "$EVAL_DIR/evaluate.py"

echo "Built TOOL_001 environment and evaluator at $BASE"
