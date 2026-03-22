#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_006"
ENV_DIR="$BASE/env"
KEY_DIR="$BASE/key"
EVAL_DIR="$BASE/evaluator"

/bin/mkdir -p \
  "$ENV_DIR/retrieval_a" \
  "$ENV_DIR/retrieval_b" \
  "$KEY_DIR" \
  "$EVAL_DIR"

/bin/cat > "$ENV_DIR/retrieval_a/result.txt" <<'EOT'
Primary retrieval result:
Status: incomplete
The launch year might be 2021.
Confidence: low
This result is insufficient for verification.
EOT

/bin/cat > "$ENV_DIR/retrieval_b/result.txt" <<'EOT'
Verified product release note

Product: Orion Analytics Suite
Official launch year: 2022

Evidence snippet:
Orion Analytics Suite was officially launched in 2022 after the beta program closed in late 2021.
EOT

/bin/cat > "$KEY_DIR/answer.json" <<'EOT'
{
  "task_id": "TOOL_006",
  "expected_tool_sequence": ["retrieval_a", "retrieval_b"],
  "expected_final_answer": "2022",
  "expected_evidence_snippet": "Orion Analytics Suite was officially launched in 2022 after the beta program closed in late 2021."
}
EOT

/bin/cat > "$EVAL_DIR/evaluate.py" <<'EOT'
#!/usr/bin/env python3
import json
import sys
from pathlib import Path

BASE = Path("/Users/wesleyshu/ep_benchmark_v1/tasks/tool_routing/TOOL_006")
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
    ev_ok = candidate.get("evidence_snippet") == key["expected_evidence_snippet"]
    success = seq_ok and ans_ok and ev_ok

    print(json.dumps({
        "task_id": key["task_id"],
        "success": success,
        "checks": {
            "tool_sequence": seq_ok,
            "final_answer": ans_ok,
            "evidence_snippet": ev_ok
        },
        "expected": {
            "tool_sequence": key["expected_tool_sequence"],
            "final_answer": key["expected_final_answer"],
            "evidence_snippet": key["expected_evidence_snippet"]
        },
        "candidate": {
            "tool_sequence": candidate.get("tool_sequence"),
            "final_answer": candidate.get("final_answer"),
            "evidence_snippet": candidate.get("evidence_snippet")
        }
    }, indent=2, ensure_ascii=False))

    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_correct.json" <<'EOT'
{
  "tool_sequence": ["retrieval_a", "retrieval_b"],
  "final_answer": "2022",
  "evidence_snippet": "Orion Analytics Suite was officially launched in 2022 after the beta program closed in late 2021."
}
EOT

/bin/cat > "$EVAL_DIR/sample_candidate_wrong.json" <<'EOT'
{
  "tool_sequence": ["retrieval_a", "retrieval_a"],
  "final_answer": "2021",
  "evidence_snippet": "The launch year might be 2021."
}
EOT

/bin/chmod +x "$EVAL_DIR/evaluate.py"

echo "Built TOOL_006 environment and evaluator at $BASE"
