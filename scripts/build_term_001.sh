#!/bin/zsh
set -euo pipefail

export PATH="/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin"

BASE="/Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_001"
ENV_DIR="$BASE/env"
KEY_DIR="$BASE/key"

/bin/mkdir -p \
  "$ENV_DIR/logs/api" \
  "$ENV_DIR/logs/auth" \
  "$ENV_DIR/logs/worker/archive" \
  "$KEY_DIR"

/bin/cat > "$ENV_DIR/logs/api/server.log" <<'EOT'
2026-03-01T10:11:02Z INFO req-11A2 health check ok
2026-03-01T10:11:05Z WARN req-77A8 upstream latency elevated
2026-03-01T10:11:09Z ERROR 502 req-77A9 upstream timeout while calling profile-service
2026-03-01T10:11:11Z INFO req-11A3 retry succeeded
EOT

/bin/cat > "$ENV_DIR/logs/auth/auth.log" <<'EOT'
2026-03-01T09:01:00Z INFO req-77A9 login challenge issued
2026-03-01T09:01:04Z ERROR 401 req-77A9 invalid otp
2026-03-01T09:01:08Z INFO req-77B0 session reset
EOT

/bin/cat > "$ENV_DIR/logs/worker/archive/worker.log" <<'EOT'
2026-03-01T08:00:00Z INFO req-21C1 batch start
2026-03-01T08:00:08Z ERROR 502 req-55Z1 downstream queue unavailable
2026-03-01T08:00:10Z INFO req-21C1 batch resumed
EOT

/bin/cat > "$KEY_DIR/answer.json" <<'EOT'
{
  "task_id": "TERM_001",
  "expected_relative_path": "logs/api/server.log",
  "expected_line_number": 3,
  "expected_exact_line": "2026-03-01T10:11:09Z ERROR 502 req-77A9 upstream timeout while calling profile-service"
}
EOT

/bin/cat > "$BASE/README_ENV.md" <<'EOT'
# TERM_001 Environment

Goal:
Find the exact matching line that contains both:
- ERROR 502
- req-77A9

Return:
- full relative file path
- line number
- exact line content

Environment root:
 /Users/wesleyshu/ep_benchmark_v1/tasks/terminal/TERM_001/env
EOT

echo "Built TERM_001 environment at $BASE"
