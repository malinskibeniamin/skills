#!/usr/bin/env python3
"""Import the complete agent-browser skill suite from reviewed Git blobs; check offline."""

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path, PurePosixPath


REPOSITORY = "https://github.com/vercel-labs/agent-browser"
METADATA = {
    "core": (
        "agent-browser",
        "Automate isolated browser tasks with version-matched guidance",
        "Use for browser automation with agent-browser when host browser policy permits. Covers isolated sessions, snapshots, refs, waiting and cleanup.",
    ),
    "agentcore": (
        "agent-browser-agentcore",
        "Use explicitly requested AWS AgentCore browser sessions",
        "Use when explicitly asked for AWS Bedrock AgentCore cloud browser automation. No implicit cloud setup or credential changes.",
    ),
    "derive-client": (
        "agent-browser-derive-client",
        "Derive scoped API clients from authorized browser traffic",
        "Use when asked to derive a standalone API client from authorized browser traffic. Treat HAR files and session credentials as secrets.",
    ),
    "dogfood": (
        "agent-browser-dogfood",
        "Explore web apps through the existing dogfood owner",
        "Use for browser-specific exploratory QA with agent-browser. The existing dogfood skill retains verification and reporting ownership.",
    ),
    "electron": (
        "agent-browser-electron",
        "Automate explicitly authorized isolated Electron apps",
        "Use for explicitly authorized Electron app automation through agent-browser. Never attach to or restart a human-owned app by default.",
    ),
    "modern-web-guidance": (
        "modern-web-guidance",
        "Apply Chrome guidance and verify real browser behavior",
        "Use for Chrome Modern Web Guidance or Baseline-aware UI: layout shift, reduced motion, dark mode and dialogs. Retrieve relevant guides, apply within scope and verify in a real browser.",
    ),
    "slack": (
        "agent-browser-slack",
        "Automate scoped Slack tasks in an authorized browser",
        "Use for explicitly requested Slack browser tasks when no suitable connected tool is available and host browser policy permits. Sending needs explicit scope.",
    ),
    "vercel": (
        "agent-browser-vercel",
        "Inspect protected Vercel previews with scoped credentials",
        "Use for authorized protected Vercel preview access or browser-local flag variants. Preserve Deployment Protection and project settings.",
    ),
    "vercel-sandbox": (
        "agent-browser-vercel-sandbox",
        "Use explicitly requested Vercel Sandbox browser runtimes",
        "Use when explicitly asked to run agent-browser in Vercel Sandbox. Importing this skill grants no cloud provisioning, dependency installation or scheduling authority.",
    ),
    "webmcp-gen": (
        "agent-browser-webmcp-gen",
        "Validate browser WebMCP tools through the existing owner",
        "Use when building or validating page WebMCP tools with agent-browser. The existing webmcp skill retains authoring, trust-boundary and verification ownership.",
    ),
}
LICENSE_SHA256 = '014bb31e83d5c2e76aea1cc6e82217346ab41362f32cb355ad0f5c10aa0aeaff'


def git(source, *args):
    return subprocess.check_output(["git", "-C", str(source), *args],
                                   env={**os.environ, "GIT_NO_LAZY_FETCH": "1"})


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
        if PurePosixPath(path).name != "SKILL.md" or path.startswith("skills/"):
            continue
        name = PurePosixPath(path).parent.name
        if name not in METADATA or path != f"skill-data/{name}/SKILL.md":
            raise ValueError(f"Unadapted upstream skill: {path}")
        if not re.match(rf"---\nname: {re.escape(name)}\n", data.decode("utf-8")):
            raise ValueError(f"Invalid upstream frontmatter: {path}")
        names.add(name)
    required = {"LICENSE", "skills/agent-browser/SKILL.md", "skill-data/core/references/commands.md",
                "skill-data/core/references/trust-boundaries.md"}
    if names != set(METADATA) or not required <= payload.keys():
        raise ValueError("All ten reviewed skills, discovery stub, core references and LICENSE are required")
    if not payload["skills/agent-browser/SKILL.md"][0].startswith(b"---\nname: agent-browser\n"):
        raise ValueError("Upstream discovery identity changed")
    if hashlib.sha256(payload["LICENSE"][0]).hexdigest() != LICENSE_SHA256:
        raise ValueError("Upstream license changed; review before refresh")
    return [{"name": METADATA[name][0], "upstream_name": name,
             "source": f"skill-data/{name}/SKILL.md",
             "registration": f"./{METADATA[name][0]}/" if name in ("core", "modern-web-guidance")
                             else f"./agent-browser-skills/{METADATA[name][0]}/",
             "short_description": METADATA[name][1], "description": METADATA[name][2]}
            for name in sorted(names)]


def adapter(skill):
    depth = "../" if skill["upstream_name"] in ("core", "modern-web-guidance") else "../../"
    return (f'---\nname: {skill["name"]}\ndescription: {json.dumps(skill["description"])}\n---\n\n'
            "<!-- Generated by scripts/vendor-agent-browser.py; do not edit. -->\n\n"
            f"Read [host compatibility]({depth}shared/AGENT-BROWSER.md) first, including the "
            f'`{skill["upstream_name"]}` branch. It overrides conflicting source instructions.\n\n'
            f'Read the complete [upstream skill]({depth}vendor/agent-browser/{skill["source"]}). '
            "Resolve its references there. Load sibling skills through the host owners mapped "
            "in compatibility; reuse already loaded guidance.\n")


