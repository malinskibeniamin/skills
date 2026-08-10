#!/bin/bash
set -eo pipefail

# Verify that skills and hooks are properly installed and up-to-date.
# Run from any consumer repo to check installation health.
#
# Usage:
#   bash verify-install.sh                    # check current repo
#   bash verify-install.sh --remote origin    # also check for updates from remote
#   bash verify-install.sh --json             # machine-readable output
#
# Exit codes:
#   0 = all checks pass
#   1 = issues found (details in output)

REMOTE=""
JSON_MODE=false
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --remote)
      if [ "$#" -gt 1 ] && [[ "$2" != --* ]]; then
        REMOTE="$2"
        shift 2
      else
        REMOTE="origin"
        shift
      fi
      ;;
    --json)
      JSON_MODE=true
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

PASS=0
WARN=0
FAIL=0
ISSUES=""

_pass() { PASS=$((PASS + 1)); $JSON_MODE || echo "  PASS  $1"; }
_warn() { WARN=$((WARN + 1)); ISSUES="$ISSUES\n  WARN  $1"; $JSON_MODE || echo "  WARN  $1"; }
_fail() { FAIL=$((FAIL + 1)); ISSUES="$ISSUES\n  FAIL  $1"; $JSON_MODE || echo "  FAIL  $1"; }

