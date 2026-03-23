#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_042/env/repo"
/bin/cat > "$REPO/app/score_bridge.py" <<'EOF2'
def final_percentage(value):
    if value < 0:
        return 0
    if value > 100:
        return 100
    return value
EOF2
