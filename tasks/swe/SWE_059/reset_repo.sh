#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_059/env/repo"
/bin/cat > "$REPO/app/score_label.py" <<'EOF2'
def score_label(score):
    if score >= 80:
        return "gold"
    if score >= 50:
        return "silver"
    return "silver"
EOF2
