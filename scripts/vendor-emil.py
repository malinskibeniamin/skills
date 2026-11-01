#!/usr/bin/env python3
"""Refresh pinned Emil source material; keep host adaptations outside the snapshot."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


REPOSITORY = "https://github.com/emilkowalski/skills"
ADAPTED = (
    "animate", "remove-animations", "improve-animations", "animation-performance",
    "animation-vocabulary", "mobile-native", "break-ui", "ask-sonner",
)
ROOT_FILES = {"LICENSE", "README.md", "performance-cheatsheet.md", "ui-cheatsheet.md"}


def git(source, *args):
    return subprocess.check_output(["git", "-C", str(source), *args])


def inventory(root):
    if root.is_symlink():
        raise ValueError(f"Symlinked managed directory: {root}")
    files = {}
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            raise ValueError(f"Symlinked managed resource: {path}")
        if path.is_file():
            files[path.relative_to(root).as_posix()] = {
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "mode": path.stat().st_mode & 0o777,
            }
    return files


def managed_paths(repo):
    for name in ("vendor", "vendor/emil", "vendor/emil.lock.json", *ADAPTED,
                 *(f"{name}/LICENSE" for name in ADAPTED)):
        if (repo / name).is_symlink():
            raise ValueError(f"Managed path must not be a symlink: {name}")


def check(repo):
    managed_paths(repo)
    lock = json.loads((repo / "vendor/emil.lock.json").read_text())
    if lock["repository"] != REPOSITORY or not re.fullmatch(r"[0-9a-f]{40}", lock["revision"]):
        raise ValueError("Invalid upstream provenance")
    source = repo / "vendor/emil"
    if inventory(source) != lock["files"]:
        raise ValueError("Snapshot bytes, modes or inventory drifted")
    license_bytes = (source / "LICENSE").read_bytes()
    for name in ADAPTED:
        if not (source / "skills" / name / "SKILL.md").is_file():
            raise ValueError(f"Missing adapted skill source: {name}")
        if (repo / name / "LICENSE").read_bytes() != license_bytes:
            raise ValueError(f"License drifted: {name}")
    print(f'OK: {len(lock["files"])} source files, {len(ADAPTED)} host licenses; pin {lock["revision"]}')


def install(repo, source, revision):
    managed_paths(repo)
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("Revision must be a full lowercase commit SHA")
    if git(source, "rev-parse", f"{revision}^{{commit}}").decode().strip() != revision:
        raise ValueError("Revision must identify a commit")
    payload = {}
    for entry in git(source, "ls-tree", "-rz", revision).split(b"\0"):
        if not entry:
            continue
        header, raw_path = entry.split(b"\t", 1)
        path = raw_path.decode("utf-8")
        if not (path.startswith("skills/") or path in ROOT_FILES):
            continue
        mode, kind, oid = header.decode().split()
        if PurePosixPath(path).is_absolute() or ".." in PurePosixPath(path).parts or kind != "blob" or mode not in ("100644", "100755"):
            raise ValueError(f"Unsafe upstream entry: {path}")
        payload[path] = (git(source, "cat-file", "blob", oid), int(mode[-3:], 8))
    required = ROOT_FILES | {f"skills/{name}/SKILL.md" for name in ADAPTED}
    if not required <= payload.keys():
        raise ValueError(f"Missing source resources: {sorted(required - payload.keys())}")
    license_bytes = payload["LICENSE"][0]
    if b"Copyright (c) 2026 Emil Kowalski" not in license_bytes or b"Permission is hereby granted" not in license_bytes:
        raise ValueError("Upstream license changed; review before updating importer")
    destination = repo / "vendor/emil"
    lock_path = repo / "vendor/emil.lock.json"
    if lock_path.exists():
        check(repo)
    elif destination.exists():
        raise ValueError("Import would overwrite unmanaged files")
    for name in ADAPTED:
        if not (repo / name).is_dir():
            raise ValueError(f"Missing host adaptation: {name}")
    repo.joinpath("vendor").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="emil-import-") as temporary:
        stage = Path(temporary) / "source"
        stage.mkdir()
        for path, (data, mode) in payload.items():
            target = stage / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            target.chmod(mode)
        lock = {"repository": REPOSITORY, "revision": revision, "files": inventory(stage)}
        if destination.exists():
            shutil.rmtree(destination)
        shutil.move(str(stage), destination)
    for name in ADAPTED:
        (repo / name / "LICENSE").write_bytes(license_bytes)
    lock_path.write_text(json.dumps(lock, indent=2) + "\n")
    check(repo)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, help="separate upstream Git checkout")
    parser.add_argument("--revision", help="reviewed immutable commit SHA")
    parser.add_argument("--check", action="store_true", help="verify local bytes without writes or network")
    args = parser.parse_args()
    if args.check:
        if args.source or args.revision:
            parser.error("--check reads local state; omit --source and --revision")
        check(args.repo_root.resolve())
    else:
        if not args.source or not args.revision:
            parser.error("refresh requires --source and --revision")
        install(args.repo_root.resolve(), args.source.resolve(), args.revision)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError, subprocess.CalledProcessError) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