_semver_valid() {
  [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

_semver_gt() {
  local left_major left_minor left_patch right_major right_minor right_patch
  IFS=. read -r left_major left_minor left_patch <<<"$1"
  IFS=. read -r right_major right_minor right_patch <<<"$2"
  [ "$left_major" -gt "$right_major" ] ||
    { [ "$left_major" -eq "$right_major" ] && [ "$left_minor" -gt "$right_minor" ]; } ||
    { [ "$left_major" -eq "$right_major" ] && [ "$left_minor" -eq "$right_minor" ] && [ "$left_patch" -gt "$right_patch" ]; }
}

LATEST_VERSION="unknown"
_consider_latest() {
  local candidate="${1#v}"
  _semver_valid "$candidate" || return 0
  if [ "$LATEST_VERSION" = "unknown" ] || _semver_gt "$candidate" "$LATEST_VERSION"; then
    LATEST_VERSION="$candidate"
  fi
}

$JSON_MODE || echo "=== Skills & Hooks Installation Verification ==="
$JSON_MODE || echo ""

# ── Detect installation mode ────────────────────────────────────
# Plugin install: hooks live in plugin cache, wired via hooks.json
# Manual install: hooks copied to consumer .claude/hooks/

PLUGIN_ROOT=""
INSTALL_MODE="manual"

# Check if installed as a plugin. Compare SemVer numerically: 4.33 beats 4.9.
CLAUDE_CONFIG_ROOT="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
CLAUDE_CACHE_ROOT="$CLAUDE_CONFIG_ROOT/plugins/cache/skills/frontend-skills"
PLUGIN_VERSION="unknown"
for dir in "$CLAUDE_CACHE_ROOT"/*/; do
  if [ -f "${dir}hooks/hooks.json" ]; then
    candidate_version="$(basename "${dir%/}")"
    if _semver_valid "$candidate_version" &&
      { [ "$PLUGIN_VERSION" = "unknown" ] || _semver_gt "$candidate_version" "$PLUGIN_VERSION"; }; then
      PLUGIN_ROOT="$dir"
      PLUGIN_VERSION="$candidate_version"
      INSTALL_MODE="plugin"
    fi
  fi
done

$JSON_MODE || echo "--- Install Mode: $INSTALL_MODE ---"

# ── 1. Version info ───────────────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Version ---"

if [ "$INSTALL_MODE" = "plugin" ]; then
  PLUGIN_JSON="${PLUGIN_ROOT}.claude-plugin/plugin.json"
else
  PLUGIN_JSON=".claude-plugin/plugin.json"
fi

if [ -f "$PLUGIN_JSON" ] && command -v jq &>/dev/null; then
  _version=$(jq -r '.version // "unknown"' "$PLUGIN_JSON")
  _updated=$(jq -r '.["x-updatedAt"] // "unknown"' "$PLUGIN_JSON")
  _pass "Version: ${_version} (updated: ${_updated})"
else
  _version="unknown"
  _updated="unknown"
  _warn "Could not read plugin version — plugin.json missing or jq unavailable"
fi

# ── 1b. Runtime and marketplace freshness ─────────────────────

CLAUDE_VERSION="unknown"
CODEX_VERSION="unknown"
CODEX_MARKETPLACE_REF="unknown"
CODEX_HOME_ROOT="${CODEX_HOME:-$HOME/.codex}"

if command -v jq >/dev/null 2>&1; then
  if command -v claude >/dev/null 2>&1; then
    CLAUDE_VERSION="$(
      claude plugin list --json 2>/dev/null |
        jq -r '[.[] | select(.id == "frontend-skills@skills") | .version] | first // "unknown"' \
          2>/dev/null || echo "unknown"
    )"
  fi
  [ -n "$CLAUDE_VERSION" ] || CLAUDE_VERSION="unknown"
  if [ "$CLAUDE_VERSION" = "unknown" ] && [ "$INSTALL_MODE" = "plugin" ]; then
    CLAUDE_VERSION="$_version"
  fi

  if command -v codex >/dev/null 2>&1; then
    CODEX_VERSION="$(
      codex plugin list --json 2>/dev/null |
        jq -r '[.installed[] | select(.pluginId == "frontend-skills@skills") | .version] | first // "unknown"' \
          2>/dev/null || echo "unknown"
    )"
    [ -n "$CODEX_VERSION" ] || CODEX_VERSION="unknown"
    while IFS= read -r candidate_version; do
      _consider_latest "$candidate_version"
    done < <(
      codex plugin list --available --json 2>/dev/null |
        jq -r '.available[]? | select(.pluginId == "frontend-skills@skills") | .version' \
          2>/dev/null || true
    )
  fi

  for marketplace_manifest in \
    "$CLAUDE_CONFIG_ROOT"/plugins/marketplaces/*/.claude-plugin/marketplace.json \
    .claude-plugin/marketplace.json; do
    [ -f "$marketplace_manifest" ] || continue
    while IFS= read -r candidate_version; do
      _consider_latest "$candidate_version"
    done < <(
      jq -r '.plugins[]? | select(.name == "frontend-skills") | .version' \
        "$marketplace_manifest" 2>/dev/null || true
    )
  done
fi

if [ "$CODEX_VERSION" = "unknown" ]; then
  CODEX_CACHE_VERSION="unknown"
  for dir in "$CODEX_HOME_ROOT/plugins/cache/skills/frontend-skills"/*/; do
    [ -f "${dir}.codex-plugin/plugin.json" ] || continue
    candidate_version="$(basename "${dir%/}")"
    if _semver_valid "$candidate_version" &&
      { [ "$CODEX_CACHE_VERSION" = "unknown" ] || _semver_gt "$candidate_version" "$CODEX_CACHE_VERSION"; }; then
      CODEX_CACHE_VERSION="$candidate_version"
    fi
  done
  CODEX_VERSION="$CODEX_CACHE_VERSION"
fi

CODEX_CONFIG="$CODEX_HOME_ROOT/config.toml"
if [ -f "$CODEX_CONFIG" ]; then
  CODEX_MARKETPLACE_REF="$(
    awk '
      /^\[marketplaces\.skills\][[:space:]]*$/ { in_skills = 1; next }
      /^\[/ { in_skills = 0 }
      in_skills && /^[[:space:]]*ref[[:space:]]*=/ {
        value = $0
        sub(/^[^=]*=[[:space:]]*/, "", value)
        gsub(/["[:space:]]/, "", value)
        print value
        exit
      }
    ' "$CODEX_CONFIG"
  )"
  [ -n "$CODEX_MARKETPLACE_REF" ] || CODEX_MARKETPLACE_REF="unknown"
fi

if [ -n "$REMOTE" ]; then
  remote_target="$REMOTE"
  repository_url=""
  if [ -f "$PLUGIN_JSON" ] && command -v jq >/dev/null 2>&1; then
    repository_url="$(jq -r '.repository // empty' "$PLUGIN_JSON")"
  fi
  case "$remote_target" in
    *://* | git@*) ;;
    *)
      configured_remote="$(git remote get-url "$remote_target" 2>/dev/null || true)"
      if [ -n "$configured_remote" ] && printf '%s\n' "$configured_remote" | grep -q 'malinskibeniamin/skills'; then
        remote_target="$configured_remote"
      elif [ -n "$repository_url" ]; then
        # This script is normally run from a consumer repository. Its `origin`
        # is unrelated and must never decide the frontend-skills latest tag.
        remote_target="$repository_url"
      fi
      ;;
  esac
  if ! git ls-remote --refs --tags "$remote_target" 'v*' >/dev/null 2>&1 &&
    [ -n "$repository_url" ]; then
    remote_target="$repository_url"
  fi
  while IFS= read -r tag; do
    _consider_latest "$tag"
  done < <(
    git ls-remote --refs --tags "$remote_target" 'v*' 2>/dev/null |
      sed 's#.*refs/tags/##' || true
  )
