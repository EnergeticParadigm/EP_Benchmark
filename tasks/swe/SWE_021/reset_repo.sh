#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_021/env/repo"
/bin/cat > "$REPO/app/boundary.py" <<'EOF2'
def first_items(values, n):
    return values[: n + 1]
EOF2
