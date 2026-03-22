#!/bin/zsh
set -euo pipefail

REPO_DIR="/Users/wesleyshu/ep_benchmark_v1/tasks/swe/SWE_001/env/repo"

/bin/cat > "$REPO_DIR/app/range_sum.py" <<'EOF2'
def sum_first_n(numbers, n):
    total = 0
    for i in range(n + 1):
        total += numbers[i]
    return total
EOF2
