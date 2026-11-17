#!/usr/bin/env python3
"""Import every Matt Pocock skill at an immutable Git revision, without replacing host policy."""

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


REPOSITORY = "https://github.com/mattpocock/skills"
SNAPSHOT = "vendor/mattpocock/upstream"
ADAPTERS = "matt-skills"
LOCK = "vendor/mattpocock.lock.json"
PATCHES = "vendor/mattpocock-patches"
PATCH_TARGETS = {"skills/in-progress/animatic/scripts/animatic.mjs"}
OWNERS = {
    "ask-matt": "ask-ben", "code-review": "review",
    "grill-me": "grilling", "grill-with-docs": "grilling",
    "implement": "development-lifecycle",
    "setup-matt-pocock-skills": "work-automation-kit",
    **{name: name for name in (
        "codebase-design", "diagnosing-bugs", "domain-modeling", "implement-spec",
        "improve-codebase-architecture", "pr", "prototype", "research", "retro",
        "tdd", "to-spec", "to-tickets", "triage", "wayfinder", "wizard", "grilling",
        "handoff", "teach", "to-questionnaire", "wait-what", "writing-for-agents",
        "writing-beats", "writing-fragments", "writing-shape", "software-factory",
        "animatic", "setup-animatic", "constrain",
    )},
}


def git(source, *args):
    return subprocess.check_output(["git", "-C", str(source), *args])


def read_source(source, revision, prefix=None):
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
        selected = path.startswith(prefix + "/") if prefix else path.startswith("skills/")
        if not (selected or path in ("LICENSE", "README.md")):
            continue
        mode, kind, oid = header.decode().split()
        if PurePosixPath(path).is_absolute() or ".." in PurePosixPath(path).parts or kind != "blob" or mode not in ("100644", "100755"):
            raise ValueError(f"Unsafe upstream entry: {path}")
        payload[path] = (git(source, "cat-file", "blob", oid), int(mode[-3:], 8))
    if not {"LICENSE", "README.md"} <= payload.keys():
        raise ValueError("Upstream LICENSE and README.md are required")
    return payload


def validate_supplements(supplements, files):
    paths = set()
    for record in supplements:
        path = record["path"]
        if (not re.fullmatch(r"[0-9a-f]{40}", record["revision"])
                or not re.fullmatch(r"skills/[a-z0-9-]+/[a-z0-9-]+", path)
                or path in paths or f"{path}/SKILL.md" not in files
                or record["license_sha256"] != files["LICENSE"]["sha256"]):
            raise ValueError("Invalid supplemental provenance, skill path or license")
        paths.add(path)


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
    if not {"LICENSE", "README.md"} <= payload.keys():
        raise ValueError("Upstream LICENSE and README.md are required")
    skills = []
    names = set()
    for path, (data, _) in sorted(payload.items()):
        if PurePosixPath(path).name != "SKILL.md":
            continue
        text = data.decode("utf-8")
        frontmatter = re.match(r"---\n(.*?)\n---(?:\n|$)", text, re.S)
        if not frontmatter:
            raise ValueError(f"Invalid upstream frontmatter: {path}")
        name = re.search(r"^name: ([a-z0-9]+(?:-[a-z0-9]+)*)$", frontmatter[1], re.M)
        description = re.search(r"^description: (.+)$", frontmatter[1], re.M)
        if not name or not description or name[1] != PurePosixPath(path).parent.name:
            raise ValueError(f"Invalid upstream name or description: {path}")
        name = name[1]
        if name in names:
            raise ValueError(f"Duplicate upstream skill: {name}")
        names.add(name)
        skills.append({
            "name": f"matt-{name}", "upstream_name": name, "source": path,
            "owner": OWNERS.get(name), "registration": f"./{ADAPTERS}/matt-{name}/",
            "short_description": f"Matt Pocock source: {name.replace('-', ' ')} guidance",
            "description": f"Use the pinned Matt Pocock {name} skill with host compatibility rules.",
        })
    if not skills:
        raise ValueError("No upstream skills found")
    return sorted(skills, key=lambda skill: skill["name"])


def adapter(skill):
    owner = skill["owner"]
    owner_rule = (f'Read the existing [host owner](../../{owner}/SKILL.md); it remains authoritative. '
                  "Use the upstream snapshot as supporting reference, not a replacement workflow.\n\n") if owner else ""
    return (f'---\nname: {skill["name"]}\ndescription: {json.dumps(skill["description"])}\n'
            "disable-model-invocation: true\n---\n\n"
            "<!-- Generated by scripts/vendor-mattpocock.py; do not edit. -->\n\n"
            "Read [host compatibility](../../shared/MATT-POCOCK.md) first; it overrides conflicting source instructions.\n\n"
            + owner_rule
            + f'Read the complete [upstream skill](../../{SNAPSHOT}/{skill["source"]}). '
            "Resolve its relative references from that source directory. Loading grants no delegation, "
            "installation, scheduling or external-action permission.\n")


