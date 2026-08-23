# Packaging integrity (issue #48 WS2): no dangling relative links in shipped
# markdown, no broken symlinks, every hook script executable.

# Codex accepts one non-root directory for plugin skills. Keep that directory
# aligned with Claude's authoritative registered skill list.
if python3 - "$REPO_ROOT" <<'PY'
import json
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1])
codex_manifest = json.loads((repo / ".codex-plugin/plugin.json").read_text())
claude_manifest = json.loads((repo / ".claude-plugin/plugin.json").read_text())
index = repo / "codex-skills"

if codex_manifest.get("skills") != "./codex-skills/":
    raise SystemExit("Codex skills must point to ./codex-skills/")

expected = {pathlib.Path(path).name: path.removeprefix("./").rstrip("/") for path in claude_manifest["skills"]}
actual = {path.name for path in index.iterdir()}
representative_descriptions = {
    "ask-ben": "Route work through Ben's frontend skill harness",
    "grilling": "Stress-test plans, decisions, and ideas",
    "to-spec": "Turn the conversation into a tracker-ready spec",
    "wayfinder": "Map huge, foggy work through decision tickets",
}
if actual != set(expected):
    missing = sorted(expected.keys() - actual)
    extra = sorted(actual - expected.keys())
    raise SystemExit(f"Codex skill index drift: missing={missing}, extra={extra}")

for name, canonical in expected.items():
    directory = index / name
    proxy = directory / "SKILL.md"
    metadata = directory / "agents" / "openai.yaml"
    if directory.is_symlink() or not directory.is_dir() or proxy.is_symlink() or not proxy.is_file():
        raise SystemExit(f"Codex cache-safe proxy missing: {name}")
    if metadata.is_symlink() or not metadata.is_file():
        raise SystemExit(f"Codex skill metadata missing: {name}")
    canonical_text = (repo / canonical / "SKILL.md").read_text()
    canonical_frontmatter = re.match(r"---\n(.*?)\n---", canonical_text, re.S)
    proxy_text = proxy.read_text()
    proxy_frontmatter = re.match(r"---\n(.*?)\n---", proxy_text, re.S)
    if not canonical_frontmatter or not proxy_frontmatter or proxy_frontmatter.group(1) != canonical_frontmatter.group(1):
        raise SystemExit(f"Codex proxy frontmatter drift: {name}")
    target = f"../../{canonical}/SKILL.md"
    if proxy_text.split("---", 2)[2].strip() != f"Read and follow the complete [canonical skill instructions]({target}) before acting.":
        raise SystemExit(f"Codex proxy target drift: {name}")
    metadata_text = metadata.read_text()
    display_name = re.search(r'^  display_name: "(.+)"$', metadata_text, re.M)
    short_description = re.search(r'^  short_description: "(.+)"$', metadata_text, re.M)
    if not display_name or not short_description or not 25 <= len(short_description.group(1)) <= 64:
        raise SystemExit(f"Codex skill interface metadata invalid: {name}")
    if short_description.group(1).startswith("Help with "):
        raise SystemExit(f"Codex skill description is generic rather than skill-derived: {name}")
    expected_description = representative_descriptions.get(name)
    if expected_description and short_description.group(1) != expected_description:
        raise SystemExit(f"Codex skill description is not review-ready: {name}")
    user_invoked = bool(re.search(r'^disable-model-invocation:\s*true$', canonical_frontmatter.group(1), re.M))
    implicit_disabled = bool(re.search(r'^  allow_implicit_invocation:\s*false$', metadata_text, re.M))
    if user_invoked != implicit_disabled:
        raise SystemExit(f"Codex invocation policy drift: {name}")
PY
then
  echo "  PASS  Codex plugin exposes cache-safe proxies with matching metadata"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Codex plugin skill index and metadata match the registered skill surface"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: Codex plugin skill index drift"
fi

# Ignore fenced code: generic signatures such as Foo[T any](data) are not links.
_pi_bad=$(python3 - "$REPO_ROOT" <<'PY'
import os
import pathlib
import re
import sys

repo = pathlib.Path(sys.argv[1])
excluded_dirs = {"node_modules", ".git", "dist", "deprecated"}
link_pattern = re.compile(r"\]\(([^)]+)\)")
fence_pattern = re.compile(r"^[ \t]{0,3}((?:\x60){3,}|~{3,})")
bad = []

markdown_paths = []
for root, dirs, files in os.walk(repo):
    dirs[:] = [directory for directory in dirs if directory not in excluded_dirs]
    markdown_paths.extend(
        pathlib.Path(root) / name
        for name in files
        if name.endswith(".md") and not name.endswith("-FORMAT.md")
    )

for path in markdown_paths:
    fence = None
    for line in path.read_text().splitlines():
        if fence is not None:
            closing_pattern = re.compile(
                rf"^[ \t]{{0,3}}{re.escape(fence[0])}{{{fence[1]},}}[ \t]*$"
            )
            if closing_pattern.match(line):
                fence = None
            continue

        match = fence_pattern.match(line)
        if match:
            marker = match.group(1)
            fence = (marker[0], len(marker))
            continue

        for target in link_pattern.findall(line):
            if target.startswith(("http", "#", "mailto:", "<")) or target == "link":
                continue
            clean = target.split("#", 1)[0].split(" ", 1)[0]
            if (path.parent / clean).exists() or (repo / clean).exists():
                continue
            if path.is_relative_to(repo / "docs-site/content") and clean.startswith("/"):
                if (repo / "docs-site/public" / clean.lstrip("/")).exists():
                    continue
            bad.append(f" {path}->{clean}")

print("".join(bad))
PY
)

