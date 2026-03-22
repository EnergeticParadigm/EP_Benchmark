#!/bin/zsh
set -euo pipefail

REPO_DIR="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_015/env/repo"

/bin/cat > "$REPO_DIR/app/score_utils.py" <<'EOF2'
def clamp_score(value):
    if value < 0:
        return 0
    if value > 100:
        return 100
    return value

def normalize_score(value):
    if value > 100:
        return 100
    return value
EOF2
