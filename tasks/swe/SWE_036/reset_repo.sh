#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_036/env/repo"
/bin/cat > "$REPO/app/report_state.py" <<'EOF2'
def build_state(ok, code):
    if ok:
        return {"status": "ok", "code": code}
    return [code]
EOF2