def managed_paths(repo):
    for name in ("vendor", "vendor/mattpocock", SNAPSHOT, LOCK, PATCHES, ADAPTERS,
                 ".claude-plugin", ".claude-plugin/plugin.json"):
        if (repo / name).is_symlink():
            raise ValueError(f"Managed path must not be a symlink: {name}")


def validate_registration(repo, skills, entries):
    actual = [p for p in entries if p.startswith(f"./{ADAPTERS}/")]
    if sorted(actual) != sorted(s["registration"] for s in skills):
        raise ValueError("Every upstream skill must have exactly one registered Matt adapter")
    for skill in skills:
        if skill["owner"]:
            owner = skill["owner"]
            if entries.count(f"./{owner}/") != 1 or not (repo / owner / "SKILL.md").is_file():
                raise ValueError(f"Missing or duplicate host owner: {owner}")


def patch_inventory(repo):
    patches = inventory(repo / PATCHES)
    if any(not name.endswith(".patch") for name in patches):
        raise ValueError("Patch directory accepts only reviewed .patch files")
    return patches


def validate_patch_scope(upstream_files, files):
    if files.keys() != upstream_files.keys():
        raise ValueError("Helper patches must preserve the complete upstream inventory")
    for name, record in files.items():
        if record["mode"] != upstream_files[name]["mode"] or (record != upstream_files[name] and name not in PATCH_TARGETS):
            raise ValueError(f"Patch outside approved animatic helper: {name}")


def check(repo, *, refresh_descriptions=False, check_patch_inputs=True):
    managed_paths(repo)
    lock = json.loads((repo / LOCK).read_text())
    if lock["repository"] != REPOSITORY or not re.fullmatch(r"[0-9a-f]{40}", lock["revision"]):
        raise ValueError("Invalid upstream provenance")
    if check_patch_inputs and patch_inventory(repo) != lock.get("patches", {}):
        raise ValueError("Patch inputs drifted; review and rerun the importer")
    if lock.get("patches") and "upstream_files" not in lock:
        raise ValueError("Patched snapshots must retain the upstream inventory")
    source = repo / SNAPSHOT
    files = inventory(source)
    if files != lock["files"]:
        raise ValueError("Snapshot bytes, executable modes or inventory drifted")
    validate_supplements(lock.get("supplements", []), lock.get("upstream_files", files))
    validate_patch_scope(lock.get("upstream_files", files), files)
    skills = discover({p: ((source / p).read_bytes(), record["mode"]) for p, record in files.items()})
    comparable = lambda rows: [{k: v for k, v in row.items() if k not in ("description", "short_description")} for row in rows]
    if (comparable(skills) != comparable(lock["skills"]) if refresh_descriptions else skills != lock["skills"]):
        raise ValueError("Skill inventory or owner mapping drifted")
    published_skills = lock["skills"] if refresh_descriptions else skills
    expected = {f'{s["name"]}/SKILL.md': {"sha256": hashlib.sha256(adapter(s).encode()).hexdigest(), "mode": 0o644}
                for s in published_skills}
    if inventory(repo / ADAPTERS) != expected:
        raise ValueError("Adapter bytes, modes or inventory drifted")
    validate_registration(repo, skills, json.loads((repo / ".claude-plugin/plugin.json").read_text())["skills"])
    print(f'OK: {len(skills)} skills and adapters; {len(files)} source files verified (pin {lock["revision"]})')
    return lock


