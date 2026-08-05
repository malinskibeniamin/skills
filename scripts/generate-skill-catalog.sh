#!/bin/bash
set -euo pipefail

# Generate the ask-ben routing table and Codex plugin skill index from
# .claude-plugin/plugin.json + each skill's SKILL.md frontmatter. Kills the
# hand-maintained copies: neither surface can drift from registered skills.
#
# Usage: scripts/generate-skill-catalog.sh [--check]
#   (no args)  rewrite the table block in ask-ben/SKILL.md
#   --check    exit 1 if the table differs from what would be generated

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-apply}"

python3 - "$REPO_ROOT" "$MODE" <<'PY'
import json, pathlib, re, shutil, sys

repo = pathlib.Path(sys.argv[1])
mode = sys.argv[2]

ACRONYMS = {"ADP", "AI", "AIP", "API", "CI", "CLI", "E2E", "GPT", "MCP", "PDF", "PM", "PR", "TDD", "UI", "URL", "UX"}
BRANDS = {"codex": "Codex", "github": "GitHub", "openai": "OpenAI", "prs": "PRs", "redpanda": "Redpanda", "snyk": "Snyk", "tanstack": "TanStack"}
SMALL_WORDS = {"and", "or", "to", "with"}
SHORT_DESCRIPTIONS = {
    "accessibility": "Build accessible React interactions and components",
    "agent-watchdog": "Audit and repair work from another coding agent",
    "aip": "Design Google AIP-style protobuf resource APIs",
    "ask-ben": "Route work through Ben's frontend skill harness",
    "codebase-design": "Design deeper modules with clear interfaces",
    "codex-compat": "Generate Codex hook and instruction parity",
    "codex": "Delegate bounded work through the Codex CLI",
    "commit-push-pr": "Commit, push, and publish a reviewable pull request",
    "connect-query": "Build typed ConnectRPC data flows with Connect Query",
    "demo": "Create a customer-facing feature recording",
    "deslop": "Audit already-bloated code and remove unjustified surface",
    "development-lifecycle": "Run the full frontend development lifecycle",
    "diagnosing-bugs": "Diagnose hard bugs with a tight feedback loop",
    "dogfood": "Use and stress-test every runnable change",
    "domain-modeling": "Build a shared domain model and vocabulary",
    "e2e-testing": "Build resilient Playwright end-to-end tests",
    "efficient-frontier": "Delegate bounded work while preserving central judgment",
    "excalidraw-diagram": "Draw editable Excalidraw diagrams from prompts",
    "extend-harness": "Extend and debug the frontend skill harness",
    "frontend-invariants": "Timeless frontend principles that outlive stacks",
    "frontend-starter-kit": "Bootstrap the standard frontend toolchain and gates",
    "go": "Verify, review, and ship completed work",
    "golang": "Write Go with evidence-backed engineering conventions",
    "golang-review": "Review Go diffs against evidence-backed conventions",
    "grilling": "Stress-test plans, decisions, and ideas",
    "handoff": "Prepare a compact session handoff for another agent",
    "hook-audit": "Audit hook effectiveness, latency, and drift",
    "improve": "Audit codebases or write requested implementation plans",
    "make-pr-easy-to-review": "Make pull request history and guidance easier to review",
    "plan-arbiter": "Compare competing plans and choose a grounded direction",
    "plow-ahead": "Continue autonomously through routine ambiguity",
    "postgresql": "Engineer and operate PostgreSQL from workload evidence",
    "prime": "Build a concise repository startup brief",
    "prototype": "Build a throwaway artifact to answer a design question",
    "quantify-impact": "Prove meaningful product and codebase improvements",
    "read-the-damn-docs": "Research current behavior from primary documentation",
    "redpanda-ai-gateway": "Run AI CLIs through the Redpanda AI Gateway",
    "registry-workflow": "Maintain component registry taxonomy and sync discipline",
    "release": "Publish an immutable frontend-skills release safely",
    "research": "Research primary sources and save cited findings",
    "resilience-review": "Review credible high-impact failures with Murphy law",
    "resolve-pr-feedback": "Resolve pull request feedback and review threads",
    "resolving-merge-conflicts": "Resolve an in-progress Git merge or rebase conflict",
    "revamp": "Run a large rewrite with baseline-driven translation",
    "review": "Review a diff with evidence-triggered specialist hats",
    "setup-atlassian-workflow": "Configure opt-in Jira and Atlassian workflows",
    "setup-routines": "Configure automated Claude Code maintenance routines",
    "snyk-ux-security": "Audit dependency security with Snyk and release gates",
    "stack-registry": "Current and banned stack governance for harness rules",
    "stacked-prs": "Create and manage dependent GitHub pull request stacks",
    "stay-within-limits": "Budget long-running agent work around usage limits",
    "steelman": "Build the strongest evidence-backed counterargument",
    "swarm": "Execute independent work across parallel worktree lanes",
    "tanstack-router": "Apply typed TanStack Router data and search patterns",
    "tanstack-table": "Build reactive TanStack Table V9 interfaces safely",
    "tdd": "Develop meaningful behavior through red-green-refactor",
    "teach": "Teach a workspace concept through durable practice",
    "thermo-nuclear-code-quality-review": "Run a release-blocking deep code quality review",
    "to-questionnaire": "Create focused discovery questionnaires for stakeholders",
    "to-spec": "Turn the conversation into a tracker-ready spec",
    "to-tickets": "Split a plan into tracer-bullet tickets with blockers",
    "triage": "Prepare issues for reliable agent or human execution",
    "upgrade-dependency": "Upgrade a dependency and adapt every affected call site",
    "ux-copy": "Write clear, inclusive product copy in Redpanda style",
    "video-research": "Turn videos into timestamped research evidence",
    "visual-plan": "Turn a plan into an interactive visual artifact",
    "visual-recap": "Turn a code change into an interactive visual recap",
    "visual-review": "Review customer-facing surfaces from visual evidence",
    "wayfinder": "Map huge, foggy work through decision tickets",
    "wait-what": "Re-pitch that with simpler language and missing context",
    "what-did-i-get-done": "Summarize authored commits into a concise status update",
    "wizard": "Generate an interactive Bash wizard for manual setup",
    "work-automation-kit": "Install planning, ticketing, and triage workflows",
    "work": "Run the lifecycle through the requested endpoint",
    "writing-beats": "Build an article beat by beat with user pivots",
    "writing-for-agents": "Write predictable skills and agent instruction files",
    "writing-fragments": "Mine conversation into reusable writing fragments",
    "writing-shape": "Shape raw Markdown into a coherent article draft",
}

