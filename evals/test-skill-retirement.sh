# Public discovery and prompt contract: retired skills cannot remain callable
# through their merged name, host adapter, router, or another active skill.

if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1])
retired = {"ponytail", "ponytail-audit", "ponytail-debt", "ponytail-review", "deslop"}
errors = []
for name in sorted(retired):
    for directory in (repo / name, repo / "codex-skills" / name):
        if directory.exists():
            errors.append(f"retired entrypoint remains: {directory.relative_to(repo)}")

for locale in ("pl", "zh-CN", "zh-TW"):
    current_docs = repo / "docs-site/content" / locale
    for name in retired:
        if (current_docs / "skills" / f"{name}.md").exists():
            errors.append(f"retired current docs remain: {locale}/{name}")

skills = json.loads((repo / ".claude-plugin/plugin.json").read_text())["skills"]
prompts = {repo / "ask-ben/SKILL-CATALOG.md", repo / "ETHOS.md", repo / "CLAUDE.md"}
prompts.update((repo / "agents").glob("*.md"))
for locale in ("pl", "zh-CN", "zh-TW"):
    current_docs = repo / "docs-site/content" / locale
    prompts.add(current_docs / "index.mdx")
    prompts.update((current_docs / "skills").glob("*.md"))
for entry in skills:
    directory = repo / entry.removeprefix("./").rstrip("/")
    if directory.name in retired:
        errors.append(f"retired registration remains: {entry}")
    prompts.update(directory / name for name in ("SKILL.md", "REFERENCE.md"))
    prompts.update((directory / "references").rglob("*.md"))

for prompt in sorted(prompts):
    if prompt.is_file() and re.search(r"\b(?:ponytail(?:-audit|-debt|-review)?|deslop)\b", prompt.read_text(), re.I):
        errors.append(f"active prompt routes to retired skill: {prompt.relative_to(repo)}")
    if prompt.is_file() and re.search(r"less code, more meaning|semantic density|reuse-first ladder|code is liability", prompt.read_text(), re.I):
        errors.append(f"derived minimization policy remains: {prompt.relative_to(repo)}")

for error in errors:
    print(error, file=sys.stderr)
sys.exit(bool(errors))
PY
then
  echo "  PASS  retired skills are absent from discovery and active prompts"
  PASS=$((PASS + 1))
else
  echo "  FAIL  retired skills remain discoverable or routed"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: retired skills remain discoverable or routed"
fi
