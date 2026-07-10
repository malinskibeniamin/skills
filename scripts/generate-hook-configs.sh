#!/bin/bash
set -euo pipefail

# Generate hook configuration files from skill-manifest.json (single source of truth).
#
# Inputs:
#   skill-manifest.json  — events → matcher → [hook scripts]
#
# Outputs:
#   .claude/settings.json        — Claude-compatible full hook surface, repo-local paths
#   hooks/hooks.json             — Claude-compatible full hook surface, plugin-root paths
#   .codex/hooks.json            — Codex-supported hook events only, repo-local paths
#                                  (best-effort; some managed sandboxes mount
#                                  .codex read-only)
#   hooks/codex-hooks.json       — Codex-supported hook events only, plugin-root paths
#
# Flags:
#   --check    compare existing files to would-be generated; exit 1 if drift
#   --apply    write the generated files (default)
#
# Rationale: prevents drift bug (v<2.2.0) where settings.json and hooks.json
# diverged. Change manifest once, regenerate both. Verifies referenced scripts
# exist on disk.

MODE="${1:---apply}"
MODE="${MODE#--}"

ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$ROOT"

MANIFEST="skill-manifest.json"
[ -f "$MANIFEST" ] || { echo "ERROR: $MANIFEST not found" >&2; exit 1; }
command -v jq >/dev/null || { echo "ERROR: jq required" >&2; exit 1; }

_codex_local_writable() {
  [ -f ".codex/hooks.json" ] && (: >> .codex/hooks.json) 2>/dev/null
}

# Build Claude settings using exec-form hooks. Use an absolute executable
# (`/bin/bash`) instead of a repo-relative command path because Claude may
# spawn hooks from a worktree subdirectory or from outside the repo. The small
# shell wrapper resolves the current git root first, then falls back to
# CLAUDE_PROJECT_DIR. This prevents posix_spawn ENOENT before run-hook.sh can
# locate the repo-local hook implementation.
_build_claude_settings() {
  jq '
    def claude_hook($script): {
      type: "command",
      command: "/bin/bash",
      args: [
        "-lc",
        ("root=$(git rev-parse --show-toplevel 2>/dev/null || printf %s \"${CLAUDE_PROJECT_DIR:-}\"); [ -n \"$root\" ] && exec \"$root/.claude/hooks/run-hook.sh\" " + ($script | @sh) + "; exit 0")
      ]
    };
    {
      hooks: (
        .hooks | to_entries | map(
          .key as $event
          | {
              key: $event,
              value: (
                .value | to_entries | map(
                  (if .key == "" then {} else {matcher: .key} end)
                  + (if $event == "PostToolUse" then {continueOnBlock: true} else {} end)
                  + {hooks: (.value | map(claude_hook(.)))}
                )
              )
            }
        ) | from_entries
      )
    }
  ' "$MANIFEST"
}

SETTINGS_PREFIX='$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks'
PLUGIN_PREFIX='"${CLAUDE_PLUGIN_ROOT}/.claude/hooks'
# Hack: opening quote only; closing quote comes right before `; [ -x ...`
# We want: f="${CLAUDE_PLUGIN_ROOT}/.claude/hooks/X.sh"; [ -x ...
# Assembled string inside jq: "f=" + prefix + "/" + script + "; [ -x ..."
# Needs close-quote before the `;`. Use suffix via jq sub:

NEW_SETTINGS=$(_build_claude_settings)

