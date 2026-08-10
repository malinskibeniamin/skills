# Behavioral coverage for stale plugin and pinned-marketplace diagnosis.

_verify_tmp="$(mktemp -d "${TMPDIR:-/tmp}/frontend-skills-verify-install.XXXXXX")"
_verify_home="$_verify_tmp/home"
_verify_bin="$_verify_tmp/bin"
mkdir -p \
  "$_verify_home/.claude/plugins/cache/skills/frontend-skills/4.9.0/.claude-plugin" \
  "$_verify_home/.claude/plugins/cache/skills/frontend-skills/4.9.0/hooks" \
  "$_verify_home/.claude/plugins/cache/skills/frontend-skills/4.33.0/.claude-plugin" \
  "$_verify_home/.claude/plugins/cache/skills/frontend-skills/4.33.0/hooks" \
  "$_verify_home/.claude/plugins/marketplaces/skills/.claude-plugin" \
  "$_verify_home/.codex" \
  "$_verify_tmp/consumer" \
  "$_verify_bin"

cat >"$_verify_home/.claude/plugins/cache/skills/frontend-skills/4.9.0/.claude-plugin/plugin.json" <<'JSON'
{"name":"frontend-skills","version":"4.9.0"}
JSON
cat >"$_verify_home/.claude/plugins/cache/skills/frontend-skills/4.33.0/.claude-plugin/plugin.json" <<'JSON'
{"name":"frontend-skills","version":"4.33.0"}
JSON
printf '%s\n' '{"hooks":{}}' >"$_verify_home/.claude/plugins/cache/skills/frontend-skills/4.9.0/hooks/hooks.json"
printf '%s\n' '{"hooks":{}}' >"$_verify_home/.claude/plugins/cache/skills/frontend-skills/4.33.0/hooks/hooks.json"
cat >"$_verify_home/.claude/plugins/marketplaces/skills/.claude-plugin/marketplace.json" <<'JSON'
{"plugins":[{"name":"frontend-skills","version":"4.34.0"}]}
JSON
cat >"$_verify_home/.codex/config.toml" <<'TOML'
[marketplaces.skills]
source_type = "git"
source = "https://github.com/malinskibeniamin/skills.git"
ref = "v4.33.0"
TOML

cat >"$_verify_bin/claude" <<'SH'
#!/bin/sh
if [ "$*" = "plugin list --json" ]; then
  printf '%s\n' '[{"id":"frontend-skills@skills","version":"4.33.0","enabled":true}]'
  exit 0
fi
exit 1
SH
cat >"$_verify_bin/codex" <<'SH'
#!/bin/sh
if [ "$*" = "plugin list --available --json" ]; then
  printf '%s\n' '{"available":[{"pluginId":"frontend-skills@skills","version":"4.34.0","installed":true}]}'
  exit 0
fi
if [ "$*" = "plugin list --json" ]; then
  printf '%s\n' '{"installed":[{"pluginId":"frontend-skills@skills","version":"4.33.0","installed":true,"enabled":true}]}'
  exit 0
fi
exit 1
SH
chmod +x "$_verify_bin/claude" "$_verify_bin/codex"
ln -s "$(command -v jq)" "$_verify_bin/jq"

_verify_output="$(
  {
    cd "$_verify_tmp/consumer"
    HOME="$_verify_home" PATH="$_verify_bin:/usr/bin:/bin" \
      bash "$REPO_ROOT/scripts/verify-install.sh"
  } 2>&1 || true
)"
_verify_json="$(
  {
    cd "$_verify_tmp/consumer"
    HOME="$_verify_home" PATH="$_verify_bin:/usr/bin:/bin" \
      bash "$REPO_ROOT/scripts/verify-install.sh" --json
  } 2>/dev/null || true
)"

_verify_assert() {
  _verify_pattern="$1"
  _verify_description="$2"
  if printf '%s\n' "$_verify_output" | grep -qF -- "$_verify_pattern"; then
    echo "  PASS  $_verify_description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $_verify_description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $_verify_description"
  fi
}

_verify_assert "Version: 4.33.0" "verify-install chooses 4.33 over lexicographic 4.9"
_verify_assert "Claude plugin 4.33.0 is behind 4.34.0" "verify-install detects stale Claude plugin"
_verify_assert "Codex plugin 4.33.0 is behind 4.34.0" "verify-install detects stale Codex plugin"
_verify_assert "Codex marketplace ref v4.33.0 is behind v4.34.0" "verify-install detects stale Codex pin"
_verify_assert "TraceDecay not found — optional semantic graph" \
  "verify-install points users to optional TraceDecay setup"

if printf '%s\n' "$_verify_json" | tail -1 | jq -e '
  .claudeVersion == "4.33.0" and
  .codexVersion == "4.33.0" and
  .latestVersion == "4.34.0" and
  .codexMarketplaceRef == "v4.33.0"
' >/dev/null 2>&1; then
  echo "  PASS  verify-install JSON reports runtime and marketplace versions"
  PASS=$((PASS + 1))
else
  echo "  FAIL  verify-install JSON reports runtime and marketplace versions"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: verify-install JSON version health"
fi

rm -rf -- "$_verify_tmp"
