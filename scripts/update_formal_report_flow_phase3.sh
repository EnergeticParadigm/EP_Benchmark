#!/bin/bash
set -euo pipefail

BASE="/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1"
PHASE3_MASTER_JSON="$BASE/results/phase3/phase3_master_summary.json"
PHASE3_MASTER_MD="$BASE/results/phase3/phase3_master_summary.md"
PHASE3_BATCH2_JSON="$BASE/results/phase3_batch2_real/phase3_batch2_real_summary.json"
PHASE3_BATCH2_MD="$BASE/results/phase3_batch2_real/phase3_batch2_real_summary.md"

REPORTS_DIR="$BASE/reports"
DOCS_DIR="$BASE/docs"
RELEASES_DIR="$BASE/releases"

REPORT_FLOW_MD="$REPORTS_DIR/phase3_report_flow.md"
PHASE3_APPENDIX_MD="$REPORTS_DIR/phase3_appendix_master_summary.md"
PHASE3_BATCH2_APPENDIX_MD="$REPORTS_DIR/phase3_batch2_appendix.md"

mkdir -p "$REPORTS_DIR" "$DOCS_DIR" "$RELEASES_DIR"

if [ ! -f "$PHASE3_MASTER_JSON" ]; then
  echo "MISSING_PHASE3_MASTER_JSON=$PHASE3_MASTER_JSON"
  exit 1
fi

if [ ! -f "$PHASE3_MASTER_MD" ]; then
  echo "MISSING_PHASE3_MASTER_MD=$PHASE3_MASTER_MD"
  exit 1
fi

if [ ! -f "$PHASE3_BATCH2_JSON" ]; then
  echo "MISSING_PHASE3_BATCH2_JSON=$PHASE3_BATCH2_JSON"
  exit 1
fi

if [ ! -f "$PHASE3_BATCH2_MD" ]; then
  echo "MISSING_PHASE3_BATCH2_MD=$PHASE3_BATCH2_MD"
  exit 1
fi

/usr/bin/python3 - <<'PY'
import json
from pathlib import Path

base = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
phase3_master_json = base / "results/phase3/phase3_master_summary.json"
phase3_master_md = base / "results/phase3/phase3_master_summary.md"
phase3_batch2_json = base / "results/phase3_batch2_real/phase3_batch2_real_summary.json"
phase3_batch2_md = base / "results/phase3_batch2_real/phase3_batch2_real_summary.md"

report_flow_md = base / "reports/phase3_report_flow.md"
phase3_appendix_md = base / "reports/phase3_appendix_master_summary.md"
phase3_batch2_appendix_md = base / "reports/phase3_batch2_appendix.md"

master = json.loads(phase3_master_json.read_text(encoding="utf-8"))
batch2 = json.loads(phase3_batch2_json.read_text(encoding="utf-8"))

totals = master.get("totals", {})
batches = master.get("batches", {})
batch2_data = batches.get("phase3_batch2_real", {})

flow_lines = []
flow_lines.append("# Phase 3 Formal Report Flow")
flow_lines.append("")
flow_lines.append("## Canonical Phase 3 Summary Sources")
flow_lines.append("")
flow_lines.append(f"- Phase 3 master summary JSON: `{phase3_master_json}`")
flow_lines.append(f"- Phase 3 master summary Markdown: `{phase3_master_md}`")
flow_lines.append(f"- Phase 3 Batch 2 summary JSON: `{phase3_batch2_json}`")
flow_lines.append(f"- Phase 3 Batch 2 summary Markdown: `{phase3_batch2_md}`")
flow_lines.append("")
flow_lines.append("## Current Aggregated Totals")
flow_lines.append("")
flow_lines.append(f"- Total task count: `{totals.get('task_count', 0)}`")
flow_lines.append(f"- Total pass count: `{totals.get('pass_count', 0)}`")
flow_lines.append(f"- Total fail count: `{totals.get('fail_count', 0)}`")
flow_lines.append(f"- Total partial count: `{totals.get('partial_count', 0)}`")
flow_lines.append(f"- Total error count: `{totals.get('error_count', 0)}`")
flow_lines.append("")
flow_lines.append("## Batch 2")
flow_lines.append("")
flow_lines.append(f"- Task count: `{batch2_data.get('task_count', 0)}`")
flow_lines.append(f"- Pass count: `{batch2_data.get('pass_count', 0)}`")
flow_lines.append(f"- Fail count: `{batch2_data.get('fail_count', 0)}`")
flow_lines.append(f"- Partial count: `{batch2_data.get('partial_count', 0)}`")
flow_lines.append(f"- Error count: `{batch2_data.get('error_count', 0)}`")
flow_lines.append("")
flow_lines.append("## Required Report Inclusion Rule")
flow_lines.append("")
flow_lines.append("Every future formal Phase 3 report should treat `results/phase3/phase3_master_summary.json` and `results/phase3/phase3_master_summary.md` as the authoritative aggregate source.")
flow_lines.append("Every Batch 2-specific report or appendix should include the dedicated Batch 2 summary from `results/phase3_batch2_real/phase3_batch2_real_summary.json` and `results/phase3_batch2_real/phase3_batch2_real_summary.md`.")
flow_lines.append("")
report_flow_md.write_text("\n".join(flow_lines) + "\n", encoding="utf-8")

appendix_lines = []
appendix_lines.append("# Appendix — Phase 3 Master Summary")
appendix_lines.append("")
appendix_lines.append(phase3_master_md.read_text(encoding="utf-8").rstrip())
appendix_lines.append("")
phase3_appendix_md.write_text("\n".join(appendix_lines) + "\n", encoding="utf-8")

batch2_lines = []
batch2_lines.append("# Appendix — Phase 3 Batch 2 Summary")
batch2_lines.append("")
batch2_lines.append(phase3_batch2_md.read_text(encoding="utf-8").rstrip())
batch2_lines.append("")
phase3_batch2_appendix_md.write_text("\n".join(batch2_lines) + "\n", encoding="utf-8")

print(f"REPORT_FLOW_MD={report_flow_md}")
print(f"PHASE3_APPENDIX_MD={phase3_appendix_md}")
print(f"PHASE3_BATCH2_APPENDIX_MD={phase3_batch2_appendix_md}")
print("UPDATE_FORMAL_REPORT_FLOW_PHASE3_OK")
PY
