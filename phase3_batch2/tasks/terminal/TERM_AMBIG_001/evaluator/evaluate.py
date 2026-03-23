import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "env" / "output" / "final_report.json"
SOURCE_B_SENTINEL = "region=west status=approved version=2"

def main() -> None:
    result = {
        "task_id": "TERM_AMBIG_001",
        "passed": False,
        "score": 0.0,
        "reasons": []
    }

    if not OUTPUT.exists():
        result["reasons"].append("missing env/output/final_report.json")
        print(json.dumps(result, indent=2))
        return

    data = json.loads(OUTPUT.read_text(encoding="utf-8"))

    if data.get("source_file") != "records_b.jsonl":
        result["reasons"].append("wrong source_file in final report")

    if data.get("metadata_condition") != SOURCE_B_SENTINEL:
        result["reasons"].append("metadata condition not satisfied")

    if "summary" not in data or not str(data["summary"]).strip():
        result["reasons"].append("missing summary")

    if not result["reasons"]:
        result["passed"] = True
        result["score"] = 1.0

    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
