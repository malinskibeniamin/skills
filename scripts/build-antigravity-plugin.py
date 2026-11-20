#!/usr/bin/env python3
"""Build a standalone Antigravity plugin from the canonical skill and hook sources."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ADAPTER = ROOT / "plugins/frontend-skills-antigravity"
SKILL_FIELDS = {"name", "description", "disable-model-invocation", "license", "compatibility"}
# Keep reference and script paths intact without bundling other host packages,
# archived documentation, or test/eval trees.
EXCLUDED = {".github", ".git", "codex-skills", "docs-site", "agent-evals", "evals", "plugins"}


def write(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def dump(path, value):
    write(path, json.dumps(value, indent=2, ensure_ascii=False) + "\n")


def frontmatter(path):
    text = path.read_text(encoding="utf-8")
    header, body = text.removeprefix("---\n").split("\n---\n", 1)
    fields = {}
    for block in re.split(r"\n(?=[\w-]+:)", header):
        key, value = block.split(":", 1)
        fields[key] = value
    return fields, body


def markdown(fields, body):
    return "---\n" + "\n".join(f"{key}:{value}" for key, value in fields.items()) + "\n---\n" + body


def stage(destination):
    catalog = json.loads((ROOT / ".claude-plugin/plugin.json").read_text())
    source = destination / "source"
    paths = subprocess.check_output(["git", "ls-files", "-z"], cwd=ROOT).decode().split("\0")
    tracked = {ROOT / name for name in paths if name}
    for origin in sorted(tracked):
        relative = origin.relative_to(ROOT)
        if relative.parts[0] in EXCLUDED:
            continue
        # Copy file bytes (including executable mode), not symlinks pointing out of
        # an installed bundle. No untracked files or external symlink targets.
        if origin.resolve() in tracked and origin.is_file():
            target = source / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(origin, target)

    for entry in catalog["skills"]:
        canonical = Path(entry) / "SKILL.md"
        fields, _ = frontmatter(source / canonical)
        name = fields["name"].strip().strip("\"'")
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or len(name) > 64:
            raise ValueError(f"Invalid Antigravity skill name: {name!r}")
        entrypoint = destination / "skills" / name / "SKILL.md"
        if entrypoint.exists():
            raise ValueError(f"Duplicate Antigravity skill: {name}")
        link = os.path.relpath(source / canonical, entrypoint.parent)
        write(entrypoint, markdown(
            {k: v for k, v in fields.items() if k in SKILL_FIELDS},
            f"\nRead the complete [skill instructions]({link}) before acting. "
            "Resolve its resource paths relative to the canonical file. Apply the Antigravity host rules.\n",
        ))

    for entry in catalog["agents"]:
        canonical = Path(entry)
        fields, _ = frontmatter(source / canonical)
        agent_path = destination / canonical
        tools = ["view_file", "grep_search", "find_by_name", "list_dir"]
        # The verifier already has unscoped Bash in the canonical definition.
        # Never widen a command-scoped reviewer to unrestricted run_command.
        if "Bash" in fields["allowed-tools"].strip().split(", "):
            tools.append("run_command")
        link = os.path.relpath(source / canonical, agent_path.parent)
        write(agent_path, markdown({
            "name": fields["name"],
            "description": fields["description"],
            "model": " inherit",
            "mainAgent": " false",
            "subagent": " true",
            "tools": " " + json.dumps(tools),
        }, f"\nRead and follow the complete [agent instructions]({link}). "
           "Use the allowed Antigravity tools only. If shell evidence is outside your tool scope, "
           "use the coordinator's supplied evidence or report the gap. Do not delegate.\n"))

    dump(destination / "plugin.json", {
        "$schema": "https://antigravity.google/schemas/v1/plugin.json",
        "name": "frontend-skills",
        "displayName": "Frontend Skills",
        "version": catalog["version"],
        "description": "Frontend Skills workflows and quality hooks for Antigravity.",
    })
    for name in ("hooks.json", "rules/antigravity.md", "scripts/hook.py"):
        target = destination / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ADAPTER / name, target)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="A new plugin directory")
    output = parser.parse_args().output.resolve()
    if output.exists():
        parser.error(f"Output already exists: {output}")
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".frontend-skills-", dir=output.parent) as tmp:
        bundle = Path(tmp) / "bundle"
        stage(bundle)
        bundle.rename(output)


if __name__ == "__main__":
    main()
