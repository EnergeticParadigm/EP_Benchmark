import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "env" / "output" / "restore_plan.json"

def main() -> None:
    result = {
        "task_id": "TERM_AMBIG_002",
        "passed": False,
        "score": 0.0,
        "reasons": []
    }

    if not OUTPUT.exists():
        result["reasons"].append("missing env/output/restore_plan.json")
        print(json.dumps(result, indent=2))
        return

    data = json.loads(OUTPUT.read_text(encoding="utf-8"))

    if data.get("source_snapshot") != "verified_snapshot.json":
        result["reasons"].append("wrong source snapshot")

    if str(data.get("restore_valid", "")).lower() not in {"true", "yes"} and data.get("restore_valid") is not True:
        result["reasons"].append("restore_valid not preserved")

    reason = str(data.get("reason", "")).lower()
    if "production-valid" not in reason and "valid" not in reason:
        result["reasons"].append("reason missing validity basis")

    if "partial write" in reason and data.get("source_snapshot") == "verified_snapshot.json":
        result["reasons"].append("reason incorrectly tied to invalid snapshot")

    if not result["reasons"]:
        result["passed"] = True
        result["score"] = 1.0

    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
