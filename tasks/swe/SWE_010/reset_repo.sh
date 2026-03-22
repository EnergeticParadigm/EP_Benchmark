#!/bin/zsh
set -euo pipefail

REPO_DIR="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_010/env/repo"

/bin/cat > "$REPO_DIR/app/formatter.py" <<'EOF2'
def normalize_result(flag, value):
    if flag:
        return {"result": value}
    return [value]
EOF2