def adapter_inventory(repo, skills):
    expected = {s["registration"].removeprefix("./") + "SKILL.md":
                {"sha256": hashlib.sha256(adapter(s).encode()).hexdigest(), "mode": 0o644}
                for s in skills}
    actual = {}
    for directory in ("agent-browser", "modern-web-guidance", "agent-browser-skills"):
        actual.update({f"{directory}/{p}": r for p, r in inventory(repo / directory).items()})
    if actual != expected:
        raise ValueError("Adapter bytes, modes or inventory drifted")


def managed_paths(repo):
    for name in ("vendor", "vendor/agent-browser", "vendor/agent-browser.lock.json", "agent-browser-skills",
                 "agent-browser", "modern-web-guidance",
                 ".claude-plugin", ".claude-plugin/plugin.json"):
        if (repo / name).is_symlink():
            raise ValueError(f"Managed path must not be a symlink: {name}")


def check(repo, source=None, refreshing=False):
    managed_paths(repo)
    lock = json.loads((repo / "vendor/agent-browser.lock.json").read_text())
    if lock["repository"] != REPOSITORY or not re.fullmatch(r"[0-9a-f]{40}", lock["revision"]):
        raise ValueError("Invalid upstream provenance")
    snapshot = repo / "vendor/agent-browser"
    files = inventory(snapshot)
    if files != lock["files"]:
        raise ValueError("Snapshot bytes, executable modes or inventory drifted")
    skills = discover({p: ((snapshot / p).read_bytes(), r["mode"]) for p, r in files.items()})
    if not refreshing and skills != lock["skills"]:
        raise ValueError("Skill metadata drifted")
    # A refresh may revise discovery descriptions; first preserve the old generated owners.
    if refreshing:
        skills = lock["skills"]
    adapter_inventory(repo, skills)
    entries = json.loads((repo / ".claude-plugin/plugin.json").read_text())["skills"]
    registered = [p for p in entries if p.startswith("./agent-browser-skills/")
                  or p in ("./agent-browser/", "./modern-web-guidance/")]
    if sorted(registered) != sorted(s["registration"] for s in skills):
        raise ValueError("Each agent-browser skill must have exactly one host owner")
    if source is not None:
        committed = read_payload(source, lock["revision"])
        expected_source = {p: {"sha256": hashlib.sha256(data).hexdigest(), "mode": mode}
                           for p, (data, mode) in committed.items()}
        if files != expected_source:
            raise ValueError("Snapshot does not match committed source at locked revision")
        print(f'OK: committed source matches pin {lock["revision"]}')
    print(f'OK: 10 skills and adapters; {len(files)} files verified (pin {lock["revision"]})')
    return lock


def read_payload(source, revision):
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
        if not (path.startswith("skill-data/") or path.startswith("skills/agent-browser/") or path in ("LICENSE", "NOTICE")):
            continue
        mode, kind, oid = header.decode().split()
        if PurePosixPath(path).is_absolute() or ".." in PurePosixPath(path).parts or kind != "blob" or mode not in ("100644", "100755"):
            raise ValueError(f"Unsafe upstream entry: {path}")
        payload[path] = (git(source, "cat-file", "blob", oid), int(mode[-3:], 8))
    return payload


def install(repo, source, revision):
    managed_paths(repo)
    payload = read_payload(source, revision)
    skills = discover(payload)
    destination = repo / "vendor/agent-browser"
    adapters = repo / "agent-browser-skills"
    lock_path = repo / "vendor/agent-browser.lock.json"
    previous = check(repo, refreshing=True) if lock_path.exists() else None
    if not previous and any((repo / p).exists() for p in ("vendor/agent-browser", "agent-browser-skills", "agent-browser", "modern-web-guidance")):
        raise ValueError("Import would overwrite unmanaged files")
    manifest_path = repo / ".claude-plugin/plugin.json"
    manifest = json.loads(manifest_path.read_text())
    registrations = {s["registration"] for s in skills}
    retained = [p for p in manifest["skills"] if p not in registrations and not p.startswith("./agent-browser-skills/")]
    if {Path(p).name for p in retained} & {s["name"] for s in skills}:
        raise ValueError("Import would collide with an existing skill")
    repo.joinpath("vendor").mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(dir=repo / "vendor", prefix=".agent-browser-import-") as temp:
        stage = Path(temp) / "source"
        stage.mkdir()
        for path, (data, mode) in payload.items():
            target = stage / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)
            target.chmod(mode)
        lock = {"repository": REPOSITORY, "revision": revision, "skills": skills, "files": inventory(stage)}
        if destination.exists():
            shutil.rmtree(destination)
        shutil.move(str(stage), destination)
    if adapters.exists():
        shutil.rmtree(adapters)
    for skill in skills:
        directory = repo / skill["registration"]
        directory.mkdir(parents=True, exist_ok=True)
        (directory / "SKILL.md").write_text(adapter(skill))
        (directory / "SKILL.md").chmod(0o644)
    lock_path.write_text(json.dumps(lock, indent=2) + "\n")
    if not previous:
        manifest["skills"] = retained + [s["registration"] for s in skills]
        manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    check(repo)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, help="separate upstream Git checkout; with --check, verify the locked commit")
    parser.add_argument("--revision", help="reviewed immutable commit SHA")
    parser.add_argument("--check", action="store_true", help="verify local snapshot without writing or networking")
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
