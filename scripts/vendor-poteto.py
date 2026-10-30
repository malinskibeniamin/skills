#!/usr/bin/env python3
"""Vendor an entire pstack source tree and register collision-free skill adapters."""

import argparse
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path


REPOSITORY = "https://github.com/cursor/plugins"
SHORT_DESCRIPTIONS = {
    "architect": "Design caller usage, types, and module boundaries",
    "arena": "Compare competing implementations and combine the best",
    "automate-me": "Draft a personal mode from observed working patterns",
    "benchmark-checklist": "Vet performance measurements before acting on them",
    "blast-radius": "Prove non-local safety by executing the decisive check",
    "bro": "Restate the last message in plain human language",
    "correct": "Make repeated agent mistakes impossible by design",
    "create-formal-verification-skill": "Create a project-local formal verifier",
    "create-verification-skill": "Create a project-local real-app verifier",
    "figure-it-out": "Design a verifiable playbook for an unfamiliar task",
    "how": "Explain subsystem behavior from source evidence",
    "in-your-own-words": "Restate the user's goals and problem",
    "interrogate": "Challenge a diff with adversarial review",
    "ketchup": "Catch up on this chat and pending user decisions",
    "ketchup-video": "Catch up on this chat in a short subtitled video",
    "maintain-formal-verification-skill": "Refresh formal checks against changed code",
    "maintain-verification-skill": "Refresh a verifier from source and live behavior",
    "make-bot-ui": "Build a dashboard that wakes a bot through a webhook",
    "no-comments": "Replace redundant comments with structural guarantees",
    "poteto-help": "Find pstack skills, setup, and troubleshooting guidance",
    "poteto-mode": "Route rigorous work through Poteto playbooks",
    "principle-build-the-lever": "Build the repeatable tool that does or proves the work",
    "principle-experience-first": "Choose user experience over implementation convenience",
    "principle-explain-the-number": "Find the limiter and validate measured numbers",
    "principle-fix-root-causes": "Reproduce symptoms and repair their underlying cause",
    "principle-model-the-domain": "Encode domain rules in explicit data structures",
    "principle-prove-it-works": "Verify real behavior rather than relying on proxies",
    "recall": "Rebuild recent context from history and live state",
    "reflect": "Turn observed workflow lessons into skill improvements",
    "reproduce-and-fix-issues": "Reproduce issue reports and verify bounded fixes",
    "setup-benny": "Configure the Benny triage and reproduction pack",
    "setup-pstack": "Configure pstack model roles and reasoning budgets",
    "sharpen": "Deepen a task and return its rewritten prompt",
    "show-me-your-work": "Keep a reviewable decision and evidence trail",
    "statechart": "Check state transitions and draw counterexample paths",
    "swarm": "Coordinate explicitly requested parallel workers",
    "tdd": "Make a bug executable before implementing its fix",
    "teach": "Explain what changed, how it works, and why",
    "technical-writing": "Write layered, clear engineering documentation",
    "triage-issue-reports": "Classify and deduplicate thread-scoped issue reports",
    "typescript-best-practices": "Apply TypeScript type-system discipline",
    "unslop": "Remove AI writing patterns while preserving meaning",
    "why": "Research design rationale from cited evidence",
}


def inventory(source):
    files = {}
    for path in sorted(source.rglob("*")):
        if ".git" in path.relative_to(source).parts:
            continue
        if path.is_symlink():
            raise ValueError(f"Source contains a symlink: {path}")
        if path.is_file():
            files[path.relative_to(source).as_posix()] = {
                "sha256": hashlib.sha256(path.read_bytes()).hexdigest(),
                "mode": path.stat().st_mode & 0o777,
            }
    return files


