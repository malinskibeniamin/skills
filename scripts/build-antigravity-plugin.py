#!/usr/bin/env python3
"""Build and validate a standalone Antigravity plugin from canonical skill and hook sources."""
import argparse
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]
ADAPTER = ROOT / "plugins/frontend-skills-antigravity"
SKILL_FIELDS = {"name", "description", "disable-model-invocation", "license", "compatibility"}
# Keep reference and script paths intact without bundling other host packages,
# archived documentation, or test/eval trees.
EXCLUDED = {".github", ".git", "codex-skills", "docs-site", "agent-evals", "evals", "plugins"}

# In the default `core` Antigravity profile, non-native vendored adapter groups
# and Claude/Codex-only skills remain explicitly invocable by name but are marked
# disable-model-invocation: true so Gemini's auto-discovery menu stays focused
# and within a tight context budget.
VENDORED_MANUAL_GROUPS = {
    "agent-browser-skills",
    "cursor-skills",
    "jakubkrehel-skills",
    "matt-skills",
    "poteto-skills",
    "t3code-skills",
    "tstack-skills",
}
OTHER_HOST_MANUAL_SKILLS = {
    "codex",
    "codex-compat",
    "redpanda-ai-gateway",
    "setup-animatic",
    "setup-atlassian-workflow",
    "setup-routines",
}
CORE_AUTO_DESC_CHAR_CAP = 14000
MARKDOWN_LINK_RE = re.compile(r"(!?\[[^\]]*\]\()([^)\s]+)((?:\s+\"[^\"]*\")?\))")
FENCE_RE = re.compile(r"^\s*(```+|~~~+)")


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


def rewrite_relative_links(body, canonical_dir, target_dir, source_root):
    """Rewrite relative Markdown links from canonical_dir so they resolve from target_dir."""
    out_lines = []
    fence = None
    for line in body.splitlines(keepends=True):
        m = FENCE_RE.match(line)
        if m:
            marker = m.group(1)
            if fence is None:
                fence = marker[0]
            elif marker[0] == fence:
                fence = None
            out_lines.append(line)
            continue
        if fence is not None:
            out_lines.append(line)
            continue

        def _replace(match):
            prefix, raw_target, suffix = match.group(1), match.group(2), match.group(3)
            if (
                raw_target.startswith(("http://", "https://", "mailto:", "file://", "#", "/"))
                or raw_target.startswith("<")
                or "://" in raw_target
            ):
                return match.group(0)
            rel_part, anchor = (raw_target.split("#", 1) + [""])[:2]
            if not rel_part:
                return match.group(0)
            resolved = (canonical_dir / rel_part).resolve()
            # Only rewrite links that point to an actual file/dir inside the bundled source tree.
            if not resolved.is_relative_to(source_root.resolve()) or not resolved.exists():
                return match.group(0)
            rewritten = os.path.relpath(resolved, target_dir)
            if anchor:
                rewritten = f"{rewritten}#{anchor}"
            return f"{prefix}{rewritten}{suffix}"

        out_lines.append(MARKDOWN_LINK_RE.sub(_replace, line))
    return "".join(out_lines)


def should_disable_auto_invocation(entry, name, profile):
    if profile == "full":
        return False
    parts = Path(entry).parts
    if len(parts) > 1 and parts[0] in VENDORED_MANUAL_GROUPS:
        return True
    return name in OTHER_HOST_MANUAL_SKILLS


def stage(destination, profile="core"):
    catalog = json.loads((ROOT / ".claude-plugin/plugin.json").read_text(encoding="utf-8"))
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
        canonical_file = source / canonical
        fields, body = frontmatter(canonical_file)
        name = fields["name"].strip().strip("\"'")
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or len(name) > 64:
            raise ValueError(f"Invalid Antigravity skill name: {name!r}")
        entrypoint = destination / "skills" / name / "SKILL.md"
        if entrypoint.exists():
            raise ValueError(f"Duplicate Antigravity skill: {name}")

        filtered = {k: v for k, v in fields.items() if k in SKILL_FIELDS}
        if should_disable_auto_invocation(entry, name, profile):
            filtered["disable-model-invocation"] = " true"

        inlined_body = rewrite_relative_links(
            body, canonical_file.parent, entrypoint.parent, source
        )
        write(entrypoint, markdown(filtered, inlined_body))

    for entry in catalog["agents"]:
        canonical = Path(entry)
        canonical_file = source / canonical
        fields, body = frontmatter(canonical_file)
        agent_path = destination / canonical
        # Support both Antigravity ACP (`read_file`) and IDE (`view_file`, etc.) read-only tools.
        tools = ["read_file", "view_file", "grep_search", "find_by_name", "list_dir"]
        # The verifier already has unscoped Bash in the canonical definition.
        # Never widen a command-scoped reviewer to unrestricted run_command.
        if "Bash" in fields["allowed-tools"].strip().split(", "):
            tools.append("run_command")
        inlined_body = rewrite_relative_links(
            body, canonical_file.parent, agent_path.parent, source
        ).rstrip()
        footer = (
            "\n\n## Antigravity host constraints\n\n"
            "Use the allowed Antigravity tools only. If shell evidence is outside your tool scope, "
            "use the coordinator's supplied evidence or report the gap. Do not delegate.\n"
        )
        write(agent_path, markdown({
            "name": fields["name"],
            "description": fields["description"],
            "model": " inherit",
            "mainAgent": " false",
            "subagent": " true",
            "tools": " " + json.dumps(tools),
        }, inlined_body + footer))

    dump(destination / "plugin.json", {
        "$schema": "https://antigravity.google/schemas/v1/plugin.json",
        "name": "frontend-skills",
        "displayName": "Frontend Skills",
        "version": catalog["version"],
        "description": "Frontend Skills workflows and quality hooks for Antigravity.",
        "logo": "assets/logo.svg",
    })
    for name in ("assets/logo.svg", "hooks.json", "rules/AGENTS.md", "scripts/hook.py"):
        target = destination / name
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ADAPTER / name, target)


