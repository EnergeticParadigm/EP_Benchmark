#!/usr/bin/env python3
from __future__ import annotations

import shutil
from datetime import datetime
from pathlib import Path

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
LOG = ROOT / "results" / "reorganize_benchmarks_v2.log"

CATEGORIES = ["tasks", "reports", "results", "configs", "docs", "releases"]
BENCHMARKS = ["phase1_batch1", "phase2_complete", "phase3_batch1", "phase3_batch2"]

def log(msg: str) -> None:
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{ts}] {msg}"
    print(line)
    LOG.parent.mkdir(parents=True, exist_ok=True)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(line + "\n")

def ensure_structure() -> None:
    for category in CATEGORIES:
        for benchmark in BENCHMARKS:
            (ROOT / category / benchmark).mkdir(parents=True, exist_ok=True)

def classify_name(name: str) -> str:
    lower = name.lower()

    if "phase2" in lower or "phase_2" in lower or "phase2_complete" in lower:
        return "phase2_complete"

    if (
        "phase3_batch2" in lower
        or "phase 3 batch 2" in lower
        or "batch2" in lower
        or "batch_2" in lower
        or "constraint" in lower
        or "drift" in lower
        or "swe_constraint_001" in lower
        or "term_constraint_001" in lower
        or "tool_constraint_001" in lower
    ):
        return "phase3_batch2"

    if (
        "phase3_batch1" in lower
        or "phase 3 batch 1" in lower
        or "ambiguity" in lower
        or "ambig" in lower
    ):
        return "phase3_batch1"

    if (
        "phase1_batch1" in lower
        or "phase1" in lower
        or "phase 1" in lower
        or "benchmark_v1" in lower
        or "formal_report" in lower
    ):
        return "phase1_batch1"

    return ""

def safe_move(src: Path, dest: Path) -> None:
    if src.resolve() == dest.resolve():
        return
    if dest.exists():
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        dest = dest.with_name(f"{dest.stem}_{ts}{dest.suffix}")
    log(f"MOVE {src} -> {dest}")
    shutil.move(str(src), str(dest))

def move_release_packages() -> None:
    releases_dir = ROOT / "releases"
    if not releases_dir.exists():
        return

    for entry in sorted(releases_dir.iterdir()):
        if entry.name in BENCHMARKS:
            continue

        if entry.is_dir():
            bucket = classify_name(entry.name)
            if bucket:
                safe_move(entry, releases_dir / bucket / entry.name)

        elif entry.is_file():
            bucket = classify_name(entry.name)
            if bucket:
                safe_move(entry, releases_dir / bucket / entry.name)
            else:
                log(f"UNCLASSIFIED_RELEASE_FILE {entry}")

def move_top_level_files(category: str) -> None:
    category_dir = ROOT / category
    if not category_dir.exists():
        return

    for entry in sorted(category_dir.iterdir()):
        if entry.name in BENCHMARKS:
            continue
        if entry.is_file():
            bucket = classify_name(entry.name)
            if bucket:
                safe_move(entry, category_dir / bucket / entry.name)
            else:
                log(f"UNCLASSIFIED {entry}")

def summarize() -> None:
    log("FINAL STRUCTURE SUMMARY")
    for category in CATEGORIES:
        log(f"--- {category} ---")
        for path in sorted((ROOT / category).rglob("*")):
            log(str(path))

def main() -> None:
    if LOG.exists():
        LOG.unlink()

    ensure_structure()
    log(f"ROOT {ROOT}")

    for category in ["tasks", "reports", "results", "configs", "docs"]:
        move_top_level_files(category)

    move_release_packages()
    summarize()
    log("DONE")

if __name__ == "__main__":
    main()
