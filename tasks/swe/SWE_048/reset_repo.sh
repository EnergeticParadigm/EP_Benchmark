#!/bin/zsh
set -euo pipefail
REPO="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_048/env/repo"
/bin/cat > "$REPO/app/first_record.py" <<'EOF2'
def first_record(records):
    return records[0] if records else {}
EOF2