def install(repo, source, revision, supplement_specs=None):
    managed_paths(repo)
    previous = check(repo, refresh_descriptions=True, check_patch_inputs=False) if (repo / LOCK).exists() else None
    if not previous and ((repo / SNAPSHOT).exists() or (repo / ADAPTERS).exists()):
        raise ValueError("Import would overwrite unmanaged files")
    payload = read_source(source, revision)
    if supplement_specs is None:
        supplement_specs = [f'{s["revision"]}:{s["path"]}' for s in (previous or {}).get("supplements", [])]
    supplements = []
    for spec in supplement_specs:
        supplemental_revision, separator, path = spec.partition(":")
        if not separator or not re.fullmatch(r"skills/[a-z0-9-]+/[a-z0-9-]+", path):
            raise ValueError("Supplement must be <full-sha>:skills/<category>/<skill>")
        extra = read_source(source, supplemental_revision, path)
        if extra["LICENSE"][0] != payload["LICENSE"][0]:
            raise ValueError("Supplement must share the retained upstream license")
        selected = {p: value for p, value in extra.items() if p.startswith(path + "/")}
        if f"{path}/SKILL.md" not in selected or payload.keys() & selected.keys():
            raise ValueError("Supplement must add a complete skill without replacing existing source; retire merged supplements explicitly")
        payload.update(selected)
        supplements.append({"revision": supplemental_revision, "path": path,
                            "license_sha256": hashlib.sha256(extra["LICENSE"][0]).hexdigest()})
    skills = discover(payload)
    manifest_path = repo / ".claude-plugin/plugin.json"
    manifest_text = manifest_path.read_text()
    manifest = json.loads(manifest_text)
    skills_match = re.search(r'"skills"\s*:\s*', manifest_text)
    if not skills_match:
        raise ValueError("Missing plugin skills array")
    published_entries, length = json.JSONDecoder().raw_decode(manifest_text[skills_match.end():])
    if published_entries != manifest["skills"]:
        raise ValueError("Ambiguous plugin skills array")
    # Preserve surviving entries in place: refreshing one vendor must not reorder
    # other vendors or create a diff when the pinned inputs are unchanged.
    registrations = [s["registration"] for s in skills]
    manifest["skills"] = [p for p in published_entries
                          if not p.startswith(f"./{ADAPTERS}/") or p in registrations]
    added = [p for p in registrations if p not in manifest["skills"]]
    insertion = max((i + 1 for i, p in enumerate(manifest["skills"])
                     if p.startswith(f"./{ADAPTERS}/")), default=len(manifest["skills"]))
    manifest["skills"][insertion:insertion] = added
    validate_registration(repo, skills, manifest["skills"])
    updated_manifest = manifest_text
    if manifest["skills"] != published_entries:
        entries_text = json.dumps(manifest["skills"], indent=2).replace("\n", "\n  ")
        updated_manifest = manifest_text[:skills_match.end()] + entries_text + manifest_text[skills_match.end() + length:]
    # Validate and stage the entire new inventory before replacing managed outputs.
    with tempfile.TemporaryDirectory(prefix="matt-import-") as temp:
        stage = Path(temp)
        for path, (data, mode) in payload.items():
            target = stage / "source" / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            target.chmod(mode)
        upstream_files = inventory(stage / "source")
        validate_supplements(supplements, upstream_files)
        patches = patch_inventory(repo)
        for name in patches:
            patch = (repo / PATCHES / name).resolve()
            subprocess.run(["git", "apply", "--check", str(patch)], cwd=stage / "source", check=True)
            subprocess.run(["git", "apply", str(patch)], cwd=stage / "source", check=True)
        files = inventory(stage / "source")
        validate_patch_scope(upstream_files, files)
        for skill in skills:
            target = stage / "adapters" / skill["name"] / "SKILL.md"
            target.parent.mkdir(parents=True)
            target.write_text(adapter(skill))
            target.chmod(0o644)
        for staged, destination in ((stage / "source", repo / SNAPSHOT), (stage / "adapters", repo / ADAPTERS)):
            if destination.exists():
                shutil.rmtree(destination)
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copytree(staged, destination)
    lock = {"repository": REPOSITORY, "revision": revision, "skills": skills,
            "patches": patches, "upstream_files": upstream_files, "files": files}
    if supplements:
        lock["supplements"] = supplements
    (repo / LOCK).write_text(json.dumps(lock, indent=2) + "\n")
    manifest_path.write_text(updated_manifest)
    if previous:
        changed = {p for p in previous["files"].keys() | files.keys() if previous["files"].get(p) != files.get(p)}
        old = {s["upstream_name"]: s for s in previous["skills"]}
        new = {s["upstream_name"]: s for s in skills}
        for name in sorted(old.keys() | new.keys()):
            skill = new.get(name) or old[name]
            prefixes = tuple(str(PurePosixPath(rows[name]["source"]).parent) + "/"
                             for rows in (old, new) if name in rows)
            if any(p.startswith(prefixes) for p in changed):
                status = "added" if name not in old else "removed" if name not in new else "changed"
                print(f'Reconcile {name} -> {skill["owner"] or skill["name"]} ({status})')
    check(repo)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, help="Git checkout containing the reviewed source commit")
    parser.add_argument("--revision", help="Reviewed full upstream commit SHA")
    supplemental = parser.add_mutually_exclusive_group()
    supplemental.add_argument("--supplement", action="append", default=None,
                              help="Add a draft skill as <full-sha>:skills/<category>/<skill>; repeatable, replaces the prior list")
    supplemental.add_argument("--no-supplements", action="store_const", const=[], dest="supplement",
                              help="Explicitly retire supplemental pins; omitted flags preserve them")
    parser.add_argument("--check", action="store_true", help="Verify local bytes, modes, owners and registrations; no writes or network")
    args = parser.parse_args()
    if args.check:
        if args.source or args.revision or args.supplement is not None:
            parser.error("--check reads local state; omit source, revision and supplemental flags")
        check(args.repo_root.resolve())
    elif args.source and args.revision:
        install(args.repo_root.resolve(), args.source.resolve(), args.revision, args.supplement)
    else:
        parser.error("Provide --source and --revision, or --check")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError, subprocess.CalledProcessError) as error:
        print(f"Matt Pocock import failed: {error}", file=sys.stderr)
        sys.exit(1)