def yaml_quote(value):
    return '"' + value.replace("\\", "\\\\").replace('"', '\\"') + '"'

def display_name(skill_name):
    words = []
    for index, word in enumerate(skill_name.split("-")):
        lower = word.lower()
        upper = word.upper()
        if upper in ACRONYMS:
            words.append(upper)
        elif lower in BRANDS:
            words.append(BRANDS[lower])
        elif index and lower in SMALL_WORDS:
            words.append(lower)
        else:
            words.append(word.capitalize())
    return " ".join(words)

skills = json.loads((repo / ".claude-plugin/plugin.json").read_text())["skills"]
codex_manifest = json.loads((repo / ".codex-plugin/plugin.json").read_text())
if codex_manifest.get("skills") != "./codex-skills/":
    print("DRIFT: Codex plugin skills must point to ./codex-skills/", file=sys.stderr)
    sys.exit(1)

index = repo / "codex-skills"
expected_proxies = {}
registered_skill_names = set()
for entry in skills:
    canonical = entry.removeprefix("./").rstrip("/")
    text = (repo / canonical / "SKILL.md").read_text()
    frontmatter = re.match(r"---\n(.*?)\n---", text, re.S)
    if not frontmatter:
        print(f"MISSING frontmatter for registered skill: {canonical}", file=sys.stderr)
        sys.exit(1)
    target = f"../../{canonical}/SKILL.md"
    name_match = re.search(r"^name:\s*(.+)$", frontmatter.group(1), re.M)
    description_match = re.search(r"^description:\s*(.+)$", frontmatter.group(1), re.M)
    if not name_match or not description_match:
        print(f"MISSING name or description in frontmatter for registered skill: {canonical}", file=sys.stderr)
        sys.exit(1)
    skill_name = name_match.group(1).strip().strip('"')
    registered_skill_names.add(skill_name)
    short = SHORT_DESCRIPTIONS.get(skill_name, "")
    if not 25 <= len(short) <= 64:
        print(f"MISSING or invalid Codex short description for registered skill: {skill_name}", file=sys.stderr)
        sys.exit(1)
    title = display_name(skill_name)
    metadata = (
        "interface:\n"
        f"  display_name: {yaml_quote(title)}\n"
        f"  short_description: {yaml_quote(short)}\n"
    )
    if re.search(r"^disable-model-invocation:\s*true$", frontmatter.group(1), re.M):
        metadata += "policy:\n  allow_implicit_invocation: false\n"
    expected_proxies[pathlib.Path(canonical).name] = (
        f"---\n{frontmatter.group(1)}\n---\n\n"
        f"Read and follow the complete [canonical skill instructions]({target}) before acting.\n",
        metadata,
    )

