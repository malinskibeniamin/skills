#!/usr/bin/env python3
"""Import complete skill directories from a reviewed T3 Code Git commit."""

import argparse
import hashlib
import json
import posixpath
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


REPOSITORY = "https://github.com/pingdotgg/t3code"
ROOTS = (".agents/skills", ".repos/effect-smol/.agents/skills")
LICENSES = ("LICENSE", ".repos/effect-smol/LICENSE")
METADATA = {
    "ai-docs": ("Maintain Effect's generated AI documentation", "Use when editing Effect's ai-docs/src or regenerating its LLMS.md. Not general documentation authoring."),
    "bundle-analysis": ("Measure bundle size and explain included dependencies", "Use when comparing production bundles, inspecting module composition, or maintaining bundle fixtures."),
    "changesets": ("Finalize consumer release notes and breaking changes", "Use when finalizing release impact in a repository that uses Changesets. Not release publication."),
    "ci-maintenance": ("Audit GitHub Actions jobs and their trust boundaries", "Use when authoring or reviewing GitHub Actions workflows, composite actions, permissions, events, artifacts, or concurrency."),
    "contribution-triage": ("Assess contributions against trusted repository policy", "Use for contribution eligibility and authorized PR moderation against the target repository's policy. Not full code review or support diagnostics."),
    "dependency-maintenance": ("Coordinate dependency roles and toolchain compatibility", "Use when adding or moving dependencies or coordinating runtime, compiler, package-manager, image, patch, and native-build compatibility."),
    "effect-development": ("Find version-matched Effect development guidance", "Use when implementing or reviewing Effect compositions and patterns. For installation use effect-ts; for app migration use effect-v3-to-v4."),
    "jsdocs": ("Document public APIs with checked runnable examples", "Use when authoring or reviewing public TypeScript API JSDoc, examples, links, or documentation diagnostics."),
    "migration-guidance": ("Maintain Effect's generated API migration reference", "Use when maintaining Effect's v3-to-v4 migration annotations or generated reference. Not migrating an application."),
    "package-development": ("Register and verify publishable workspace packages", "Use when adding, renaming, moving, or publishing JavaScript workspace packages, including exports, dependencies, and packed contents."),
    "performance-analysis": ("Measure runtime and TypeScript compiler regressions", "Use for library runtime benchmarks or TypeScript compiler-cost measurements and regression thresholds. Not web interaction profiling."),
    "test-development": ("Verify runtime behavior and public compiler contracts", "Use when selecting runtime versus compiler-contract coverage, including inference, assignability, overloads, or displayed TypeScript types."),
    "test-t3-app": ("Verify T3 Code web and desktop in isolated state", "Use only in a T3 Code checkout for web or desktop verification through its built-in Browser panel, pairing recovery, and SQLite fixtures."),
    "test-t3-mobile": ("Verify T3 Code native clients through its Device panel", "Use only in a T3 Code checkout for native iOS or Android verification through its Device panel and returned AgentDevice command."),
    "vendored-assets": ("Update vendored assets with pinned provenance and licenses", "Use when importing or updating checked-in third-party code, skills, assets, registries, schemas, or generated snapshots."),
}


def git(source, *args):
    return subprocess.check_output(["git", "-C", str(source), *args])


def inventory(source):
    files = {}
    if source.is_symlink():
        raise ValueError(f"Symlinked snapshot: {source}")
    for path in sorted(source.rglob("*")):
        if path.is_symlink():
            raise ValueError(f"Symlinked source file: {path}")
        if path.is_file():
            files[path.relative_to(source).as_posix()] = {
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "mode": path.stat().st_mode & 0o777,
            }
    return files


def discover(payload):
    skills = []
    names = set()
    for path, (data, _) in sorted(payload.items()):
        if PurePosixPath(path).name != "SKILL.md":
            continue
        name = PurePosixPath(path).parent.name
        if name not in METADATA or name in names:
            raise ValueError(f"Unadapted or duplicate upstream skill: {name}")
        text = data.decode("utf-8")
        frontmatter = re.match(r"---\n(.*?)\n---", text, re.S)
        if not frontmatter or not re.search(rf"^name: {re.escape(name)}$", frontmatter[1], re.M):
            raise ValueError(f"Invalid skill frontmatter: {path}")
        names.add(name)
        short, description = METADATA[name]
        skills.append({"name": name, "source": path, "description": description,
                       "short_description": short,
                       "explicit_only": bool(re.search(r"^disable-model-invocation: true$", frontmatter[1], re.M))})
    if not skills or any(path not in payload for path in LICENSES):
        raise ValueError("Both T3 and Effect licenses and at least one skill are required")
    return skills


