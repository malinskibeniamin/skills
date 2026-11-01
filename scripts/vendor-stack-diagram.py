#!/usr/bin/env python3
"""Import a reviewed stack-diagram skill from committed Git blobs; check offline."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


REPOSITORY = "https://github.com/caru-ini/stack-diagram"
PREFIX = "skills/stack-diagram/"
REQUIRED = {"LICENSE"} | {PREFIX + name for name in (
    "SKILL.md", "LICENSE", "assets/template.html", "references/geometry.md",
    "references/tsx.md", "scripts/build.py", "scripts/fetch_icons.py",
    "scripts/render_png.py", "assets/fonts/Geist.woff2", "assets/fonts/JetBrainsMono.woff2",
    "assets/fonts/OFL-Geist.txt", "assets/fonts/OFL-JetBrainsMono.txt",
    "assets/fonts/README.md", *(f"assets/generic/{name}.svg" for name in
                              ("user", "browser", "device", "internet", "server")),
)}

# Any upstream license-byte change requires an explicit review of these pins.
LICENSE_DIGESTS = {
    'LICENSE':
        '7b153fc3f5f1ccce2b9ac98a35301c666c025db85d6c44565e13304774d144a9',
    'skills/stack-diagram/LICENSE':
        'be10012fc23bb7f2e332d62312b80cfca01c3eb7abd8970ebb1cdf8ff5b04faa',
    'skills/stack-diagram/assets/fonts/OFL-Geist.txt':
        'c683bfbcc7e087f5d37a54ef628f10387c451a83ddc459b151403a164ac46c90',
    'skills/stack-diagram/assets/fonts/OFL-JetBrainsMono.txt':
        '8790c0909f720c509810f95268779450cd6b0aa75b6d24e32f0878afe068427c',
}


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


def validate(payload):
    if not REQUIRED <= payload.keys():
        raise ValueError(f"Missing required resources: {sorted(REQUIRED - payload.keys())}")
    if any(path != "LICENSE" and not path.startswith(PREFIX) for path in payload):
        raise ValueError("Unexpected snapshot paths")
    for path, digest in LICENSE_DIGESTS.items():
        if hashlib.sha256(payload[path][0]).hexdigest() != digest:
            raise ValueError(f"Upstream license changed; review before refresh: {path}")
    if not payload[PREFIX + "SKILL.md"][0].startswith(b"---\nname: stack-diagram\n"):
        raise ValueError("Upstream skill identity changed; review before refresh")


def managed_paths(repo):
    for name in ("vendor", "vendor/stack-diagram", "vendor/stack-diagram.lock.json"):
        if (repo / name).is_symlink():
            raise ValueError(f"Managed path must not be a symlink: {name}")


def check(repo):
    managed_paths(repo)
    lock = json.loads((repo / "vendor/stack-diagram.lock.json").read_text())
    if lock["repository"] != REPOSITORY or not re.fullmatch(r"[0-9a-f]{40}", lock["revision"]):
        raise ValueError("Invalid upstream provenance")
    snapshot = repo / "vendor/stack-diagram"
    files = inventory(snapshot)
    if files != lock["files"]:
        raise ValueError("Snapshot bytes, modes or inventory drifted")
    validate({name: ((snapshot / name).read_bytes(), record["mode"])
              for name, record in files.items()})
    print(f'OK: {len(files)} stack-diagram files; pin {lock["revision"]}')


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
        if path != "LICENSE" and not path.startswith(PREFIX):
            continue
        mode, kind, oid = header.decode().split()
        if PurePosixPath(path).is_absolute() or ".." in PurePosixPath(path).parts or kind != "blob" or mode not in ("100644", "100755"):
            raise ValueError(f"Unsafe upstream entry: {path}")
        payload[path] = (git(source, "cat-file", "blob", oid), int(mode[-3:], 8))
    validate(payload)
    destination = repo / "vendor/stack-diagram"
    lock_path = repo / "vendor/stack-diagram.lock.json"
    if lock_path.exists():
        check(repo)
    elif destination.exists():
        raise ValueError("Import would overwrite unmanaged files")
    repo.joinpath("vendor").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="stack-diagram-import-") as temp:
        stage = Path(temp) / "source"
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
    lock_path.write_text(json.dumps(lock, indent=2) + "\n")
    check(repo)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, help="separate upstream Git checkout")
    parser.add_argument("--revision", help="reviewed immutable commit SHA")
    parser.add_argument("--check", action="store_true", help="verify bytes/modes offline without writing")
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
