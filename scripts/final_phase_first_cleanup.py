#!/usr/bin/env python3
from __future__ import annotations

import shutil
from pathlib import Path

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")

def move_contents(src: Path, dst: Path) -> None:
    if not src.exists():
        return
    dst.mkdir(parents=True, exist_ok=True)
    for item in sorted(src.iterdir()):
        target = dst / item.name
        if target.exists():
            raise RuntimeError(f"Target already exists: {target}")
        shutil.move(str(item), str(target))
        print(f"MOVED: {item} -> {target}")
    try:
        src.rmdir()
    except OSError:
        pass

def ensure_shared() -> Path:
    shared = ROOT / "shared"
    (shared / "configs").mkdir(parents=True, exist_ok=True)
    (shared / "reports" / "assets").mkdir(parents=True, exist_ok=True)
    (shared / "results" / "figures").mkdir(parents=True, exist_ok=True)
    return shared

def migrate_old_shared(shared: Path) -> None:
    old = ROOT / "_shared_unclassified"
    if not old.exists():
        return

    move_contents(old / "configs", shared / "configs")
    move_contents(old / "reports" / "assets", shared / "reports" / "assets")
    move_contents(old / "results" / "figures", shared / "results" / "figures")

    for leftover in sorted(old.rglob("*"), reverse=True):
        if leftover.is_dir():
            try:
                leftover.rmdir()
                print(f"REMOVED EMPTY: {leftover}")
            except OSError:
                pass

    try:
        old.rmdir()
        print(f"REMOVED EMPTY: {old}")
    except OSError:
        pass

def flatten_phase3_batch1_results() -> None:
    nested = ROOT / "phase3_batch1" / "results" / "phase3"
    target = ROOT / "phase3_batch1" / "results"
    if not nested.exists():
        return

    for item in sorted(nested.iterdir()):
        dest = target / item.name
        if dest.exists():
            raise RuntimeError(f"Target already exists: {dest}")
        shutil.move(str(item), str(dest))
        print(f"MOVED: {item} -> {dest}")

    try:
        nested.rmdir()
        print(f"REMOVED EMPTY: {nested}")
    except OSError:
        pass

def print_summary() -> None:
    print("\nFINAL SUMMARY\n")
    for path in sorted(ROOT.iterdir()):
        print(path)
        if path.is_dir() and path.name in {
            "phase1_batch1", "phase2_batch1", "phase3_batch1", "phase3_batch2", "shared"
        }:
            for sub in sorted(path.iterdir()):
                print(f"  {sub}")

def main() -> None:
    shared = ensure_shared()
    migrate_old_shared(shared)
    flatten_phase3_batch1_results()
    print_summary()

if __name__ == "__main__":
    main()
