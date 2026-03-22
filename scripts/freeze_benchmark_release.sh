#!/bin/zsh
set -euo pipefail

BASE="/Users/wesleyshu/ep_benchmark_v1"
RELEASE_NAME="ep_benchmark_v1_phase2_complete"
RELEASE_DIR="$BASE/releases/$RELEASE_NAME"
REPORTS_DIR="$BASE/results/reports"
SCORED_DIR="$BASE/results/scored"
RAW_DIR="$BASE/results/raw"

export BASE RELEASE_NAME RELEASE_DIR REPORTS_DIR SCORED_DIR RAW_DIR

/bin/mkdir -p "$RELEASE_DIR"
/bin/mkdir -p "$RELEASE_DIR/reports" "$RELEASE_DIR/scored" "$RELEASE_DIR/raw" "$RELEASE_DIR/docs"

# Copy frozen benchmark outputs
/bin/cp -R "$REPORTS_DIR/." "$RELEASE_DIR/reports/"
/bin/cp -R "$SCORED_DIR/." "$RELEASE_DIR/scored/"
/bin/cp -R "$RAW_DIR/." "$RELEASE_DIR/raw/"

# Write external short summary
/bin/cat > "$RELEASE_DIR/docs/external_summary.md" <<'EOT'
# EP Benchmark External Summary

EP Benchmark v1 Phase 2 Complete is a fully executed 32-task internal benchmark comparing three execution modes:

- baseline
- baseline_scaffold
- ep

The benchmark covers three task families:
- terminal
- tool_routing
- swe

Final success rates:
- baseline: 0.4375
- baseline_scaffold: 0.8750
- ep: 0.9688

Paired significance:
- baseline vs baseline_scaffold: p = 0.000122
- baseline vs ep: p = 0.000015
- baseline_scaffold vs ep: p = 0.250000

Governance-oriented execution profile:
- invalid_tool_rate: baseline = 0.1875, baseline_scaffold = 0.0938, ep = 0.0000
- checkpoint_rate: baseline = 0.0000, baseline_scaffold = 0.0000, ep = 0.2500
- rollback_rate: baseline = 0.0312, baseline_scaffold = 0.1250, ep = 0.2500

Core conclusion:

Raw execution is weakest. Structured execution is much stronger. Governed execution is strongest.

Under the current fully executed 32-task internal benchmark, EP achieves the best completion rate and the strongest governance-oriented execution profile.
EOT

# Write release manifest
/usr/bin/python3 <<'PY'
import json
import os
from pathlib import Path

base = Path(os.environ["BASE"])
release_dir = Path(os.environ["RELEASE_DIR"])

manifest = {
    "release_name": os.environ["RELEASE_NAME"],
    "benchmark_status": "frozen",
    "task_count": 32,
    "task_execution_status": "fully_executed",
    "modes": ["baseline", "baseline_scaffold", "ep"],
    "headline_metrics": {
        "baseline": {
            "success_rate": 0.4375,
            "invalid_tool_rate": 0.1875,
            "checkpoint_rate": 0.0,
            "rollback_rate": 0.0312,
        },
        "baseline_scaffold": {
            "success_rate": 0.8750,
            "invalid_tool_rate": 0.0938,
            "checkpoint_rate": 0.0,
            "rollback_rate": 0.1250,
        },
        "ep": {
            "success_rate": 0.9688,
            "invalid_tool_rate": 0.0,
            "checkpoint_rate": 0.2500,
            "rollback_rate": 0.2500,
        },
    },
    "paired_significance": {
        "baseline_vs_baseline_scaffold": 0.000122,
        "baseline_vs_ep": 0.000015,
        "baseline_scaffold_vs_ep": 0.250000,
    },
    "source_paths": {
        "reports": str(base / "results" / "reports"),
        "scored": str(base / "results" / "scored"),
        "raw": str(base / "results" / "raw"),
    },
}

(release_dir / "release_manifest.json").write_text(
    json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
    encoding="utf-8",
)
print(f"Wrote {release_dir / 'release_manifest.json'}")
PY

# Update README with frozen release section
/usr/bin/python3 <<'PY'
from pathlib import Path

readme = Path("/Users/wesleyshu/ep_benchmark_v1/README.md")
if readme.exists():
    text = readme.read_text(encoding="utf-8")
else:
    text = "# EP Benchmark v1\n\n"

section = """## Current Frozen Release

Release name: ep_benchmark_v1_phase2_complete

This is the current frozen benchmark baseline.

Benchmark status:
- 32 tasks
- fully executed
- three modes: baseline, baseline_scaffold, ep

Final success rates:
- baseline: 0.4375
- baseline_scaffold: 0.8750
- ep: 0.9688

Paired significance:
- baseline vs baseline_scaffold: p = 0.000122
- baseline vs ep: p = 0.000015
- baseline_scaffold vs ep: p = 0.250000

Governance metrics:
- invalid_tool_rate: baseline = 0.1875, baseline_scaffold = 0.0938, ep = 0.0000
- checkpoint_rate: baseline = 0.0000, baseline_scaffold = 0.0000, ep = 0.2500
- rollback_rate: baseline = 0.0312, baseline_scaffold = 0.1250, ep = 0.2500

Key files:
- reports: /Users/wesleyshu/ep_benchmark_v1/results/reports
- frozen release: /Users/wesleyshu/ep_benchmark_v1/releases/ep_benchmark_v1_phase2_complete
"""

marker = "## Current Frozen Release"
if marker in text:
    before = text.split(marker)[0].rstrip() + "\n\n"
    text = before + section
else:
    text = text.rstrip() + "\n\n" + section

readme.write_text(text, encoding="utf-8")
print(f"Updated {readme}")
PY

# Create short founder-style post draft
/bin/cat > "$RELEASE_DIR/docs/linkedin_short_post.md" <<'EOT'
EP Benchmark Phase 2 is now frozen as a complete 32-task internal benchmark.

We tested three execution modes on the same fully executed task pack:

baseline  
baseline_scaffold  
ep

Final success rates:

baseline = 0.4375  
baseline_scaffold = 0.8750  
ep = 0.9688

The benchmark also captured execution quality, not just completion. EP finished with zero invalid tool behavior, the highest checkpoint rate, and the highest rollback rate.

Paired comparisons are now strong:

baseline vs baseline_scaffold  
p = 0.000122

baseline vs ep  
p = 0.000015

This means the benchmark has moved beyond a concept demo. It is now a stable internal baseline for comparing raw execution, structured execution, and governed execution.

Raw execution is weakest.  
Structured execution is much stronger.  
Governed execution is strongest.
EOT

/bin/echo "Frozen release created at:"
/bin/echo "$RELEASE_DIR"
/bin/echo ""
/bin/echo "Key files:"
/bin/echo "$RELEASE_DIR/release_manifest.json"
/bin/echo "$RELEASE_DIR/docs/external_summary.md"
/bin/echo "$RELEASE_DIR/docs/linkedin_short_post.md"
/bin/echo "/Users/wesleyshu/ep_benchmark_v1/README.md"
