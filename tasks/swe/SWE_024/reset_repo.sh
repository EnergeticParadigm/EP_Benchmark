#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_024/env/repo"
/bin/cat > "$REPO/app/result_shape.py" <<'EOF2'
def build_result(values):
    if not values:
        return None
    return {"count": len(values), "items": values}
EOF2
