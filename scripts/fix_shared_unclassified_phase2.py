#!/usr/bin/env python3
from __future__ import annotations

import shutil
from pathlib import Path

ROOT = Path("/Users/wesleyshu/EnergeticParadigm/ep_benchmark_v1")
SRC = ROOT / "_shared_unclassified" / "results"
DST = ROOT / "phase2_batch1" / "results"

def move_all(src_dir: Path, dst_dir: Path) -> None:
    if not src_dir.exists():
        return
    dst_dir.mkdir(parents=True, exist_ok=True)

    for item in sorted(src_dir.iterdir()):
        target = dst_dir / item.name
        if target.exists():
            raise RuntimeError(f"Target already exists: {target}")
        shutil.move(str(item), str(target))
        print(f"MOVED: {item} -> {target}")

    try:
        src_dir.rmdir()
    except OSError:
        pass

def remove_empty_parents(path: Path) -> None:
    while path != ROOT and path.exists():
        try:
            path.rmdir()
            print(f"REMOVED EMPTY: {path}")
            path = path.parent
        except OSError:
            break

def main() -> None:
    move_all(SRC / "raw", DST / "raw")
    move_all(SRC / "reports", DST / "reports")
    move_all(SRC / "scored", DST / "scored")

    for name in ["reorganize_benchmarks.log", "reorganize_benchmarks_v2.log"]:
        src_file = SRC / name
        if src_file.exists():
            target = DST / name
            if target.exists():
                raise RuntimeError(f"Target already exists: {target}")
            shutil.move(str(src_file), str(target))
            print(f"MOVED: {src_file} -> {target}")

    remove_empty_parents(SRC)
    print("DONE")

if __name__ == "__main__":
    main()
