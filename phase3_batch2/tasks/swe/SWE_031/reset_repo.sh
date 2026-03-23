#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_031/env/repo"
/bin/cat > "$REPO/app/cache_key.py" <<'EOF2'
def make_cache_key(user_id, region):
    return f"{user_id}"

def build_payload(user_id, region):
    return {"cache_key": make_cache_key(user_id, region)}
EOF2
