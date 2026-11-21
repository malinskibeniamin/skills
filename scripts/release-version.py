#!/usr/bin/env python3
"""Prepare or verify a version bump relative to the exact target commit."""
import argparse
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = "skill-manifest.json"
PLUGINS = (".claude-plugin/plugin.json", ".codex-plugin/plugin.json")
MARKETS = (".claude-plugin/marketplace.json", ".agents/plugins/marketplace.json")
SEMVER = r"(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)"


def version(value):
    match = re.fullmatch(SEMVER, value)
    if not match:
        raise ValueError(f"Expected stable SemVer, got {value!r}")
    return tuple(map(int, match.groups()))


def metadata():
    for name in (MANIFEST, *PLUGINS, *MARKETS):
        path = ROOT / name
        document = json.loads(path.read_text())
        entry = (
            next(p for p in document["plugins"] if p["name"] == "frontend-skills")
            if name in MARKETS else document
        )
        yield path, document, entry


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("check", "prepare"))
    parser.add_argument("--base", default="origin/main")
    parser.add_argument("--version")
    parser.add_argument("--note", help="Concise release note; required for prepare")
    args = parser.parse_args()
    base = json.loads(subprocess.check_output(
        ["git", "show", f"{args.base}:{MANIFEST}"], cwd=ROOT, text=True
    ))["version"]
    changelog = ROOT / "CHANGELOG.md"
    readme = ROOT / "README.md"
    entries = list(metadata())
    if args.mode == "prepare":
        if not args.note or not args.note.strip() or any(c in args.note for c in "\r\n"):
            parser.error("prepare needs a one-line --note")
        major, minor, patch = version(base)
        target = args.version or f"{major}.{minor}.{patch + 1}"
        if version(target) <= version(base):
            parser.error(f"release version must exceed {base}")
        text = changelog.read_text()
        if f"\n## {target}\n" in text:
            parser.error(f"CHANGELOG.md already contains {target}")
        command = readme.read_text()
        command, matches = re.subn(
            r"(codex plugin marketplace add malinskibeniamin/skills --ref v)[0-9.]+",
            lambda m: m[1] + target, command,
        )
        if matches != 1:
            parser.error("missing or duplicate Codex release install example")
        if shutil.which("bunx") is None or not (ROOT / "node_modules/.bin/biome").is_file():
            parser.error("run bun install --frozen-lockfile before preparing release metadata")
        date = datetime.now(timezone.utc).date().isoformat()
        # Existing unreleased notes belong to this release, not the next one.
        text = text.replace("\n## Unreleased\n", f"\n## Unreleased\n\n## {target}\n\n- {args.note}\n", 1)
        if f"\n## {target}\n" not in text:
            parser.error("missing Unreleased changelog section")
        for path, document, entry in entries:
            entry["version"] = target
            if path.name != MANIFEST:
                entry["x-updatedAt"] = date
                entry["x-changelog"] = {**entry["x-changelog"], target: args.note}
            path.write_text(json.dumps(document, indent=2, ensure_ascii=False) + "\n")
        changelog.write_text(text)
        readme.write_text(command)
        subprocess.run(
            ["bunx", "--no-install", "biome", "format", "--write",
             *(str(path) for path, _, _ in entries)], cwd=ROOT, check=True,
            stdout=subprocess.DEVNULL,
        )
    else:
        target = entries[0][2]["version"]
        if version(target) <= version(base):
            parser.error(f"{target} must exceed base {base}; run scripts/release-version.py prepare")
        for path, _, entry in entries:
            if entry["version"] != target or (
                path.name != MANIFEST and not entry.get("x-changelog", {}).get(target)
            ):
                parser.error(f"version or changelog mismatch: {path.relative_to(ROOT)}")
        if changelog.read_text().splitlines().count(f"## {target}") != 1:
            parser.error("missing or duplicate changelog section")
        if f"codex plugin marketplace add malinskibeniamin/skills --ref v{target}\n" not in readme.read_text():
            parser.error("Codex install example does not match the release version")
    print(target)


if __name__ == "__main__":
    main()
