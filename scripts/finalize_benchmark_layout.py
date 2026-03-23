#!/usr/bin/env python3
from __future__ import annotations

import shutil
from pathlib import Path

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")

def move(src: Path, dst: Path) -> None:
    if not src.exists():
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists():
        raise RuntimeError(f"Target already exists: {dst}")
    shutil.move(str(src), str(dst))
    print(f"MOVED: {src} -> {dst}")

def main() -> None:
    # tasks
    move(
        ROOT / "tasks" / "swe",
        ROOT / "tasks" / "phase3_batch2" / "swe",
    )
    move(
        ROOT / "tasks" / "terminal",
        ROOT / "tasks" / "phase3_batch2" / "terminal",
    )
    move(
        ROOT / "tasks" / "tool_routing",
        ROOT / "tasks" / "phase3_batch2" / "tool_routing",
    )

    # reports
    move(
        ROOT / "reports" / "phase3_appendix_master_summary.md",
        ROOT / "reports" / "phase3_batch2" / "phase3_appendix_master_summary.md",
    )
    move(
        ROOT / "reports" / "phase3_report_flow.md",
        ROOT / "reports" / "phase3_batch2" / "phase3_report_flow.md",
    )

    # results
    move(
        ROOT / "results" / "phase3",
        ROOT / "results" / "phase3_batch1" / "phase3",
    )
    move(
        ROOT / "results" / "phase3_batch2_compare",
        ROOT / "results" / "phase3_batch2" / "phase3_batch2_compare",
    )
    move(
        ROOT / "results" / "phase3_batch2_execution",
        ROOT / "results" / "phase3_batch2" / "phase3_batch2_execution",
    )
    move(
        ROOT / "results" / "phase3_batch2_raw_generation",
        ROOT / "results" / "phase3_batch2" / "phase3_batch2_raw_generation",
    )
    move(
        ROOT / "results" / "phase3_batch2_raw_generation_fast",
        ROOT / "results" / "phase3_batch2" / "phase3_batch2_raw_generation_fast",
    )
    move(
        ROOT / "results" / "phase3_batch2_real",
        ROOT / "results" / "phase3_batch2" / "phase3_batch2_real",
    )
    move(
        ROOT / "results" / "phase3_batch2_real_evidence",
        ROOT / "results" / "phase3_batch2" / "phase3_batch2_real_evidence",
    )
    move(
        ROOT / "results" / "phase3_batch2_runner_logs",
        ROOT / "results" / "phase3_batch2" / "phase3_batch2_runner_logs",
    )

    # configs
    move(
        ROOT / "configs" / "phase3_added_manifest.json",
        ROOT / "configs" / "phase2_batch1" / "phase3_added_manifest.json",
    )
    move(
        ROOT / "configs" / "phase3_flat_manifest.json",
        ROOT / "configs" / "phase3_batch1" / "phase3_flat_manifest.json",
    )
    move(
        ROOT / "configs" / "phase3_manifest.json",
        ROOT / "configs" / "phase3_batch1" / "phase3_manifest.json",
    )
    move(
        ROOT / "configs" / "phase3_task_paths.json",
        ROOT / "configs" / "phase3_batch2" / "phase3_task_paths.json",
    )

    # docs
    move(
        ROOT / "docs" / "phase3_design.md",
        ROOT / "docs" / "phase3_batch1" / "phase3_design.md",
    )
    move(
        ROOT / "docs" / "phase3_pilot_summary.md",
        ROOT / "docs" / "phase3_batch1" / "phase3_pilot_summary.md",
    )
    move(
        ROOT / "docs" / "smoke_test_overview.md",
        ROOT / "docs" / "phase2_batch1" / "smoke_test_overview.md",
    )

    print("DONE")

if __name__ == "__main__":
    main()