if [ -n "$_pi_bad" ]; then
  echo "  FAIL  dangling markdown links:$_pi_bad"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: dangling markdown links"
else
  echo "  PASS  no dangling relative links in shipped markdown"
  PASS=$((PASS + 1))
fi

_pi_symbad=$(find "$REPO_ROOT" -type l ! -exec test -e {} \; -print 2>/dev/null | grep -v node_modules || true)
if [ -n "$_pi_symbad" ]; then
  echo "  FAIL  broken symlinks: $_pi_symbad"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: broken symlinks"
else
  echo "  PASS  no broken symlinks"
  PASS=$((PASS + 1))
fi

_pi_noexec=$(find "$REPO_ROOT/.claude/hooks" "$REPO_ROOT/shared" -name '*.sh' ! -perm -u+x 2>/dev/null || true)
if [ -n "$_pi_noexec" ]; then
  echo "  FAIL  non-executable hook scripts: $_pi_noexec"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: non-executable hook scripts"
else
  echo "  PASS  all hook scripts executable"
  PASS=$((PASS + 1))
fi

# Executable ownership (issue #48 WS3): the Biome reference config must be
# machine-loadable and actually carry every rule the retirement notes claim --
# asserted against the parsed artifact, not prose.
_pi_cfg=$(awk '/^```jsonc?$/{f=1;next} /^```$/{f=0} f' "$REPO_ROOT/frontend-starter-kit/references/biome/REFERENCE.md" | sed -e 's://[^"]*$::' )
if printf '%s' "$_pi_cfg" | jq -e . >/dev/null 2>&1; then
  echo "  PASS  Biome reference config parses as JSON"
  PASS=$((PASS + 1))
  for _pi_rule in noRestrictedImports noRestrictedElements noProcessEnv; do
    if printf '%s' "$_pi_cfg" | jq -e ".. | objects | select(has(\"$_pi_rule\"))" >/dev/null 2>&1; then
      echo "  PASS  parsed Biome config carries $_pi_rule"
      PASS=$((PASS + 1))
    else
      echo "  FAIL  parsed Biome config missing $_pi_rule"
      FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: Biome config missing $_pi_rule"
    fi
  done
else
  echo "  FAIL  Biome reference config block does not parse as JSON"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: Biome config unparseable"
fi

# docs/screenshots is dead (owner call 2026-07-10): nothing may reference it
# and the directory must not return.
if [ -d "$REPO_ROOT/docs/screenshots" ]; then
  echo "  FAIL  docs/screenshots resurrected -- killed by owner decision"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: docs/screenshots resurrected"
else
  echo "  PASS  docs/screenshots stays dead"
  PASS=$((PASS + 1))
fi
_pi_media_refs=$(grep -rl "docs/screenshots" "$REPO_ROOT/README.md" "$REPO_ROOT"/*/SKILL.md 2>/dev/null || true)
if [ -n "$_pi_media_refs" ]; then
  echo "  FAIL  live references to dead docs/screenshots: $_pi_media_refs"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: dead screenshots referenced"
else
  echo "  PASS  no live references to docs/screenshots"
  PASS=$((PASS + 1))
fi

# Library mirror integrity: every _hook-lib.sh in an executable location must
# resolve to the ONE authoritative shared/hook-lib.sh (the diverged-mirror bug
# left live hooks calling functions that only existed in shared/).
_pi_lib_bad=""
while IFS= read -r _pi_lib; do
  cmp -s "$_pi_lib" "$REPO_ROOT/shared/hook-lib.sh" || _pi_lib_bad="$_pi_lib_bad $_pi_lib"
done < <(find "$REPO_ROOT/.claude/hooks" "$REPO_ROOT/frontend-starter-kit" "$REPO_ROOT/accessibility" -name '_hook-lib.sh' 2>/dev/null)
if [ -n "$_pi_lib_bad" ]; then
  echo "  FAIL  diverged hook-lib mirrors:$_pi_lib_bad"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: diverged hook-lib mirrors"
else
  echo "  PASS  every _hook-lib.sh resolves to the authoritative shared lib"
  PASS=$((PASS + 1))
fi