def verify_bundle(bundle, profile="core", run_agy=True):
    errors = []
    manifest_path = bundle / "plugin.json"
    if not manifest_path.is_file():
        errors.append("Missing plugin.json")
    else:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        logo = manifest.get("logo")
        if not logo or not (bundle / logo).is_file():
            errors.append(f"Missing plugin logo: {logo}")

    hooks_path = bundle / "hooks.json"
    if not hooks_path.is_file():
        errors.append("Missing hooks.json")
    else:
        hooks = json.loads(hooks_path.read_text(encoding="utf-8")).get("frontend-skills", {})
        for required_event in ("SessionStart", "PreInvocation", "PreToolUse", "PostToolUse", "PostInvocation", "Stop"):
            if required_event not in hooks:
                errors.append(f"Missing hook event: {required_event}")

    if any(path.is_symlink() for path in bundle.rglob("*")):
        errors.append("Bundle contains symlinks")

    auto_count = 0
    auto_desc_chars = 0
    broken_links = []
    for skill_md in sorted(bundle.glob("skills/*/SKILL.md")):
        fields, body = frontmatter(skill_md)
        if "Read the complete [skill instructions](" in body:
            errors.append(f"Double-hop proxy stub detected in {skill_md.relative_to(bundle)}")
        disabled = fields.get("disable-model-invocation", "").strip().lower() == "true"
        if not disabled:
            auto_count += 1
            auto_desc_chars += len(fields.get("description", "").strip())
        # Verify every rewritten source link resolves inside the bundle.
        for match in MARKDOWN_LINK_RE.finditer(body):
            target = match.group(2)
            if target.startswith("../../source/"):
                rel_part = target.split("#", 1)[0]
                if not (skill_md.parent / rel_part).resolve().exists():
                    broken_links.append(f"{skill_md.relative_to(bundle)} -> {target}")

    if broken_links:
        errors.append(f"Broken relative links ({len(broken_links)}): {broken_links[:5]}")
    if profile == "core" and auto_desc_chars > CORE_AUTO_DESC_CHAR_CAP:
        errors.append(
            f"Core profile auto-invocable descriptions over budget: "
            f"{auto_desc_chars} chars > {CORE_AUTO_DESC_CHAR_CAP} ({auto_count} skills)"
        )

    if run_agy and shutil.which("agy"):
        proc = subprocess.run(
            ["agy", "plugin", "validate", "--strict", str(bundle)],
            text=True, capture_output=True,
        )
        if proc.returncode != 0:
            errors.append(f"agy plugin validate --strict failed: {proc.stdout}\n{proc.stderr}")

    return {
        "ok": not errors,
        "errors": errors,
        "auto_invocable_skills": auto_count,
        "auto_desc_chars": auto_desc_chars,
        "auto_desc_tokens_est": auto_desc_chars // 4,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path, help="Plugin output directory")
    parser.add_argument(
        "--profile", choices=("core", "full"), default="core",
        help="Skill auto-discovery profile: 'core' (default, focused Gemini menu) or 'full' (canonical parity).",
    )
    parser.add_argument(
        "--update", action="store_true",
        help="Replace an existing plugin directory after staging; add --verify to validate before replacement.",
    )
    parser.add_argument(
        "--verify", action="store_true",
        help="Validate manifest, hooks, links, token budget, and agy CLI schema (when installed).",
    )
    args = parser.parse_args()
    output = args.output.resolve()
    if output.exists() and not args.update:
        parser.error(f"Output already exists (pass --update to replace it): {output}")
    output.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix=".frontend-skills-", dir=output.parent) as tmp:
        bundle = Path(tmp) / "bundle"
        stage(bundle, profile=args.profile)
        if args.verify:
            report = verify_bundle(bundle, profile=args.profile)
            if not report["ok"]:
                print(json.dumps(report, indent=2), file=sys.stderr)
                sys.exit(1)
        if output.exists():
            backup = Path(tmp) / "previous"
            output.rename(backup)
            try:
                bundle.rename(output)
            except OSError:
                backup.rename(output)
                raise
        else:
            bundle.rename(output)


if __name__ == "__main__":
    main()
