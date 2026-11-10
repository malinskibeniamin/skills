#!/usr/bin/env python3
"""Import reviewed shadcn/improve Git blobs; verify offline or against the source pin."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


REPOSITORY = "https://github.com/shadcn/improve"
PREFIX = "skills/improve/"
REQUIRED = {"LICENSE.md"} | {PREFIX + name for name in (
    "SKILL.md", "references/audit-playbook.md", "references/closing-the-loop.md",
    "references/plan-template.md",
)}
LICENSE_DIGEST = "00ff8408e93e2ecc4d90c0edeabdf434100c3aff50acc5d330e17eccd4a3faa5"


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
            files[path.relative_to(root).as_posix()] = (
                path.read_bytes(), path.stat().st_mode & 0o777)
        elif not path.is_dir():
            raise ValueError(f"Unsupported managed resource: {path}")
    return files


def records(payload):
    return {name: {"sha256": hashlib.sha256(data).hexdigest(), "mode": mode}
            for name, (data, mode) in sorted(payload.items())}


def validate(payload):
    if not REQUIRED <= payload.keys():
        raise ValueError(f"Missing required resources: {sorted(REQUIRED - payload.keys())}")
    for name, (_, mode) in payload.items():
        path = PurePosixPath(name)
        if (path.is_absolute() or ".." in path.parts or mode not in (0o644, 0o755)
                or (name != "LICENSE.md" and not name.startswith(PREFIX))):
            raise ValueError(f"Unsafe snapshot entry: {name}")
    if hashlib.sha256(payload["LICENSE.md"][0]).hexdigest() != LICENSE_DIGEST:
        raise ValueError("Upstream license changed; review before refresh")
    if not payload[PREFIX + "SKILL.md"][0].startswith(b"---\nname: improve\n"):
        raise ValueError("Upstream skill identity changed; review before refresh")


def source_payload(source, revision):
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
        if path != "LICENSE.md" and not path.startswith(PREFIX):
            continue
        mode, kind, oid = header.decode().split()
        if kind != "blob" or mode not in ("100644", "100755"):
            raise ValueError(f"Unsafe upstream entry: {path}")
        payload[path] = (git(source, "cat-file", "blob", oid), int(mode[-3:], 8))
    validate(payload)
    return payload


def managed_paths(repo):
    for name in ("vendor", "vendor/shadcn-improve", "vendor/shadcn-improve.lock.json",
                 "improve", "improve/LICENSE.md"):
        if (repo / name).is_symlink():
            raise ValueError(f"Managed path must not be a symlink: {name}")


def check(repo, source=None):
    managed_paths(repo)
    lock = json.loads((repo / "vendor/shadcn-improve.lock.json").read_text())
    if lock["repository"] != REPOSITORY or not re.fullmatch(r"[0-9a-f]{40}", lock["revision"]):
        raise ValueError("Invalid upstream provenance")
    payload = inventory(repo / "vendor/shadcn-improve")
    validate(payload)
    if records(payload) != lock["files"]:
        raise ValueError("Snapshot bytes, modes or inventory drifted")
    license_path = repo / "improve/LICENSE.md"
    if (license_path.read_bytes(), license_path.stat().st_mode & 0o777) != payload["LICENSE.md"]:
        raise ValueError("Distributed improve license drifted")
    if source is not None and payload != source_payload(source, lock["revision"]):
        raise ValueError("Snapshot differs from the recorded upstream commit")
    proof = "upstream verified" if source is not None else "offline lock verified"
    print(f'OK: {len(payload)} shadcn/improve files; pin {lock["revision"]}; {proof}')


def install(repo, source, revision):
    managed_paths(repo)
    payload = source_payload(source, revision)
    destination = repo / "vendor/shadcn-improve"
    lock_path = repo / "vendor/shadcn-improve.lock.json"
    if lock_path.exists():
        check(repo)
    elif destination.exists():
        raise ValueError("Import would overwrite unmanaged files")
    else:
        license_path = repo / "improve/LICENSE.md"
        # Only the known pre-pin attribution may be migrated on first import.
        legacy = b"MIT License\n\nVendored from https://github.com/shadcn/improve, MIT \xc2\xa9 shadcn.\n"
        if license_path.exists() and license_path.read_bytes() != legacy:
            raise ValueError("Import would overwrite an unmanaged improve license")
    repo.joinpath("vendor").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="shadcn-improve-import-") as temp:
        stage = Path(temp) / "source"
        stage.mkdir()
        for name, (data, mode) in payload.items():
            target = stage / name
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            target.chmod(mode)
        lock = {"repository": REPOSITORY, "revision": revision, "files": records(payload)}
        if destination.exists():
            shutil.rmtree(destination)
        shutil.move(str(stage), destination)
    lock_path.write_text(json.dumps(lock, indent=2) + "\n")
    license_path = repo / "improve/LICENSE.md"
    license_path.parent.mkdir(exist_ok=True)
    license_path.write_bytes(payload["LICENSE.md"][0])
    license_path.chmod(payload["LICENSE.md"][1])
    check(repo, source)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, help="trusted separate upstream Git checkout")
    parser.add_argument("--revision", help="reviewed immutable commit SHA; refresh only")
    parser.add_argument("--check", action="store_true", help="verify without writing; optional --source proves origin")
    args = parser.parse_args()
    if args.check:
        if args.revision:
            parser.error("--check uses the locked revision; omit --revision")
        check(args.repo_root.resolve(), args.source.resolve() if args.source else None)
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
