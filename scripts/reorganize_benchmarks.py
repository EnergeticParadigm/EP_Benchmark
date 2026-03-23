#!/usr/bin/env python3
from __future__ import annotations

import re
import shutil
from datetime import datetime
from pathlib import Path

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
LOG = ROOT / "results" / "reorganize_benchmarks.log"

CATEGORIES = [
    "tasks",
    "reports",
    "results",
    "configs",
    "docs",
    "releases",
]

BENCHMARKS = [
    "phase1_batch1",
    "phase3_batch1",
    "phase3_batch2",
]


def ensure_structure() -> None:
    (ROOT / "results").mkdir(parents=True, exist_ok=True)
    for category in CATEGORIES:
        category_dir = ROOT / category
        category_dir.mkdir(parents=True, exist_ok=True)
        for benchmark in BENCHMARKS:
            (category_dir / benchmark).mkdir(parents=True, exist_ok=True)


def log(msg: str) -> None:
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{ts}] {msg}"
    print(line)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(line + "\n")


def classify_file(path: Path) -> str:
    lower = path.name.lower().strip()

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
        or re.search(r"\bphase1\b", lower)
        or "phase 1" in lower
        or "benchmark_v1" in lower
        or "formal_report" in lower
        or "baseline benchmark" in lower
    ):
        return "phase1_batch1"

    return ""


def safe_move(src: Path, dest_dir: Path) -> None:
    dest_dir.mkdir(parents=True, exist_ok=True)
    dest = dest_dir / src.name

    try:
        if dest.exists() and dest.resolve() == src.resolve():
            return
    except FileNotFoundError:
        pass

    if dest.exists():
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        dest = dest_dir / f"{dest.stem}_{ts}{dest.suffix}"

    log(f"MOVE {src} -> {dest}")
    shutil.move(str(src), str(dest))


def scan_top_level(category: str) -> None:
    category_dir = ROOT / category
    if not category_dir.exists():
        return

    for entry in sorted(category_dir.iterdir()):
        if entry.is_file():
            benchmark = classify_file(entry)
            if benchmark:
                safe_move(entry, category_dir / benchmark)
            else:
                log(f"UNCLASSIFIED {entry}")


def scan_nested_misplaced(category: str) -> None:
    category_dir = ROOT / category
    if not category_dir.exists():
        return

    valid_parents = set(BENCHMARKS)

    for path in sorted(category_dir.rglob("*")):
        if not path.is_file():
            continue

        if path.parent.name in valid_parents:
            continue

        benchmark = classify_file(path)
        if benchmark:
            safe_move(path, category_dir / benchmark)
        else:
            log(f"STILL_UNCLASSIFIED {path}")


def write_summary() -> None:
    log("")
    log("FINAL STRUCTURE SUMMARY")
    for category in CATEGORIES:
        category_dir = ROOT / category
        log(f"--- {category} ---")
        if category_dir.exists():
            for path in sorted(category_dir.rglob("*")):
                if path.is_file():
                    log(str(path))


def main() -> None:
    ensure_structure()

    if LOG.exists():
        LOG.unlink()

    log("Reorganization started")
    log(f"Root: {ROOT}")

    for category in CATEGORIES:
        log(f"Processing category: {category}")
        scan_top_level(category)

    for category in CATEGORIES:
        log(f"Second pass category: {category}")
        scan_nested_misplaced(category)

    write_summary()
    log("Reorganization finished")


if __name__ == "__main__":
    main()
