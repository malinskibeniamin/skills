#!/bin/bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex_bin="${CODEX_BIN:-$(command -v codex 2>/dev/null || true)}"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/frontend-skills-codex-install.XXXXXX")"
marketplace_root="$test_root/local marketplace"
test_home="$test_root/user home"
codex_home="$test_root/codex home"

cleanup() {
  if [ -d "$test_root" ] &&
    [[ "$(basename "$test_root")" == frontend-skills-codex-install.* ]]; then
    rm -rf -- "$test_root"
  fi
}
trap cleanup EXIT

fail() {
  printf 'error: %s\n' "$1" >&2
  exit 1
}

run_codex() {
  HOME="$test_home" CODEX_HOME="$codex_home" "$codex_bin" "$@"
}

[ -n "$codex_bin" ] || fail "Codex CLI not found"
command -v jq >/dev/null 2>&1 || fail "jq is required"

mkdir -p "$marketplace_root" "$test_home" "$codex_home"

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
manifest="$marketplace_root/.codex-plugin/plugin.json"
expected_name="$(jq -er '.name | select(type == "string" and length > 0)' "$manifest")"
expected_version="$(jq -er '.version | select(type == "string" and length > 0)' "$manifest")"
marketplace_name="$(jq -er '.name | select(type == "string" and length > 0)' "$marketplace_root/.agents/plugins/marketplace.json")"
plugin_id="$expected_name@$marketplace_name"

add_result="$test_root/marketplace-add.json"
available_result="$test_root/plugin-available.json"
install_result="$test_root/plugin-install.json"
reinstall_result="$test_root/plugin-reinstall.json"
list_result="$test_root/plugin-list.json"

run_codex plugin marketplace add "$marketplace_root" --json >"$add_result"
jq -e \
  --arg marketplace "$marketplace_name" \
  --arg root "$marketplace_root" \
  '.marketplaceName == $marketplace and
   .installedRoot == $root and
   .alreadyAdded == false' \
  "$add_result" >/dev/null ||
  fail "Codex did not add the isolated local marketplace"

run_codex plugin list --available --json >"$available_result"
jq -e \
  --arg id "$plugin_id" \
  --arg version "$expected_version" \
  'any(.available[]; .pluginId == $id and .version == $version and .installed == false)' \
  "$available_result" >/dev/null ||
  fail "frontend-skills is not discoverable from the local marketplace"

run_codex plugin add "$plugin_id" --json >"$install_result"
jq -e \
  --arg id "$plugin_id" \
  --arg version "$expected_version" \
  '.pluginId == $id and
   .version == $version and
   (.installedPath | type == "string" and length > 0)' \
  "$install_result" >/dev/null ||
  fail "Codex returned invalid plugin installation metadata"

installed_path="$(jq -er '.installedPath' "$install_result")"
[ -d "$installed_path" ] || fail "Codex plugin cache directory is missing"
installed_path="$(cd -P "$installed_path" && pwd)"
cache_root="$(cd -P "$codex_home/plugins/cache" && pwd)"
case "$installed_path/" in
  "$cache_root"/*) ;;
  *) fail "Codex installed the plugin outside the isolated cache" ;;
esac

installed_manifest="$installed_path/.codex-plugin/plugin.json"
jq -e \
  --arg name "$expected_name" \
  --arg version "$expected_version" \
  '.name == $name and .version == $version' \
  "$installed_manifest" >/dev/null ||
  fail "installed plugin manifest does not match the marketplace entry"

expected_skill_count="$(
  find "$marketplace_root/codex-skills" -mindepth 2 -maxdepth 2 -name SKILL.md |
    wc -l |
    tr -d ' '
)"
installed_skill_count="$(
  find "$installed_path/codex-skills" -mindepth 2 -maxdepth 2 -name SKILL.md |
    wc -l |
    tr -d ' '
)"
[ "$expected_skill_count" -gt 0 ] || fail "source plugin exposes no Codex skills"
[ "$installed_skill_count" -eq "$expected_skill_count" ] ||
  fail "installed Codex skill count does not match the source"

for skill in development-lifecycle tdd review; do
  [ -f "$installed_path/codex-skills/$skill/SKILL.md" ] ||
    fail "installed plugin is missing the $skill skill"
  [ -f "$installed_path/codex-skills/$skill/agents/openai.yaml" ] ||
    fail "installed plugin is missing $skill interface metadata"
done

hooks_path="$(jq -er '.hooks | select(type == "string" and length > 0)' "$installed_manifest")"
hooks_path="${hooks_path#./}"
hooks_manifest="$installed_path/$hooks_path"
[ -f "$hooks_manifest" ] || fail "installed Codex hooks manifest is missing"

hook_scripts="$(
  jq -r '.. | .command? // empty' "$hooks_manifest" |
    sed -n 's#.*\.claude/hooks/\([^"]*\.sh\).*#\1#p' |
    sort -u
)"
[ -n "$hook_scripts" ] || fail "installed Codex hooks manifest has no commands"
while IFS= read -r hook_script; do
  [ -x "$installed_path/.claude/hooks/$hook_script" ] ||
    fail "installed hook is missing or not executable: $hook_script"
done <<EOF
$hook_scripts
EOF
[ -f "$installed_path/shared/hook-lib.sh" ] ||
  fail "installed hooks are missing their shared library"

# Reinstalling the same marketplace version must be safe and must not create a
# duplicate installed entry.
run_codex plugin add "$plugin_id" --json >"$reinstall_result"
jq -e \
  --arg id "$plugin_id" \
  --arg version "$expected_version" \
  --arg path "$installed_path" \
  '.pluginId == $id and .version == $version and .installedPath == $path' \
  "$reinstall_result" >/dev/null ||
  fail "reinstalling the same plugin version changed its identity or cache path"

run_codex plugin list --json >"$list_result"
jq -e \
  --arg id "$plugin_id" \
  --arg version "$expected_version" \
  '[.installed[] |
    select(.pluginId == $id and
      .version == $version and
      .installed == true and
      .enabled == true)] |
   length == 1' \
  "$list_result" >/dev/null ||
  fail "Codex did not retain exactly one enabled frontend-skills installation"

printf 'Codex plugin installation test passed: %s (%s skills)\n' \
  "$plugin_id version $expected_version" \
  "$installed_skill_count"