def discover(source, files):
    skills = []
    names = set()
    for path in files:
        if Path(path).name != "SKILL.md":
            continue
        slug = Path(path).parent.name
        name = slug if slug.startswith("poteto-") else f"poteto-{slug}"
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name) or len(name) > 64:
            raise ValueError(f"Invalid skill directory: {path}")
        if name in names:
            raise ValueError(f"Duplicate skill directory: {slug}")
        names.add(name)
        text = (source / path).read_text()
        match = re.match(r"---\n(.*?)\n---", text, re.S)
        if not match or not re.search(r"^name:\s*\S", match[1], re.M):
            raise ValueError(f"Missing skill frontmatter: {path}")
        description = re.search(r"^description:\s*(.+)$", match[1], re.M)
        if not description:
            raise ValueError(f"Missing description: {path}")
        description = description[1].strip()
        if description == ">-":
            block = re.search(r"^description: >-\n((?:  \S[^\n]*(?:\n|$))+)", match[1], re.M)
            if not block:
                raise ValueError(f"Unsupported folded description: {path}")
            description = " ".join(line.strip() for line in block[1].splitlines())
        elif description.startswith('"'):
            description = json.loads(description)
        elif description.startswith("'") and description.endswith("'"):
            description = description[1:-1].replace("''", "'")
        if not description or description in ("|", ">"):
            raise ValueError(f"Unsupported description: {path}")
        short = SHORT_DESCRIPTIONS.get(slug, slug.removeprefix("principle-").replace("-", " ").capitalize())
        short = f"Poteto: {short}"
        if not 25 <= len(short) <= 64:
            raise ValueError(f"Short description needs an entry: {slug}")
        skills.append({
            "name": name,
            "source": path,
            "description": f"Poteto: {description}",
            "short_description": short,
            "explicit_only": bool(re.search(r"^disable-model-invocation:\s*true$", match[1], re.M)),
        })
    if not skills or "LICENSE" not in files or ".cursor-plugin/plugin.json" not in files:
        raise ValueError("Expected a complete pstack package with skills, LICENSE, and plugin metadata")
    return skills


def model_rule(repo):
    config = json.loads((repo / "config/model-routing.json").read_text())
    allowed = {"claude-opus-5-5", "gpt-6.1-sol"}
    preferred = config["selection"]["preferred_models"]
    if set(config["models"]) != allowed or set(preferred) != allowed or len(preferred) != 2:
        raise ValueError("Only Opus 5.5 and GPT-6.1 Sol are allowed in pstack routing")
    policy = config["quality_first"]

    def route(value):
        if not isinstance(value, dict) or value.get("model") not in allowed or value.get("effort") != "xhigh":
            raise ValueError("Unsupported pstack model route; use the host's Opus 5.5 / GPT-6.1 Sol xhigh routes")
        return f'{value["model"]}-{value["effort"]}'

    default = route(policy["default"])
    hard_policy = policy["hard"]
    if hard_policy["efforts"] != ["xhigh"]:
        raise ValueError("Unsupported pstack model route; hardest tasks must use xhigh")
    hard = route({"model": hard_policy["model"], "effort": "xhigh"})
    review = route(policy["review"]["primary"])
    fallback = route(policy["review"]["secondary"])
    panel = f"{review}, {fallback}"
    roles = [
        ("feature, refactoring", default),
        ("bug-fix", default),
        ("perf-issue", default),
        ("hillclimb", default),
        ("judgment and prose", default),
        ("hardest tasks", hard),
        ("how explorer", default),
        ("how explainer", default),
        ("why investigators", default),
        ("why synthesizer", default),
        ("reflect tooling", review),
        ("reflect judgment, divergent, synthesizer", default),
        ("arena runners", panel),
        ("arena cross-judge pool", panel),
        ("swarm workers", default),
        ("architect runners", panel),
        ("interrogate reviewers", panel),
    ]
    return "\n".join([
        "---", "alwaysApply: true", "---",
        "# Generated from config/model-routing.json; rerun vendor-poteto.py --model-rule.",
        "# budget: large (xhigh)",
        "# Every role overrides upstream defaults. No other models or aliases are allowed.",
        "# A model rule grants no permission to delegate or call models recursively.",
        *[f"{name}: {model}" for name, model in roles],
    ])