fi

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Plugin Freshness ---"

if [ "$LATEST_VERSION" = "unknown" ]; then
  _warn "Could not determine the latest frontend-skills marketplace version"
else
  _pass "Latest available version: $LATEST_VERSION"
  if _semver_valid "$CLAUDE_VERSION" && _semver_gt "$LATEST_VERSION" "$CLAUDE_VERSION"; then
    _warn "Claude plugin $CLAUDE_VERSION is behind $LATEST_VERSION"
  elif _semver_valid "$CLAUDE_VERSION"; then
    _pass "Claude plugin is current ($CLAUDE_VERSION)"
  else
    _warn "Could not determine the installed Claude plugin version"
  fi

  if _semver_valid "$CODEX_VERSION" && _semver_gt "$LATEST_VERSION" "$CODEX_VERSION"; then
    _warn "Codex plugin $CODEX_VERSION is behind $LATEST_VERSION"
  elif _semver_valid "$CODEX_VERSION"; then
    _pass "Codex plugin is current ($CODEX_VERSION)"
  else
    _warn "Could not determine the installed Codex plugin version"
  fi

  codex_ref_version="${CODEX_MARKETPLACE_REF#v}"
  if _semver_valid "$codex_ref_version" && _semver_gt "$LATEST_VERSION" "$codex_ref_version"; then
    _warn "Codex marketplace ref $CODEX_MARKETPLACE_REF is behind v$LATEST_VERSION"
  elif _semver_valid "$codex_ref_version"; then
    _pass "Codex marketplace ref is current ($CODEX_MARKETPLACE_REF)"
  else
    _warn "Could not determine the Codex marketplace ref"
  fi
fi

# ── 2. Basic structure ──────────────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Structure ---"

if [ "$INSTALL_MODE" = "plugin" ]; then
  _pass "Plugin installed at $PLUGIN_ROOT"

  if [ -f "${PLUGIN_ROOT}hooks/hooks.json" ]; then
    _pass "hooks/hooks.json exists (plugin hook wiring)"
  else
    _fail "hooks/hooks.json missing — plugin hooks not wired"
  fi

  if [ -d "${PLUGIN_ROOT}.claude/hooks" ]; then
    _pass "Plugin .claude/hooks/ directory exists"
  else
    _fail "Plugin .claude/hooks/ directory missing"
  fi

  hook_lib="${PLUGIN_ROOT}.claude/hooks/_hook-lib.sh"
  if [ -f "$hook_lib" ] || [ -L "$hook_lib" ]; then
    _pass "_hook-lib.sh present in plugin"
  else
    _fail "_hook-lib.sh missing in plugin — all hooks will fail"
  fi

  shared_lib="${PLUGIN_ROOT}shared/hook-lib.sh"
  if [ -f "$shared_lib" ]; then
    _pass "shared/hook-lib.sh present in plugin"
  else
    _fail "shared/hook-lib.sh missing in plugin — all hooks will fail"
  fi
else
  if [ -d ".claude/hooks" ]; then
    _pass ".claude/hooks/ directory exists"
  else
    _fail ".claude/hooks/ directory missing"
  fi

  if [ -f ".claude/settings.json" ]; then
    _pass ".claude/settings.json exists"
  else
    _fail ".claude/settings.json missing — no hooks configured"
  fi

  if [ -f ".claude/hooks/_hook-lib.sh" ]; then
    _pass "_hook-lib.sh shared library present"
    if [ -x ".claude/hooks/_hook-lib.sh" ] || [ -L ".claude/hooks/_hook-lib.sh" ]; then
      _pass "_hook-lib.sh is executable or symlinked"
    else
      _fail "_hook-lib.sh exists but is not executable"
    fi
  else
    _fail "_hook-lib.sh missing — all hooks will fail"
  fi
fi

# ── 3. Hook scripts ────────────────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Hook Scripts ---"

# Auto-discover expected hooks from hooks.json instead of hardcoding
# This prevents the list from going stale when hooks are added/removed
if [ "$INSTALL_MODE" = "plugin" ]; then
  _hooks_json="${PLUGIN_ROOT}hooks/hooks.json"
