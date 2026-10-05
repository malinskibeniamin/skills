#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
claude_bin="${CLAUDE_BIN:-$(command -v claude 2>/dev/null || true)}"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/frontend-skills-claude-install.XXXXXX")"
marketplace_root="$test_root/local marketplace"
test_home="$test_root/user home"
claude_config="$test_root/claude config"

cleanup() {
  if [ -d "$test_root" ] &&
    [[ "$(basename "$test_root")" == frontend-skills-claude-install.* ]]; then
    rm -rf -- "$test_root"
  fi
}
trap cleanup EXIT

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

run_claude() {
  # The eval harness reserves fd 3 for assertion counters. Do not let Claude's
  # updater or other descendants inherit it and hold the harness pipe open.
  HOME="$test_home" CLAUDE_CONFIG_DIR="$claude_config" "$claude_bin" "$@" 3>/dev/null
}

claude_bin="$(command -v "$claude_bin" 2>/dev/null || true)"
[ -n "$claude_bin" ] || fail "Claude Code CLI not found"
command -v jq >/dev/null 2>&1 || fail "jq is required"

plugin_name="${1:-frontend-skills}"
case "$plugin_name" in
  frontend-skills) plugin_relative_path="." ;;
  frontend-skills-mods) plugin_relative_path="plugins/frontend-skills-mods" ;;
  *) fail "unknown plugin: $plugin_name" ;;
esac

if [ "$plugin_name" = frontend-skills-mods ]; then
  claude_version="$(run_claude --version | awk '{print $1}')"
  if ! printf '%s\n' "$claude_version" | awk -F. '
    NF == 3 && $1 ~ /^[0-9]+$/ && $2 ~ /^[0-9]+$/ && $3 ~ /^[0-9]+$/ {
      if ($1 > 2 || ($1 == 2 && ($2 > 1 || ($2 == 1 && $3 >= 287)))) ok = 1
    }
    END { exit !ok }
  '; then
    fail "frontend-skills-mods requires Claude Code 2.1.287 or later (found $claude_version)"
  fi
  [ -x "$repo_root/node_modules/.bin/tsc" ] || fail "run bun install before testing mods"
fi

# Resolve before changing cwd for the isolated type-generation loader below.
claude_bin="$(cd "$(dirname "$claude_bin")" && pwd)/$(basename "$claude_bin")"
mkdir -p "$marketplace_root" "$test_home" "$claude_config"

# Exercise tracked and unignored worktree files without copying private/runtime
# state from .gitignore entries such as .context, .env files, and node_modules.
(
  cd "$repo_root"
  git ls-files --cached --others --exclude-standard -z |
    tar --null -T - -cf -
) | (
  cd "$marketplace_root"
  tar -xf -
)

marketplace_root="$(cd -P "$marketplace_root" && pwd)"
manifest="$marketplace_root/$plugin_relative_path/.claude-plugin/plugin.json"
marketplace="$marketplace_root/.claude-plugin/marketplace.json"
expected_name="$(jq -er '.name | select(type == "string" and length > 0)' "$manifest")"
expected_version="$(jq -er '.version | select(type == "string" and length > 0)' "$manifest")"
marketplace_name="$(jq -er '.name | select(type == "string" and length > 0)' "$marketplace")"
plugin_id="$expected_name@$marketplace_name"

# Claude resolves relative marketplace sources from marketplace.json. Point the
# isolated copy at itself so the test cannot fall through to GitHub or a cache.
marketplace_tmp="$test_root/marketplace.json"
jq '.plugins |= map(if .name == "frontend-skills" then .source = "./" else . end)' \
  "$marketplace" >"$marketplace_tmp"
mv "$marketplace_tmp" "$marketplace"

run_claude plugin validate "$marketplace_root" >/dev/null
if [ "$plugin_name" = frontend-skills-mods ]; then
  run_claude plugin validate --strict "$marketplace_root/$plugin_relative_path" >/dev/null
fi
run_claude plugin marketplace add "$marketplace_root" >/dev/null
# Claude Code 2.1.220 exits its process group when plugin-install stdout is
# redirected. Keep the progress line attached; CI still gets deterministic
# assertions from the JSON list call below.
run_claude plugin install "$plugin_id"

list_result="$test_root/plugin-list.json"
run_claude plugin list --json >"$list_result"
jq -e \
  --arg id "$plugin_id" \
  --arg version "$expected_version" \
  '[.[] |
    select(.id == $id and
      .version == $version and
      .enabled == true and
      (.installPath | type == "string" and length > 0))] |
   length == 1' \
  "$list_result" >/dev/null ||
  fail "Claude did not retain exactly one enabled $plugin_name installation"

