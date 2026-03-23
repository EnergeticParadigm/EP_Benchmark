#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_027/env/repo"
/bin/cat > "$REPO/app/parser.py" <<'EOF2'
import re

def extract_order_id(text):
    m = re.search(r"order-\d+", text)
    return None if m is None else m.group(0)
EOF2
