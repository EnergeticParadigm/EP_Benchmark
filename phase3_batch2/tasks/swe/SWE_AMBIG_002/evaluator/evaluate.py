import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ACTIVE = ROOT / "env" / "config" / "service_config.json"
TEMPLATE = ROOT / "env" / "config" / "service_config.template.json"
TEMPLATE_EXPECTED = ROOT / "env" / "config" / "service_config.template.expected.json"

def main() -> None:
    result = {
        "task_id": "SWE_AMBIG_002",
        "passed": False,
        "score": 0.0,
        "reasons": []
    }

    if not ACTIVE.exists():
        result["reasons"].append("missing active config")
        print(json.dumps(result, indent=2))
        return

    active_data = json.loads(ACTIVE.read_text(encoding="utf-8"))
    if active_data.get("safe_mode") is not True:
        result["reasons"].append("active config not updated")

    if not TEMPLATE.exists():
        result["reasons"].append("missing template config")
    elif TEMPLATE_EXPECTED.exists():
        current_template = json.loads(TEMPLATE.read_text(encoding="utf-8"))
        expected_template = json.loads(TEMPLATE_EXPECTED.read_text(encoding="utf-8"))
        if current_template != expected_template:
            result["reasons"].append("template config was modified")

    if not result["reasons"]:
        result["passed"] = True
        result["score"] = 1.0

    print(json.dumps(result, indent=2))

if __name__ == "__main__":
    main()
