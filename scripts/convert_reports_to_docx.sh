#!/bin/zsh
set -euo pipefail

PANDOC="/usr/local/bin/pandoc"
if [ ! -x "$PANDOC" ]; then
  PANDOC="/usr/bin/pandoc"
fi

REPORTS_DIR="/Users/wesleyshu/ep_benchmark_v1/results/reports"

"$PANDOC" \
  "$REPORTS_DIR/significance_report_v1.md" \
  -o "$REPORTS_DIR/significance_report_v1.docx"

"$PANDOC" \
  "$REPORTS_DIR/EP_benchmark_phase2_report_v1.md" \
  -o "$REPORTS_DIR/EP_benchmark_phase2_report_v1.docx"

echo "Created:"
echo "$REPORTS_DIR/significance_report_v1.docx"
echo "$REPORTS_DIR/EP_benchmark_phase2_report_v1.docx"
