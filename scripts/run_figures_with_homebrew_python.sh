#!/bin/zsh
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

if [ -x /opt/homebrew/bin/python3 ]; then
  PYTHON_BIN="/opt/homebrew/bin/python3"
elif [ -x /usr/local/bin/python3 ]; then
  PYTHON_BIN="/usr/local/bin/python3"
else
  echo "Homebrew python3 not found." >&2
  exit 1
fi

FIG_SCRIPT="/Users/wesleyshu/ep_benchmark_v1/scripts/generate_benchmark_figures.py"
FIG_DIR="/Users/wesleyshu/ep_benchmark_v1/results/figures"

"$PYTHON_BIN" - <<'PY'
import sys
import matplotlib
print("PYTHON=" + sys.executable)
print("MATPLOTLIB=" + matplotlib.__version__)
PY

"$PYTHON_BIN" "$FIG_SCRIPT"

echo
echo "FIGURES_DIR=$FIG_DIR"
ls -1 "$FIG_DIR"