def adapter(skill):
    policy = "disable-model-invocation: true\n" if skill["explicit_only"] else ""
    return (
        f'---\nname: {skill["name"]}\n'
        f'description: {json.dumps(skill["short_description"])}\n'
        f"{policy}---\n\n"
        "Read [harness compatibility rules](../../shared/POTETO-COMPATIBILITY.md) first.\n"
        f'Read and follow the complete [upstream skill](../../vendor/pstack/{skill["source"]}), '
        "resolving its relative resources from that source directory.\n"
    )


def registration(skill):
    return f'./poteto-skills/{skill["name"]}/'


def check(repo, *, allow_legacy_descriptions=False):
    lock = json.loads((repo / "vendor/pstack.lock.json").read_text())
    source = repo / "vendor/pstack"
    files = inventory(source)
    if files != lock["files"]:
        raise ValueError("Vendored source bytes, permissions, or file inventory drifted")
    skills = discover(source, files)
    recorded = lock["skills"]
    if allow_legacy_descriptions:
        # Only refresh can repair the old folded-scalar metadata bug. Source
        # hashes, adapters, registrations and every other field still must match.
        descriptions = {skill["name"]: skill["description"] for skill in skills}
        recorded = [
            {**skill, "description": descriptions.get(skill["name"], skill["description"])}
            if skill["description"] == "Poteto: >-" else skill
            for skill in recorded
        ]
    if skills != recorded:
        raise ValueError("Skill inventory does not cover the complete source package")
    expected = {skill["name"] for skill in skills}
    actual = {path.name for path in (repo / "poteto-skills").iterdir()}
    if actual != expected:
        raise ValueError("Poteto adapters do not match the complete source inventory")
    for skill in skills:
        directory = repo / "poteto-skills" / skill["name"]
        if directory.is_symlink() or {path.relative_to(directory).as_posix() for path in directory.rglob("*")} != {"SKILL.md"}:
            raise ValueError(f'Unexpected local files in managed adapter: {skill["name"]}')
        if (directory / "SKILL.md").is_symlink() or (directory / "SKILL.md").read_text() != adapter(skill):
            raise ValueError(f'Adapter drift: {skill["name"]}')
    manifest = json.loads((repo / ".claude-plugin/plugin.json").read_text())
    registered = [entry for entry in manifest["skills"] if entry.startswith("./poteto-skills/")]
    if sorted(registered) != sorted(registration(skill) for skill in skills):
        raise ValueError("Claude plugin does not register every Poteto adapter exactly once")
    print(f'OK: {len(skills)} Poteto skills; {len(files)} upstream files match {lock["revision"]}')


def check_routing(repo):
    """Validate the published instruction graph, not model adherence to it."""
    native = repo / "shared/POTETO-NATIVE.md"
    sections = re.split(r"^## (.+)\n", native.read_text(), flags=re.M)
    expected = {
        (repo / "vendor/pstack" / skill["source"]).resolve()
        for skill in json.loads((repo / "vendor/pstack.lock.json").read_text())["skills"]
    }
    covered = set()
    owners = set()
    for title, body in zip(sections[1::2], sections[2::2]):
        anchor = title.lower().replace(" ", "-")
        links = re.findall(r"\[[^\]]+\]\(([^)]+)\)", body)
        paths = set()
        for link in links:
            if "://" in link or link.startswith("#"):
                continue
            path = (native.parent / link.split("#", 1)[0]).resolve()
            if not path.is_relative_to(repo) or not path.is_file():
                raise ValueError(f"Broken Poteto reference: {link}")
            paths.add(path)
        sources = paths & expected
        if not sources:
            raise ValueError(f"Poteto routing branch has no source skills: {title}")
        branch_owners = {p for p in paths if p.name == "SKILL.md" and not p.is_relative_to(repo / "vendor")}
        if not branch_owners:
            raise ValueError(f"Poteto routing branch has no host owner: {title}")
        for owner in branch_owners:
            targets = re.findall(r"\[[^\]]+\]\(([^)]+)\)", owner.read_text())
            if not any(
                (owner.parent / target.split("#", 1)[0]).resolve() == native
                and target.endswith(f"#{anchor}")
                for target in targets
            ):
                raise ValueError(f"{owner.relative_to(repo)} does not load Poteto branch #{anchor}")
        covered.update(sources)
        owners.update(branch_owners)
    if covered != expected:
        missing = sorted(str(path.relative_to(repo)) for path in expected - covered)
        raise ValueError(f"Unrouted Poteto skills: {missing}")
    print(f"OK: {len(covered)} Poteto source skills referenced through {len(owners)} native owners")


