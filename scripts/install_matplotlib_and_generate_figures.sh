#!/bin/zsh
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

PYTHON_BIN="/usr/bin/python3"

/usr/bin/python3 - <<'PY'
import sys
try:
    import matplotlib  # noqa: F401
    print("MATPLOTLIB_ALREADY_INSTALLED=1")
except Exception:
    print("MATPLOTLIB_ALREADY_INSTALLED=0")
PY

if ! /usr/bin/python3 - <<'PY'
import matplotlib  # noqa: F401
PY
then
  if /usr/bin/which brew >/dev/null 2>&1; then
    /opt/homebrew/bin/brew install python-matplotlib || /usr/local/bin/brew install python-matplotlib || true
  fi

  if ! /usr/bin/python3 - <<'PY'
import matplotlib  # noqa: F401
PY
  then
    "$PYTHON_BIN" -m ensurepip --upgrade || true
    "$PYTHON_BIN" -m pip install --upgrade pip --break-system-packages || true
    "$PYTHON_BIN" -m pip install matplotlib --break-system-packages
  fi
fi

"$PYTHON_BIN" /Users/wesleyshu/ep_benchmark_v1/scripts/generate_benchmark_figures.py

echo "DONE_FIGURES_DIR=/Users/wesleyshu/ep_benchmark_v1/results/figures"
