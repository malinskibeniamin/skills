#!/usr/bin/env python3
"""Vendor the complete reviewed interface suite without replacing host workflows."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


REPOSITORY = "https://github.com/jakubkrehel/skills"
# Changes to this inventory or invocation policy require a compatibility review.
EXPLICIT = {"interface-review", "explain-interface", "break", "state-machine", "variant"}
METADATA = {
    "better-interface": ("Review interfaces through existing visual review", "Review whole screens or flows across accessibility, layout, copy, typography, color and polish using the existing visual-review owner."),
    "better-ui": ("Polish surfaces, icons and interaction details", "Use for surface geometry, optical alignment, shadows, icon states and UI polish; existing animate guidance owns motion."),
    "better-typography": ("Set and review readable interface typography", "Use for type scales, font loading, line height, wrapping, truncation and numeric alignment within the project's type system."),
    "better-colors": ("Build and measure semantic interface color systems", "Use for palettes, semantic color tokens, theme pairs, gamut and measured contrast; preserve existing tokens and accessibility requirements."),
    "better-accessibility": ("Extend existing accessibility verification with WCAG", "Use for WCAG-grounded keyboard, focus, names, forms, announcements, motion and zoom checks through the existing accessibility owner."),
    "better-layout": ("Review grouping and responsive interface structure", "Use for grouping, reading order, responsive structure, localization and RTL; preserve project density and verify actual layout failures."),
    "better-writing": ("Extend existing UI copy guidance with interface patterns", "Use for product vocabulary, translated strings, labels, errors, empty states and confirmations through the existing ux-copy owner."),
    "interface-review": ("Review interface regressions in a named change", "Review introduced or regressed interface issues in a branch, PR or uncommitted change."),
    "explain-interface": ("Explain an interface or effect from observed evidence", "Explain a named site or effect from a URL or image; label measured, derived and inferred claims."),
    "break": ("Build an explicitly requested component stress page", "Build a temporary component stress page on explicit request; compose break-ui and prototype."),
    "build-design": ("Implement a supplied design with existing components", "Use when implementing a Figma file or design image with the project's existing tokens and components through development-lifecycle."),
    "teardown": ("Create evidence-grounded technical illustrations", "Use for technical object or layered-concept illustrations with editable geometry and SVG, PNG or PDF export; not manufacturing drawings."),
    "state-machine": ("Build an explicitly requested component state workbench", "Build a real-component state switcher with isolated fixtures; not state-machine architecture."),
    "variant": ("Explore explicitly requested component design variants", "Explore component design directions on explicit request through the existing prototype owner."),
}


def git(source, *args):
    return subprocess.check_output(["git", "-C", str(source), *args])


def inventory(root):
    if root.is_symlink():
        raise ValueError(f"Symlinked managed directory: {root}")
    files = {}
    for path in sorted(root.rglob("*")):
        if path.is_symlink():
            raise ValueError(f"Symlinked managed file: {path}")
        if path.is_file():
            files[path.relative_to(root).as_posix()] = {
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "mode": path.stat().st_mode & 0o777,
            }
    return files


def discover(payload):
    names = set()
    for path, (data, _) in payload.items():
        if PurePosixPath(path).name != "SKILL.md":
            continue
        name = PurePosixPath(path).parent.name
        if name not in METADATA or path != f"skills/{name}/SKILL.md":
            raise ValueError(f"Unadapted upstream skill: {path}")
        if not re.match(rf"---\nname: {re.escape(name)}\n", data.decode("utf-8")):
            raise ValueError(f"Invalid upstream frontmatter: {path}")
        frontmatter = re.match(r"---\n(.*?)\n---", data.decode("utf-8"), re.S)
        if not frontmatter or not re.search(r"^description: .+", frontmatter[1], re.M):
            raise ValueError(f"Invalid upstream frontmatter: {path}")
        explicit = bool(re.search(r"^disable-model-invocation: true$", frontmatter[1], re.M))
        if explicit != (name in EXPLICIT):
            raise ValueError(f"Unreviewed invocation policy: {name}")
        names.add(name)
    if names != set(METADATA) or not {"LICENSE", "README.md"} <= payload.keys():
        raise ValueError("All 14 reviewed skills, LICENSE and README.md are required")
    return [{"name": name, "source": f"skills/{name}/SKILL.md",
             "registration": f"./jakubkrehel-skills/{name}/",
             "explicit_only": name in EXPLICIT,
             "short_description": METADATA[name][0], "description": METADATA[name][1]}
            for name in sorted(names)]


def adapter(skill):
    policy = "disable-model-invocation: true\n" if skill["explicit_only"] else ""
    return (f'---\nname: {skill["name"]}\ndescription: {json.dumps(skill["description"])}\n'
            f"{policy}---\n\n"
            "<!-- Generated by scripts/vendor-jakubkrehel.py; do not edit. -->\n\n"
            "Read [host compatibility](../../shared/INTERFACES.md) first, including the "
            f'`{skill["name"]}` branch. It overrides conflicting source instructions.\n\n'
            f'Read the complete [upstream skill](../../vendor/jakubkrehel/{skill["source"]}). '
            "Resolve relative references there. Compose through the existing owners mapped "
            "in compatibility; reuse already loaded guidance. Loading grants no execution "
            "or delegation permission.\n")


def managed_paths(repo):
    for name in ("vendor", "vendor/jakubkrehel", "vendor/jakubkrehel.lock.json", "vendor/jakubkrehel-patches", "jakubkrehel-skills",
                 ".claude-plugin", ".claude-plugin/plugin.json"):
        if (repo / name).is_symlink():
            raise ValueError(f"Managed path must not be a symlink: {name}")


def patch_inventory(repo):
    patches = inventory(repo / "vendor/jakubkrehel-patches")
    if any(not name.endswith(".patch") for name in patches):
        raise ValueError("Security patch directory accepts only reviewed .patch files")
    return patches


def check(repo, *, check_patch_inputs=True, refresh_descriptions=False):
    managed_paths(repo)
    lock = json.loads((repo / "vendor/jakubkrehel.lock.json").read_text())
    if lock["repository"] != REPOSITORY or not re.fullmatch(r"[0-9a-f]{40}", lock["revision"]):
        raise ValueError("Invalid upstream provenance")
    if check_patch_inputs and patch_inventory(repo) != lock.get("patches", {}):
        raise ValueError("Security patch inputs drifted; review and rerun the importer")
    source = repo / "vendor/jakubkrehel"
    files = inventory(source)
    if files != lock["files"]:
        raise ValueError("Snapshot bytes, executable modes or inventory drifted")
    skills = discover({p: ((source / p).read_bytes(), r["mode"]) for p, r in files.items()})
    comparable = lambda rows: [{k: v for k, v in row.items() if k not in ("description", "short_description")} for row in rows]
    if (comparable(skills) != comparable(lock["skills"]) if refresh_descriptions else skills != lock["skills"]):
        raise ValueError("Skill metadata drifted")
    # During refresh, validate published adapters against their published text,
    # while still requiring current names, source paths and invocation policies.
    published_skills = lock["skills"] if refresh_descriptions else skills
    expected = {f'{s["name"]}/SKILL.md': {"sha256": hashlib.sha256(adapter(s).encode()).hexdigest(), "mode": 0o644}
                for s in published_skills}
    if inventory(repo / "jakubkrehel-skills") != expected:
        raise ValueError("Adapter bytes, modes or inventory drifted")
    entries = json.loads((repo / ".claude-plugin/plugin.json").read_text())["skills"]
    registered = [p for p in entries if p.startswith("./jakubkrehel-skills/") or Path(p).name in METADATA]
    if sorted(registered) != sorted(s["registration"] for s in skills):
        raise ValueError("Each jakubkrehel skill must have exactly one host owner")
    print(f'OK: 14 skills, 14 adapters; {len(files)} files verified (pin {lock["revision"]})')
    return lock


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
        if not (path.startswith("skills/") or path in ("LICENSE", "README.md")):
            continue
        mode, kind, oid = header.decode().split()
        if PurePosixPath(path).is_absolute() or ".." in PurePosixPath(path).parts or kind != "blob" or mode not in ("100644", "100755"):
            raise ValueError(f"Unsafe upstream entry: {path}")
        payload[path] = (git(source, "cat-file", "blob", oid), int(mode[-3:], 8))
    skills = discover(payload)
    destination = repo / "vendor/jakubkrehel"
    adapters = repo / "jakubkrehel-skills"
    lock_path = repo / "vendor/jakubkrehel.lock.json"
    previous = check(repo, check_patch_inputs=False, refresh_descriptions=True) if lock_path.exists() else None
    if not previous and (destination.exists() or adapters.exists()):
        raise ValueError("Import would overwrite unmanaged files")
    manifest_path = repo / ".claude-plugin/plugin.json"
    manifest = json.loads(manifest_path.read_text())
    retained = [p for p in manifest["skills"] if not p.startswith("./jakubkrehel-skills/")]
    if {Path(p).name for p in retained} & set(METADATA):
        raise ValueError("Import would collide with an existing skill")
    repo.joinpath("vendor").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="jakubkrehel-import-") as temp:
        stage = Path(temp) / "source"
        stage.mkdir()
        for path, (data, mode) in payload.items():
            target = stage / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            target.chmod(mode)
        upstream_files = inventory(stage)
        patches = patch_inventory(repo)
        for name in patches:
            patch = (repo / "vendor/jakubkrehel-patches" / name).resolve()
            # Stage outside any checkout: Git applies only to this disposable tree.
            subprocess.run(["git", "apply", "--check", str(patch)], cwd=stage, check=True)
            subprocess.run(["git", "apply", str(patch)], cwd=stage, check=True)
        files = inventory(stage)
        if files.keys() != upstream_files.keys():
            raise ValueError("Security patches must preserve the complete upstream inventory")
        for name, record in files.items():
            if record != upstream_files[name] and not name.startswith(("skills/teardown/assets/", "skills/teardown/scripts/")):
                raise ValueError(f"Security patch outside teardown helpers: {name}")
        lock = {"repository": REPOSITORY, "revision": revision, "skills": skills,
                "patches": patches, "upstream_files": upstream_files, "files": files}
        if destination.exists():
            shutil.rmtree(destination)
        shutil.move(str(stage), destination)
    if adapters.exists():
        shutil.rmtree(adapters)
    for skill in skills:
        directory = adapters / skill["name"]
        directory.mkdir(parents=True)
        (directory / "SKILL.md").write_text(adapter(skill))
        (directory / "SKILL.md").chmod(0o644)
    lock_path.write_text(json.dumps(lock, indent=2) + "\n")
    registrations = retained + [s["registration"] for s in skills]
    if manifest["skills"] != registrations:
        manifest["skills"] = registrations
        manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    check(repo)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, help="separate upstream Git checkout")
    parser.add_argument("--revision", help="reviewed immutable commit SHA")
    parser.add_argument("--check", action="store_true", help="verify local snapshot without writing or networking")
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