# Codex supports a smaller lifecycle surface than Claude Code
# (https://developers.openai.com/codex/hooks): SessionStart, SubagentStart,
# PreToolUse, PermissionRequest, PostToolUse, PreCompact, PostCompact,
# UserPromptSubmit, SubagentStop, Stop. Generate a best-effort mapping:
# - every Codex-supported event maps directly,
# - Claude PostToolUseFailure maps to Codex PostToolUse (Codex includes failures),
# - Codex PermissionRequest gets an adapter that reuses approval-safe deny guards,
# - Claude-only events with no Codex equivalent are dropped by design:
#   FileChanged (codex-compat keeps Stop-batch fallback), WorktreeCreate,
#   SessionEnd (no lifecycle analog; metrics summary is Claude-side only).
CODEX_EVENTS='["SessionStart","SubagentStart","PreToolUse","PostToolUse","PreCompact","PostCompact","UserPromptSubmit","SubagentStop","Stop"]'
_build_codex() {
  local prefix="$1"
  local close_quote="${2:-}"
  jq --arg prefix "$prefix" --arg close "$close_quote" --argjson events "$CODEX_EVENTS" '
    def command_hook($script): {
      type: "command",
      command: ("f=" + $prefix + "/" + $script + $close + "; [ -x \"$f\" ] && exec \"$f\"; exit 0")
    };
    . as $root
    | def groups_for($event):
      ($root.hooks[$event] // {})
      | to_entries
      | map(
          (if .key == "" then {} else {matcher: .key} end) + {
            hooks: (.value | map(command_hook(.)))
          }
        );
    def supported_direct:
      $root.hooks
      | with_entries(select(.key as $event | $events | index($event)))
      | to_entries
      | map(.key as $event | {key: $event, value: groups_for($event)})
      | from_entries;

    {hooks: supported_direct}
    # Codex has no PostToolBatch event. Re-expand Claude batch-dispatched
    # per-edit checks back into the PostToolUse Edit|Write matcher so Codex
    # keeps the historical one-process-per-tool-call behavior.
    | if (($root["x-codex-per-call"] // []) | length) > 0 then
        .hooks.PostToolUse = ([
          {
            matcher: "Edit|Write|apply_patch",
            hooks: (($root["x-codex-per-call"] // []) | map(command_hook(.)))
          }
        ] + (.hooks.PostToolUse // []))
      else . end
    # Codex PostToolUse runs for failed Bash commands too, so preserve the
    # Claude failure categorizer by appending it to PostToolUse.
    | if ($root.hooks.PostToolUseFailure? // null) != null then
        .hooks.PostToolUse = ((.hooks.PostToolUse // []) + groups_for("PostToolUseFailure"))
      else . end
    # Codex-only event: run an adapter during approval prompts so approval-time
    # Bash/MCP requests still get the same hard-deny guardrails.
    | .hooks.PermissionRequest = [
        {
          matcher: "Bash|mcp__.*",
          hooks: [command_hook("codex-permission-request-guard.sh")]
        }
      ]
  ' "$MANIFEST"
}

NEW_CODEX_SETTINGS=$(_build_codex "$SETTINGS_PREFIX")

# For plugin, rebuild with matching-quote prefix:
NEW_PLUGIN=$(jq --arg prefix '"${CLAUDE_PLUGIN_ROOT}/.claude/hooks' '
  {
    hooks: (
      .hooks | to_entries | map(
        .key as $event
        | {
            key: $event,
            value: (
              .value | to_entries | map(
                (if .key == "" then {} else {matcher: .key} end) + {
                  hooks: (.value | map({
                    type: "command",
                    command: ("f=" + $prefix + "/" + . + "\"; [ -x \"$f\" ] && exec \"$f\"; exit 0")
                  }))
                }
              )
            )
          }
      ) | from_entries
    )
  }
' "$MANIFEST")

NEW_CODEX_PLUGIN=$(_build_codex '"${CLAUDE_PLUGIN_ROOT}/.claude/hooks' '"')

# Merge hand-edited Claude settings not sourced from the manifest.
if [ -f ".claude/settings.json" ]; then
  _perms=$(jq '.permissions // empty' .claude/settings.json)
  _skill_overrides=$(jq '.skillOverrides // empty' .claude/settings.json)
  if [ -n "$_perms" ] && [ "$_perms" != "null" ]; then
    NEW_SETTINGS=$(echo "$NEW_SETTINGS" | jq --argjson p "$_perms" '. + {permissions: $p}')
  fi
  if [ -n "$_skill_overrides" ] && [ "$_skill_overrides" != "null" ]; then
    NEW_SETTINGS=$(echo "$NEW_SETTINGS" | jq --argjson s "$_skill_overrides" '. + {skillOverrides: $s}')
  fi
fi

case "$MODE" in
  check)
    _drift=0
    # hook-lib mirror: the packager cannot follow symlinks, so .claude/hooks
    # carries a real-file copy of shared/hook-lib.sh; divergence fails open.
    if ! cmp -s shared/hook-lib.sh .claude/hooks/_hook-lib.sh; then
      echo "DRIFT: .claude/hooks/_hook-lib.sh diverged from shared/hook-lib.sh" >&2
      _drift=1
    fi
    _cur_settings=$(jq -S . .claude/settings.json 2>/dev/null || echo "{}")
    _new_settings_sorted=$(echo "$NEW_SETTINGS" | jq -S .)
    if ! diff <(echo "$_cur_settings") <(echo "$_new_settings_sorted") >/dev/null 2>&1; then
      echo "DRIFT: .claude/settings.json ≠ manifest" >&2
      _drift=1
    fi
    _cur_plugin=$(jq -S . hooks/hooks.json 2>/dev/null || echo "{}")
    _new_plugin_sorted=$(echo "$NEW_PLUGIN" | jq -S .)
    if ! diff <(echo "$_cur_plugin") <(echo "$_new_plugin_sorted") >/dev/null 2>&1; then
      echo "DRIFT: hooks/hooks.json ≠ manifest" >&2
      _drift=1
    fi
    if _codex_local_writable; then
      _cur_codex_settings=$(jq -S . .codex/hooks.json 2>/dev/null || echo "{}")
      _new_codex_settings_sorted=$(echo "$NEW_CODEX_SETTINGS" | jq -S .)
      if ! diff <(echo "$_cur_codex_settings") <(echo "$_new_codex_settings_sorted") >/dev/null 2>&1; then
        echo "DRIFT: .codex/hooks.json ≠ manifest Codex subset" >&2
        _drift=1
      fi
    fi
    _cur_codex_plugin=$(jq -S . hooks/codex-hooks.json 2>/dev/null || echo "{}")
    _new_codex_plugin_sorted=$(echo "$NEW_CODEX_PLUGIN" | jq -S .)
    if ! diff <(echo "$_cur_codex_plugin") <(echo "$_new_codex_plugin_sorted") >/dev/null 2>&1; then
      echo "DRIFT: hooks/codex-hooks.json ≠ manifest Codex subset" >&2
      _drift=1
    fi
    [ "$_drift" = "0" ] && echo "OK: both configs match manifest"
    exit $_drift
    ;;
  apply)
    mkdir -p .codex hooks
    cp shared/hook-lib.sh .claude/hooks/_hook-lib.sh && chmod +x .claude/hooks/_hook-lib.sh  # hook-lib mirror sync
    echo "$NEW_SETTINGS" > .claude/settings.json
    echo "$NEW_PLUGIN" > hooks/hooks.json
    if _codex_local_writable; then
      echo "$NEW_CODEX_SETTINGS" > .codex/hooks.json
    else
      echo "WARN: .codex/hooks.json not writable; skipped local Codex config" >&2
    fi
    echo "$NEW_CODEX_PLUGIN" > hooks/codex-hooks.json
    if ! jq empty .claude/settings.json 2>&1; then
      echo "ERROR: generated settings.json invalid" >&2
      exit 1
    fi
    if ! jq empty hooks/hooks.json 2>&1; then
      echo "ERROR: generated hooks/hooks.json invalid" >&2
      exit 1
    fi
    if _codex_local_writable; then
      if ! jq empty .codex/hooks.json 2>&1; then
        echo "ERROR: generated .codex/hooks.json invalid" >&2
        exit 1
      fi
    fi
    if ! jq empty hooks/codex-hooks.json 2>&1; then
      echo "ERROR: generated hooks/codex-hooks.json invalid" >&2
      exit 1
    fi
    echo "Generated .claude/settings.json, hooks/hooks.json, .codex/hooks.json, and hooks/codex-hooks.json from $MANIFEST"
    # Verify scripts exist
    _missing=0
    while IFS= read -r script; do
      [ -z "$script" ] && continue
      if [ ! -f ".claude/hooks/$script" ]; then
        echo "WARN: .claude/hooks/$script not found on disk" >&2
        _missing=$((_missing + 1))
      fi
    done < <(jq -r '.hooks | .. | .[]? | select(type=="string")' "$MANIFEST" | grep -E '\.sh$' | sort -u)
    if [ "$_missing" -gt 0 ]; then
      echo "WARN: $_missing scripts missing" >&2
      exit 1
    fi
    ;;
  *)
    echo "Usage: $0 [--apply|--check]" >&2
    exit 1
    ;;
esac