def install(repo, source, revision):
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        raise ValueError("Revision must be a full lowercase Git commit SHA")
    files = inventory(source)
    skills = discover(source, files)
    version = json.loads((source / ".cursor-plugin/plugin.json").read_text())["version"]
    manifest_path = repo / ".claude-plugin/plugin.json"
    manifest = json.loads(manifest_path.read_text())
    # Validate the inputs before replacing only this command's managed output.
    if source.is_relative_to(repo / "vendor") or source.is_relative_to(repo / "poteto-skills"):
        raise ValueError("Refresh from a separate upstream checkout, not the managed output")
    lock_path = repo / "vendor/pstack.lock.json"
    destination = repo / "vendor/pstack"
    if destination.exists() and not lock_path.exists():
        raise ValueError("Snapshot would overwrite an existing unmanaged directory")
    if lock_path.exists():
        check(repo, allow_legacy_descriptions=True)  # Preserve local patches.
    previous = json.loads(lock_path.read_text())["skills"] if lock_path.exists() else []
    for skill in previous:
        if not re.fullmatch(r"poteto-[a-z0-9]+(?:-[a-z0-9]+)*", skill["name"]):
            raise ValueError("Invalid managed adapter name in previous inventory")
    managed = {skill["name"] for skill in previous}
    for skill in skills:
        if (repo / "poteto-skills" / skill["name"]).exists() and skill["name"] not in managed:
            raise ValueError(f'Adapter would overwrite an existing directory: {skill["name"]}')
    destination.parent.mkdir(parents=True, exist_ok=True)
    if destination.exists():
        shutil.rmtree(destination)
    destination.mkdir()
    for path in files:
        target = destination / path
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source / path, target)
    for skill in previous:
        shutil.rmtree(repo / "poteto-skills" / skill["name"])
    for skill in skills:
        directory = repo / "poteto-skills" / skill["name"]
        directory.mkdir(parents=True)
        (directory / "SKILL.md").write_text(adapter(skill))
    lock = {"repository": REPOSITORY, "subdirectory": "pstack", "revision": revision,
            "version": version, "skills": skills, "files": files}
    lock_path.write_text(json.dumps(lock, indent=2, ensure_ascii=False) + "\n")
    manifest["skills"] = [entry for entry in manifest["skills"] if not entry.startswith("./poteto-skills/")]
    manifest["skills"].extend(registration(skill) for skill in skills)
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
    check(repo)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--repo-root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--source", type=Path, help="pstack directory from the pinned upstream checkout")
    parser.add_argument("--revision", help="full upstream commit SHA")
    actions = parser.add_mutually_exclusive_group()
    actions.add_argument("--check", action="store_true", help="check the local snapshot and complete registrations")
    actions.add_argument("--check-routing", action="store_true", help="check the snapshot and native instruction links; execute no skills")
    actions.add_argument("--model-rule", action="store_true", help="print a pstack rule using only the host's Opus/Sol routes; write nothing")
    args = parser.parse_args()
    if args.model_rule:
        if args.source or args.revision:
            parser.error("--model-rule reads host routing; omit --source and --revision")
        print(model_rule(args.repo_root.resolve()))
    elif args.check or args.check_routing:
        if args.source or args.revision:
            parser.error("checks read local state; omit --source and --revision")
        check(args.repo_root.resolve())
        if args.check_routing:
            check_routing(args.repo_root.resolve())
    else:
        if not args.source or not args.revision:
            parser.error("refresh requires --source and --revision")
        install(args.repo_root.resolve(), args.source.resolve(), args.revision)


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError) as error:
        print(f"error: {error}", file=sys.stderr)
        sys.exit(1)