def adapter(skill):
    invocation = "disable-model-invocation: true\n" if skill["explicit_only"] else ""
    return (f'---\nname: {skill["name"]}\ndescription: {json.dumps(skill["description"])}\n'
            f"{invocation}---\n\n<!-- Generated by scripts/vendor-t3code-skills.py; do not edit. -->\n\n"
            "Read [host compatibility](../../shared/T3CODE-SKILLS.md) first and apply the "
            f'`{skill["name"]}` branch. It takes precedence over the source snapshot.\n\n'
            f'Read the complete [upstream skill](../../vendor/t3code/{skill["source"]}). '
            "Resolve its relative references from that source directory. Repository-root "
            "commands and paths refer to the target checkout, never this plugin's vendor directory.\n")


def registration(skill):
    return f'./t3code-skills/{skill["name"]}/'


def managed_paths(repo):
    paths = ("vendor", "vendor/t3code", "vendor/t3code-skills.lock.json",
             "t3code-skills", ".claude-plugin", ".claude-plugin/plugin.json")
    if any((repo / path).is_symlink() for path in paths):
        raise ValueError("Managed paths must not be symlinks")


def linked_files(path, data):
    if not path.endswith(".md"):
        return []
    targets = []
    fence = None
    for line in data.decode("utf-8").splitlines():
        marker = re.match(r"^\s*(`{3,}|~{3,})", line)
        if marker:
            if fence is None:
                fence = marker[1][0]
            elif marker[1][0] == fence:
                fence = None
            continue
        if fence:
            continue
        for target in re.findall(r"\]\(([^)]+)\)", line):
            if target.startswith("#") or re.match(r"^[A-Za-z][A-Za-z0-9+.-]*:", target):
                continue
            target = target.strip("<>").split("#", 1)[0].split(" ", 1)[0]
            resolved = posixpath.normpath(posixpath.join(posixpath.dirname(path), target))
            if resolved.startswith(("../", "/")):
                raise ValueError(f"Support link escapes upstream repository: {path} -> {target}")
            targets.append(resolved)
    return targets


def read_snapshot(source, revision):
    entries = {}
    for entry in git(source, "ls-tree", "-rz", revision).split(b"\0"):
        if entry:
            header, path = entry.split(b"\t", 1)
            name = path.decode("utf-8")
            if PurePosixPath(name).is_absolute() or ".." in PurePosixPath(name).parts:
                raise ValueError(f"Unsafe upstream path: {name}")
            entries[name] = header.decode().split()
    selected = {p for p in entries if p in LICENSES or any(p.startswith(root + "/") for root in ROOTS)}
    pending = list(selected)
    payload = {}
    while pending:
        path = pending.pop()
        if path in payload:
            continue
        if path not in entries:
            raise ValueError(f"Linked support file absent from pinned commit: {path}")
        mode, kind, oid = entries[path]
        if kind != "blob" or mode not in ("100644", "100755"):
            raise ValueError(f"Unsupported upstream entry: {path}")
        data = git(source, "cat-file", "blob", oid)
        if path not in selected and path.endswith(".md"):
            # Policy documents point into the full app; keep their original bytes
            # and render pinned links instead of recursively importing that app.
            payload[path + ".upstream"] = (data, int(mode[-3:], 8))
            references = iter(linked_files(path, data))
            lines = []
            fence = None
            for line in data.decode("utf-8").splitlines(keepends=True):
                marker = re.match(r"^\s*(`{3,}|~{3,})", line)
                if marker:
                    fence = marker[1][0] if fence is None else None if marker[1][0] == fence else fence
                elif not fence:
                    def rebase_link(match):
                        target = match[1]
                        if target.startswith("#") or re.match(r"^[A-Za-z][A-Za-z0-9+.-]*:", target):
                            return match[0]
                        resolved = next(references)
                        is_file = resolved in entries
                        if not is_file and not any(p.startswith(resolved + "/") for p in entries):
                            raise ValueError(f"Upstream policy link does not resolve: {path} -> {resolved}")
                        fragment = "#" + target.split("#", 1)[1] if "#" in target else ""
                        kind = "blob" if is_file else "tree"
                        return f"]({REPOSITORY}/{kind}/{revision}/{resolved}{fragment})"
                    line = re.sub(r"\]\(([^)]+)\)", rebase_link, line)
                lines.append(line)
            data = (f"<!-- Pinned policy reference; original bytes: {PurePosixPath(path).name}.upstream -->\n\n" + "".join(lines)).encode()
        payload[path] = (data, int(mode[-3:], 8))
        if path in selected:
            pending.extend(linked_files(path, data))
    return payload