else
  _hooks_json=".claude/hooks.json"
  [ -f "$_hooks_json" ] || _hooks_json="hooks/hooks.json"
fi

EXPECTED_HOOKS=()
if [ -f "$_hooks_json" ] && command -v jq &>/dev/null; then
  while IFS= read -r hook; do
    EXPECTED_HOOKS+=("$hook")
  done < <(jq -r '.. | .command? // empty' "$_hooks_json" | grep -oE '[^/]+\.sh' | sort -u)
fi

# Fallback if hooks.json not found or jq missing — keep in sync with hooks/hooks.json
if [ ${#EXPECTED_HOOKS[@]} -eq 0 ]; then
  _warn "Could not auto-discover hooks from hooks.json — using hardcoded fallback (may be stale)"
  EXPECTED_HOOKS=(
    "react-rules-check.sh"
    "tailwind-check.sh"
    "accessibility-check.sh"
    "zustand-check.sh"
    "tanstack-router-check.sh"
    "connect-query-check.sh"
    "test-perf-check.sh"
    "ux-copy-check.sh"
    "enforce-toolchain.sh"
    "biome-autofix.sh"
    "typecheck-stop.sh"
    "lifecycle-stop.sh"
    "session-env.sh"
    "intent-detect.sh"
    "vendor-file-check.sh"
    "ui-registry-warn.sh"
    "form-mode-check.sh"
    "file-size-check.sh"
    "hook-location-check.sh"
    "mutation-side-effect-check.sh"
    "connect-error-check.sh"
    "unhappy-path-check.sh"
    "tdd-prompt-check.sh"
    "error-boundary-check.sh"
    "field-mask-check.sh"
    "legacy-linter-check.sh"
    "form-watch-check.sh"
    "biome-ignore-check.sh"
    "as-cast-check.sh"
    "mutation-naming-check.sh"
    "disabled-button-tooltip-check.sh"
    "test-convention-check.sh"
    "mutation-onerror-check.sh"
    "edit-loop-check.sh"
    "query-pattern-check.sh"
    "consecutive-failure-check.sh"
    "orchestration-guidance.sh"
    "orchestration-stop.sh"
    "quality-gate-stop.sh"
    "violation-summary-stop.sh"
    "violation-nudge.sh"
    "architecture-review-stop.sh"
    "react-doctor-stop.sh"
    "registry-check.sh"
    "test-perf-stop.sh"
    "llm-truncate.sh"
    "llm-test-flags.sh"
    "conventional-commits-check.sh"
    "user-prompt-context.sh"
    "post-compact-context.sh"
    "subagent-start.sh"
    "subagent-stop.sh"
    "llm-env.sh"
  )
fi

# Determine where to look for hook scripts
if [ "$INSTALL_MODE" = "plugin" ]; then
  HOOKS_DIR="${PLUGIN_ROOT}.claude/hooks"
else
  HOOKS_DIR=".claude/hooks"
fi

installed=0
missing=0
for hook in "${EXPECTED_HOOKS[@]}"; do
  if [ -f "$HOOKS_DIR/$hook" ] || [ -L "$HOOKS_DIR/$hook" ]; then
    if [ -x "$HOOKS_DIR/$hook" ] || [ -L "$HOOKS_DIR/$hook" ]; then
      installed=$((installed + 1))
    else
      _fail "$hook exists but is not executable"
      missing=$((missing + 1))
    fi
  else
    _warn "$hook not installed"
    missing=$((missing + 1))
  fi
done

if [ $missing -eq 0 ]; then
  _pass "All $installed hook scripts installed and executable"
else
  _warn "$installed of ${#EXPECTED_HOOKS[@]} hooks installed ($missing missing)"
fi

# ── 4. Hook wiring ─────────────────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Hook Wiring ---"

# All 8 hook events used by the harness
HOOK_EVENTS=("SessionStart" "PostCompact" "UserPromptSubmit" "PreToolUse" "PostToolUse" "SubagentStart" "SubagentStop" "Stop")

if [ "$INSTALL_MODE" = "plugin" ]; then
  # Plugin mode: check hooks/hooks.json
  hooks_file="${PLUGIN_ROOT}hooks/hooks.json"

  if grep -q 'CLAUDE_PLUGIN_ROOT' "$hooks_file" 2>/dev/null; then
    _pass "Hook paths use \${CLAUDE_PLUGIN_ROOT} (plugin-portable)"
  else
    _warn "Hook paths don't use \${CLAUDE_PLUGIN_ROOT} — may not resolve correctly"
  fi

  hook_count=$(grep -c '"command"' "$hooks_file" 2>/dev/null || echo "0")
  if [ "$hook_count" -gt 0 ]; then
    _pass "$hook_count hooks configured in hooks.json"
  else
    _fail "No hooks configured in hooks.json"
  fi

  for event in "${HOOK_EVENTS[@]}"; do
    if grep -q "\"$event\"" "$hooks_file" 2>/dev/null; then
      _pass "$event event configured"
    else
      _warn "$event event not configured"
    fi
  done
else
  # Manual mode: check .claude/settings.json
  if [ -f ".claude/settings.json" ]; then
    if grep -q 'git rev-parse --show-toplevel' ".claude/settings.json" 2>/dev/null; then
      _pass "Hook paths use git root resolution (portable)"
    elif grep -q '\.claude/hooks/' ".claude/settings.json" 2>/dev/null; then
      _warn "Hook paths use relative paths — may break from subdirectories. Update to git root resolution pattern."
    fi

    hook_count=$(grep -c '"command"' ".claude/settings.json" 2>/dev/null || echo "0")
    if [ "$hook_count" -gt 0 ]; then
      _pass "$hook_count hooks configured in settings.json"
    else
      _fail "No hooks configured in settings.json"
    fi

    for event in "${HOOK_EVENTS[@]}"; do
      if grep -q "\"$event\"" ".claude/settings.json" 2>/dev/null; then
        _pass "$event event configured"
      else
        _warn "$event event not configured"
      fi
    done
  fi
fi

# ── 5. Assets ──────────────────────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Assets ---"

if [ "$INSTALL_MODE" = "plugin" ]; then
  ASSETS_ROOT="$PLUGIN_ROOT"
else
  ASSETS_ROOT="."
fi

# Skills (count directories with SKILL.md)
skill_count=$(find "${ASSETS_ROOT}" -maxdepth 2 -name "SKILL.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$skill_count" -gt 0 ]; then
  _pass "$skill_count skills installed"
else
  _fail "No skills found (no SKILL.md files)"
fi

# Commands
cmd_count=0
for cmd_dir in "${ASSETS_ROOT}/.claude/commands" "${ASSETS_ROOT}/commands"; do
  if [ -d "$cmd_dir" ]; then
    cmd_count=$(find "$cmd_dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    break
  fi
done
if [ "$cmd_count" -gt 0 ]; then
  _pass "$cmd_count slash commands installed"
else
  _warn "No slash commands found"
fi

# Agents
agent_count=0
if [ -d "${ASSETS_ROOT}/agents" ]; then
  agent_count=$(find "${ASSETS_ROOT}/agents" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi
if [ "$agent_count" -gt 0 ]; then
  _pass "$agent_count agent definitions installed"
else
  _warn "No agent definitions found"
fi

# Routines
routine_count=0
routine_dir="${ASSETS_ROOT}/setup-routines/routines"
if [ -d "$routine_dir" ]; then
  routine_count=$(find "$routine_dir" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
fi
if [ "$routine_count" -gt 0 ]; then
  _pass "$routine_count routine templates installed"
else
  _warn "No routine templates found"
fi

# Shared utilities
shared_count=0
if [ -d "${ASSETS_ROOT}/shared" ]; then
  shared_count=$(find "${ASSETS_ROOT}/shared" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
fi
if [ "$shared_count" -gt 0 ]; then
  _pass "$shared_count shared utilities installed"
else
  _warn "No shared utilities found"
fi

# Reference docs
ref_count=$(find "${ASSETS_ROOT}" -maxdepth 2 -name "REFERENCE.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$ref_count" -gt 0 ]; then
  _pass "$ref_count reference docs installed"
else
  _warn "No reference docs found"
fi

# Instructions
for instr in "CLAUDE.md" "AGENTS.md"; do
  if [ -f "${ASSETS_ROOT}/${instr}" ]; then
    _pass "$instr present"
  else
    _warn "$instr not found"
  fi
done

# ── 6. Codex compatibility (optional) ──────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Codex Compatibility ---"

if [ "$INSTALL_MODE" = "plugin" ]; then
  CODEX_ROOT="$PLUGIN_ROOT"
else
  CODEX_ROOT="."
fi

if [ -f "${CODEX_ROOT}/.codex/hooks.json" ]; then
  _pass ".codex/hooks.json exists"
  if [ -f "${CODEX_ROOT}/.codex/hooks/codex-batch-check.sh" ] || [ -L "${CODEX_ROOT}/.codex/hooks/codex-batch-check.sh" ]; then
    _pass "codex-batch-check.sh installed"
  else
    _warn "codex-batch-check.sh missing — Codex Stop hook won't run Edit|Write checks"
  fi
  # Hooks are gated twice on Codex: the [features] hooks flag AND hash trust.
  # A missing flag makes every hook a silent no-op — the worst failure mode.
  _codex_flag_found=0
  for _cfg in "${CODEX_ROOT}/.codex/config.toml" "$HOME/.codex/config.toml"; do
    if [ -f "$_cfg" ] && grep -qE '^[[:space:]]*hooks[[:space:]]*=[[:space:]]*true' "$_cfg" 2>/dev/null; then
      _codex_flag_found=1
      break
    fi
  done
  if [ "$_codex_flag_found" = "1" ]; then
    _pass "Codex hooks feature flag enabled in config.toml"
  else
    _warn "Codex hooks feature flag not found — set [features] hooks = true in config.toml, then trust definitions via /hooks (hooks silently no-op otherwise)"
  fi
  if [ -f "${CODEX_ROOT}/.codex/rules/frontend-skills.rules" ]; then
    _pass "execpolicy rules installed (.codex/rules/frontend-skills.rules)"
  else
    _warn ".codex/rules/frontend-skills.rules missing — toolchain bans have no deterministic floor when Codex hooks are off"
  fi
else
  _warn ".codex/hooks.json not found — Codex hooks not configured (install codex-compat skill)"
fi

if [ -f "${CODEX_ROOT}/AGENTS.md" ]; then
  _pass "AGENTS.md exists"
else
  _warn "AGENTS.md not found — Codex soft guidance not configured"
fi

if [ -f "${CODEX_ROOT}/.codex-plugin/plugin.json" ]; then
  _pass ".codex-plugin/plugin.json exists"
else
  _warn ".codex-plugin/plugin.json not found"
fi

# ── 7. Dependencies ─────────────────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Dependencies ---"

if command -v jq &>/dev/null; then
  _pass "jq available (required by hook-lib.sh)"
else
  _fail "jq not installed — hooks will fail. Install: brew install jq"
fi

if command -v bun &>/dev/null; then
  _pass "bun available"
else
  _warn "bun not found — toolchain hooks expect bun as package manager"
fi

if command -v tracedecay &>/dev/null; then
  _pass "TraceDecay available (optional semantic graph)"
else
  _tracedecay_agent="codex"
  if ! command -v codex &>/dev/null && command -v claude &>/dev/null; then
    _tracedecay_agent="claude"
  fi
  _warn "TraceDecay not found — optional semantic graph. Run: bash \"$SCRIPT_DIR/setup-tracedecay.sh\" --agent $_tracedecay_agent --project \"$PWD\""
fi

if [ -f "package.json" ]; then
  _pass "package.json found (frontend project)"
  if grep -q '"react"' package.json 2>/dev/null; then
    _pass "React dependency found"
  else
    _warn "No React dependency — some hooks may not be relevant"
  fi
else
  _warn "No package.json — hooks are designed for frontend projects"
fi

# ── Summary ─────────────────────────────────────────────────────

$JSON_MODE || echo ""

if $JSON_MODE; then
  jq -cn \
    --argjson pass "$PASS" \
    --argjson warn "$WARN" \
    --argjson fail "$FAIL" \
    --arg version "${_version:-unknown}" \
    --arg updatedAt "${_updated:-unknown}" \
    --arg claudeVersion "$CLAUDE_VERSION" \
    --arg codexVersion "$CODEX_VERSION" \
    --arg latestVersion "$LATEST_VERSION" \
    --arg codexMarketplaceRef "$CODEX_MARKETPLACE_REF" \
    '{
      pass: $pass,
      warn: $warn,
      fail: $fail,
      version: $version,
      updatedAt: $updatedAt,
      claudeVersion: $claudeVersion,
      codexVersion: $codexVersion,
      latestVersion: $latestVersion,
      codexMarketplaceRef: $codexMarketplaceRef
    }'
else
  echo "=== Summary: $PASS passed, $WARN warnings, $FAIL failures ==="
  if [ $FAIL -gt 0 ]; then
    echo ""
    echo "Failures require action — hooks may not work correctly."
  elif [ $WARN -gt 0 ]; then
    echo ""
    echo "Warnings are non-critical but may affect coverage."
  else
    echo ""
    echo "All checks passed. Installation is healthy."
  fi
fi

[ $FAIL -eq 0 ]