installed_path="$(
  jq -er --arg id "$plugin_id" --arg version "$expected_version" \
    '.[] | select(.id == $id and .version == $version) | .installPath' \
    "$list_result"
)"
[ -d "$installed_path" ] || fail "Claude plugin cache directory is missing"
installed_path="$(cd -P "$installed_path" && pwd)"
cache_root="$(cd -P "$claude_config/plugins/cache" && pwd)"
case "$installed_path/" in
  "$cache_root"/*) ;;
  *) fail "Claude installed the plugin outside the isolated cache" ;;
esac

installed_manifest="$installed_path/.claude-plugin/plugin.json"
jq -e \
  --arg name "$expected_name" \
  --arg version "$expected_version" \
  '.name == $name and .version == $version' \
  "$installed_manifest" >/dev/null ||
  fail "installed plugin manifest does not match the marketplace entry"

if [ "$plugin_name" = frontend-skills-mods ]; then
  run_claude plugin validate --strict "$installed_path"
  run_claude plugin test "$installed_path"

  # The loader emits this build's declarations before /help returns. A built-in
  # command, empty config/HOME and no inherited credentials: never a model prompt.
  # Work in the scratch directory, not a repository with settings or MCP servers.
  (
    cd "$test_root"
    env -i PATH="$PATH" HOME="$test_home" CLAUDE_CONFIG_DIR="$claude_config" \
      TERM=dumb "$claude_bin" --setting-sources "" --no-session-persistence \
      --plugin-dir "$installed_path" --print /help 3>/dev/null
  ) >"$test_root/types-loader.log" 2>&1 || {
    cat "$test_root/types-loader.log" >&2
    fail "Claude could not load the mod to emit SDK declarations"
  }
  sdk="$installed_path/.claude-plugin/types/claude-code/index.d.ts"
  [ -f "$sdk" ] || fail "Claude did not emit mod SDK declarations"
  [ "$(head -1 "$sdk")" = "// Written by Claude Code $claude_version." ] ||
    fail "generated mod SDK does not match the tested Claude build"
  "$repo_root/node_modules/.bin/tsc" -p "$installed_path"
  run_claude plugin disable "$plugin_id" >/dev/null
  run_claude plugin list --json >"$list_result"
  jq -e --arg id "$plugin_id" \
    '[.[] | select(.id == $id and .enabled == false)] | length == 1' \
    "$list_result" >/dev/null || fail "Claude did not disable the mod"
  run_claude plugin uninstall "$plugin_id" >/dev/null
  run_claude plugin list --json >"$list_result"
  jq -e --arg id "$plugin_id" \
    '[.[] | select(.id == $id)] | length == 0' \
    "$list_result" >/dev/null || fail "Claude did not uninstall the mod"
  printf 'Claude mods passed: %s (%s; install, runtime, types, rollback)\n' \
    "$plugin_id" "$claude_version"
  exit 0
fi

expected_skill_count="$(jq '.skills | length' "$manifest")"
installed_skill_count=0
while IFS= read -r skill_path; do
  skill_path="${skill_path#./}"
  skill_path="${skill_path%/}"
  [ -f "$installed_path/$skill_path/SKILL.md" ] ||
    fail "installed Claude plugin is missing $skill_path/SKILL.md"
  installed_skill_count=$((installed_skill_count + 1))
done < <(jq -r '.skills[]' "$manifest")
[ "$installed_skill_count" -eq "$expected_skill_count" ] ||
  fail "installed Claude skill count does not match the manifest"

# Check upstream bytes and every adapter dependency inside the actual plugin cache.
python3 "$installed_path/scripts/vendor-poteto.py" --check
bash "$installed_path/scripts/generate-skill-catalog.sh" --check

hooks_manifest="$installed_path/hooks/hooks.json"
[ -f "$hooks_manifest" ] || fail "installed Claude hooks manifest is missing"

hook_scripts="$(
  jq -r '.. | .command? // empty' "$hooks_manifest" |
    sed -n 's#.*\.claude/hooks/\([^" ]*\.sh\).*#\1#p' |
    sort -u
)"
[ -n "$hook_scripts" ] || fail "installed Claude hooks manifest has no commands"
while IFS= read -r hook_script; do
  [ -x "$installed_path/.claude/hooks/$hook_script" ] ||
    fail "installed hook is missing or not executable: $hook_script"
done <<EOF
$hook_scripts
EOF
[ -f "$installed_path/shared/hook-lib.sh" ] ||
  fail "installed hooks are missing their shared library"

printf 'Claude plugin installation test passed: %s (%s skills)\n' \
  "$plugin_id version $expected_version" \
  "$installed_skill_count"