def check(repo):
    managed_paths(repo)
    lock = json.loads((repo / "vendor/t3code-skills.lock.json").read_text())
    if lock["repository"] != REPOSITORY or not re.fullmatch(r"[0-9a-f]{40}", lock["revision"]):
        raise ValueError("Invalid upstream provenance")
    source = repo / "vendor/t3code"
    files = inventory(source)
    if files != lock["files"]:
        raise ValueError("Snapshot bytes, executable modes, or file inventory drifted")
    payload = {path: ((source / path).read_bytes(), record["mode"]) for path, record in files.items()}
    skills = discover(payload)
    if skills != lock["skills"]:
        raise ValueError("Upstream skill inventory drifted")
    adapters = repo / "t3code-skills"
    if adapters.is_symlink() or {p.name for p in adapters.iterdir()} != {s["name"] for s in skills}:
        raise ValueError("Adapter inventory drifted")
    for skill in skills:
        directory = adapters / skill["name"]
        if directory.is_symlink() or sorted(p.name for p in directory.iterdir()) != ["SKILL.md"]:
            raise ValueError(f'Unexpected adapter files: {skill["name"]}')
        path = directory / "SKILL.md"
        if path.is_symlink() or path.read_text() != adapter(skill):
            raise ValueError(f'Adapter drift: {skill["name"]}')
    manifest = json.loads((repo / ".claude-plugin/plugin.json").read_text())
    registered = [s for s in manifest["skills"] if s.startswith("./t3code-skills/")]
    if sorted(registered) != sorted(registration(s) for s in skills):
        raise ValueError("Every adapter must be registered exactly once")
    print(f'OK: {len(skills)} skills; {len(files)} snapshot files verified (pin {lock["revision"]})')
    return lock


def install(repo, source, revision):
    managed_paths(repo)
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("Revision must be a full lowercase commit SHA")
    if git(source, "rev-parse", f"{revision}^{{commit}}").decode().strip() != revision:
        raise ValueError("Revision must identify a Git commit, not a moving ref")
    payload = read_snapshot(source, revision)
    skills = discover(payload)
    destination = repo / "vendor/t3code"
    adapters = repo / "t3code-skills"
    lock_path = repo / "vendor/t3code-skills.lock.json"
    previous = check(repo) if lock_path.exists() else None
    if not previous and (destination.exists() or adapters.exists()):
        raise ValueError("Import would overwrite unmanaged files")
    manifest_path = repo / ".claude-plugin/plugin.json"
    manifest = json.loads(manifest_path.read_text())
    retained = [s for s in manifest["skills"] if not s.startswith("./t3code-skills/")]
    existing_names = {Path(s).name for s in retained}
    if existing_names & {s["name"] for s in skills}:
        raise ValueError("Import would collide with an existing skill")
    repo.joinpath("vendor").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=repo / "vendor", prefix=".t3code-import-") as temp:
        stage = Path(temp) / "source"
        stage.mkdir()
        for path, (data, mode) in payload.items():
            target = stage / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            target.chmod(mode)
        lock = {"repository": REPOSITORY, "revision": revision, "skills": skills, "files": inventory(stage)}
        # Existing managed output passed integrity checks; never remove a user's patches.
        if destination.exists():
            shutil.rmtree(destination)
        shutil.move(str(stage), destination)
    if adapters.exists():
        shutil.rmtree(adapters)
    for skill in skills:
        directory = adapters / skill["name"]
        directory.mkdir(parents=True)
        (directory / "SKILL.md").write_text(adapter(skill))
    lock_path.write_text(json.dumps(lock, indent=2) + "\n")
    registrations = retained + [registration(s) for s in skills]
    if manifest["skills"] != registrations:
        manifest["skills"] = registrations
        manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    check(repo)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, help="separate upstream Git checkout")
    parser.add_argument("--revision", help="reviewed immutable commit SHA")
    parser.add_argument("--check", action="store_true", help="verify bytes, modes, adapters and registration without writing")
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
