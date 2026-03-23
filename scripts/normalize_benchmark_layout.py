#!/usr/bin/env python3
from __future__ import annotations

import shutil
from pathlib import Path

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
CATEGORIES = ["tasks", "reports", "results", "configs", "docs", "releases"]

OLD_NAME = "phase2_complete"
NEW_NAME = "phase2_batch1"

def move_contents(src: Path, dst: Path) -> None:
    if not src.exists():
        return
    dst.mkdir(parents=True, exist_ok=True)
    for item in sorted(src.iterdir()):
        target = dst / item.name
        if target.exists():
            raise RuntimeError(f"Target already exists: {target}")
        shutil.move(str(item), str(target))
    try:
        src.rmdir()
    except OSError:
        pass

def ensure_phase_dirs() -> None:
    for category in CATEGORIES:
        (ROOT / category / "phase1_batch1").mkdir(parents=True, exist_ok=True)
        (ROOT / category / "phase3_batch1").mkdir(parents=True, exist_ok=True)
        (ROOT / category / "phase3_batch2").mkdir(parents=True, exist_ok=True)

def print_summary() -> None:
    print("\nFINAL LAYOUT\n")
    for category in CATEGORIES:
        category_dir = ROOT / category
        print(f"[{category}]")
        if category_dir.exists():
            for path in sorted(category_dir.iterdir()):
                print(path)
        print()

def main() -> None:
    ensure_phase_dirs()

    for category in CATEGORIES:
        src = ROOT / category / OLD_NAME
        dst = ROOT / category / NEW_NAME
        move_contents(src, dst)

    print_summary()

if __name__ == "__main__":
    main()
