#!/bin/zsh
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

if ! /usr/bin/which brew >/dev/null 2>&1; then
  /bin/echo "Homebrew is not installed at PATH=/opt/homebrew/bin:/usr/local/bin." >&2
  exit 1
fi

if ! /usr/bin/which pandoc >/dev/null 2>&1; then
  /opt/homebrew/bin/brew install pandoc || /usr/local/bin/brew install pandoc
fi

PANDOC="$(/usr/bin/which pandoc)"
REPORTS_DIR="/Users/wesleyshu/ep_benchmark_v1/results/reports"

"$PANDOC" \
  "$REPORTS_DIR/significance_report_v1.md" \
  -o "$REPORTS_DIR/significance_report_v1.docx"

"$PANDOC" \
  "$REPORTS_DIR/EP_benchmark_phase2_report_v1.md" \
  -o "$REPORTS_DIR/EP_benchmark_phase2_report_v1.docx"

echo "PANDOC=$PANDOC"
echo "CREATED=$REPORTS_DIR/significance_report_v1.docx"
echo "CREATED=$REPORTS_DIR/EP_benchmark_phase2_report_v1.docx"
