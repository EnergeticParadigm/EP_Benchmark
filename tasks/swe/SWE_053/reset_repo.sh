#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_053/env/repo"
/bin/cat > "$REPO/app/normalize_name.py" <<'EOF2'
def normalize_name(name):
    return name.strip().lower().replace(" ", "")
EOF2