if registered_skill_names != set(SHORT_DESCRIPTIONS):
    stale = sorted(set(SHORT_DESCRIPTIONS) - registered_skill_names)
    print(f"STALE Codex short descriptions for unregistered skills: {stale}", file=sys.stderr)
    sys.exit(1)

if mode == "--check":
    actual_proxies = {}
    if index.is_dir():
        for path in index.iterdir():
            skill_file = path / "SKILL.md"
            metadata_file = path / "agents" / "openai.yaml"
            if not path.is_symlink() and path.is_dir() and skill_file.is_file() and metadata_file.is_file():
                actual_proxies[path.name] = (skill_file.read_text(), metadata_file.read_text())
    if actual_proxies != expected_proxies or len(list(index.iterdir())) != len(expected_proxies):
        print("DRIFT: codex-skills differs from registered plugin skills. Run scripts/generate-skill-catalog.sh", file=sys.stderr)
        sys.exit(1)
else:
    index.mkdir(exist_ok=True)
    for path in index.iterdir():
        path.unlink() if path.is_symlink() or path.is_file() else shutil.rmtree(path)
    for name, (content, metadata) in expected_proxies.items():
        directory = index / name
        directory.mkdir()
        (directory / "SKILL.md").write_text(content)
        agents = directory / "agents"
        agents.mkdir()
        (agents / "openai.yaml").write_text(metadata)

rows = []
for entry in sorted(skills):
    d = entry.strip("./")
    p = repo / d / "SKILL.md"
    if not p.exists():
        print(f"MISSING SKILL.md for registered skill: {d}", file=sys.stderr)
        sys.exit(1)
    text = p.read_text()
    m = re.match(r"---\n(.*?)\n---", text, re.S)
    fm = m.group(1) if m else ""
    name = re.search(r"^name:\s*(.+)$", fm, re.M)
    name = name.group(1).strip().strip('"') if name else d
    # Reuse the bounded router copy that also feeds Codex metadata. This avoids
    # truncating model-facing descriptions mid-branch or mid-word.
    first = SHORT_DESCRIPTIONS[name].rstrip(".") + "."
    rows.append(f"| `/{name}` | {first} |")

table = "\n".join(rows)

askben = repo / "ask-ben/SKILL.md"
s = askben.read_text()
START = "<!-- catalog:start (generated by scripts/generate-skill-catalog.sh -- do not edit rows by hand) -->"
END = "<!-- catalog:end -->"

block = f"{START}\n| Skill | Use for |\n|---|---|\n{table}\n{END}"

if START in s:
    new = re.sub(re.escape(START) + r".*?" + re.escape(END), block, s, flags=re.S)
else:
    # first generation: replace the existing contiguous table (header + rows)
    new = re.sub(r"\| Skill \| Use for \|\n\|---\|---\|\n(\| `/.*\|\n?)+", block + "\n", s)
    if START not in new:
        # no recognizable table header: replace the bare row block
        new = re.sub(r"(\| `/.*\|\n?)+", block + "\n", s, count=1)

if mode == "--check":
    if new != s:
        print("DRIFT: ask-ben catalog table differs from generated output. Run scripts/generate-skill-catalog.sh", file=sys.stderr)
        sys.exit(1)
    print("OK: ask-ben catalog and Codex skill index match registered skills")
else:
    askben.write_text(new)
    print(f"skill surfaces regenerated: {len(rows)} skills")
PY
