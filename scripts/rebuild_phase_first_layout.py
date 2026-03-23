#!/usr/bin/env python3
from __future__ import annotations

import shutil
from datetime import datetime
from pathlib import Path

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
LOG = ROOT / "migration_phase_first.log"

PHASES = [
    "phase1_batch1",
    "phase2_batch1",
    "phase3_batch1",
    "phase3_batch2",
]

CATEGORIES = [
    "reports",
    "tasks",
    "results",
    "configs",
    "docs",
    "releases",
]

CATEGORY_FIRST_DIRS = {c: ROOT / c for c in CATEGORIES}
PHASE_FIRST_DIRS = {p: ROOT / p for p in PHASES}
SHARED = ROOT / "_shared_unclassified"


def log(msg: str) -> None:
    ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{ts}] {msg}"
    print(line)
    with LOG.open("a", encoding="utf-8") as f:
        f.write(line + "\n")


def ensure_structure() -> None:
    for phase in PHASES:
        for category in CATEGORIES:
            (ROOT / phase / category).mkdir(parents=True, exist_ok=True)
    SHARED.mkdir(parents=True, exist_ok=True)


def safe_move(src: Path, dst: Path) -> None:
    if not src.exists():
        return
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists():
        suffix = datetime.now().strftime("%Y%m%d_%H%M%S")
        dst = dst.with_name(f"{dst.stem}_{suffix}{dst.suffix}")
    log(f"MOVE {src} -> {dst}")
    shutil.move(str(src), str(dst))


def move_contents(src_dir: Path, dst_dir: Path) -> None:
    if not src_dir.exists():
        return
    for item in sorted(src_dir.iterdir()):
        safe_move(item, dst_dir / item.name)
    try:
        src_dir.rmdir()
    except OSError:
        pass


def move_category_first_phase_dirs() -> None:
    for category, category_dir in CATEGORY_FIRST_DIRS.items():
        if not category_dir.exists():
            continue
        for phase in PHASES:
            src = category_dir / phase
            dst = ROOT / phase / category
            move_contents(src, dst)


def classify_loose_name(name: str) -> str:
    lower = name.lower()

    if "phase1" in lower:
        return "phase1_batch1"

    if "phase2" in lower:
        return "phase2_batch1"

    if (
        "phase3_batch2" in lower
        or "batch2" in lower
        or "constraint" in lower
        or "drift" in lower
        or "swe" in lower
        or "terminal" in lower
        or "tool_routing" in lower
        or "tool-routing" in lower
    ):
        return "phase3_batch2"

    if "phase3" in lower or "ambiguity" in lower or "ambig" in lower:
        return "phase3_batch1"

    return ""


def move_loose_items_inside_category_dirs() -> None:
    """
    Handle leftovers still sitting directly under old category-first roots,
    such as:
    /.../reports/phase3_report_flow.md
    /.../results/phase3_batch2_compare
    """
    for category, category_dir in CATEGORY_FIRST_DIRS.items():
        if not category_dir.exists():
            continue

        for item in sorted(category_dir.iterdir()):
            if item.name in PHASES:
                continue

            phase = classify_loose_name(item.name)
            if phase:
                safe_move(item, ROOT / phase / category / item.name)
            else:
                safe_move(item, SHARED / category / item.name)

        try:
            category_dir.rmdir()
        except OSError:
            pass


def move_phase_top_level_misplacements() -> None:
    """
    If any phase-related items already exist at repo top level but outside the
    correct phase/category tree, move them.
    """
    protected = set(PHASES) | set(CATEGORIES) | {
        "scripts",
        "README.md",
        "REDACT_FIRST.txt",
        "PUSH_FILES.txt",
        "DO_NOT_PUSH.txt",
        "_shared_unclassified",
        "migration_phase_first.log",
    }

    for item in sorted(ROOT.iterdir()):
        if item.name in protected:
            continue

        phase = classify_loose_name(item.name)
        if phase:
            safe_move(item, ROOT / phase / "results" / item.name)


def remove_empty_old_category_dirs() -> None:
    for category in CATEGORIES:
        old_dir = ROOT / category
        if old_dir.exists():
            try:
                old_dir.rmdir()
                log(f"REMOVED_EMPTY {old_dir}")
            except OSError:
                pass


def write_summary() -> None:
    log("FINAL SUMMARY")
    for phase in PHASES:
        log(f"=== {phase} ===")
        phase_dir = ROOT / phase
        for path in sorted(phase_dir.rglob("*")):
            log(str(path))

    if SHARED.exists():
        log("=== _shared_unclassified ===")
        for path in sorted(SHARED.rglob("*")):
            log(str(path))


def main() -> None:
    if LOG.exists():
        LOG.unlink()

    log(f"ROOT {ROOT}")
    ensure_structure()
    move_category_first_phase_dirs()
    move_loose_items_inside_category_dirs()
    move_phase_top_level_misplacements()
    remove_empty_old_category_dirs()
    write_summary()
    log("DONE")


if __name__ == "__main__":
    main()
