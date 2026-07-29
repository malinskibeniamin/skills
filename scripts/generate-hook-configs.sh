#!/bin/bash
set -euo pipefail

# Generate hook configuration files from skill-manifest.json (single source of truth).
#
# Inputs:
#   skill-manifest.json  — events → matcher → [hook entries]
#                          entry = "script.sh" or {script, if, async,
#                          asyncRewake, statusMessage, timeout}. The object
#                          fields are Claude-only hook capabilities; Codex
#                          output keeps the bare command (script-side guards
#                          cover the `if` semantics there).
#   hooks/frontend-skills.rules — Codex execpolicy mirror of the
#                          enforce-toolchain deny list (hand-maintained).
#
# Outputs:
#   .claude/settings.json        — Claude-compatible full hook surface, repo-local paths
#   hooks/hooks.json             — Claude-compatible full hook surface, plugin-root paths
#   .codex/hooks.json            — Codex-supported hook events only, repo-local paths
#                                  (best-effort; some managed sandboxes mount
#                                  .codex read-only)
#   .codex/rules/frontend-skills.rules — execpolicy copy (same writability caveat)
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

# Shared jq prelude: normalize a manifest entry (string or object) and emit
# the Claude-only extra fields. `-c` (NOT `-lc`): a login shell sources the
# user's profile on EVERY hook spawn — measured milliseconds × ~30 hooks per
# tool batch for zero benefit; hooks inherit the session environment already.
JQ_CLAUDE_PRELUDE='
  def norm($e): if ($e|type) == "object" then $e else {script: $e} end;
  def extra_fields($e):
    ({}
     + (if $e.if then {if: $e.if} else {} end)
     + (if $e.async then {async: true} else {} end)
     + (if $e.asyncRewake then {asyncRewake: true} else {} end)
     + (if $e.statusMessage then {statusMessage: $e.statusMessage} else {} end)
     + (if $e.timeout then {timeout: $e.timeout} else {} end));
'

# Build Claude settings using exec-form hooks. Use an absolute executable
# (`/bin/bash`) instead of a repo-relative command path because Claude may
# spawn hooks from a worktree subdirectory or from outside the repo. The small
# shell wrapper resolves the current git root first, then falls back to
# CLAUDE_PROJECT_DIR. This prevents posix_spawn ENOENT before run-hook.sh can
# locate the repo-local hook implementation.
_build_claude_settings() {
  jq "$JQ_CLAUDE_PRELUDE"'
    def claude_hook($entry):
      norm($entry) as $e
      | {
          type: "command",
          command: "/bin/bash",
          args: [
            "-c",
            ("root=$(git rev-parse --show-toplevel 2>/dev/null || printf %s \"${CLAUDE_PROJECT_DIR:-}\"); [ -n \"$root\" ] && exec \"$root/.claude/hooks/run-hook.sh\" " + ($e.script | @sh) + "; exit 0")
          ]
        } + extra_fields($e);
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
#   SessionEnd (no lifecycle analog; the `notify` turn-complete adapter in
#   codex-compat covers the metrics summary), Setup, UserPromptExpansion,
#   CwdChanged, ConfigChange, TaskCompleted, StopFailure, PermissionDenied,
#   Notification.
# Object-entry extras (if/async/statusMessage/timeout) are stripped: Codex
# parses only command hooks, and each script self-guards on its stdin.
CODEX_EVENTS='["SessionStart","SubagentStart","PreToolUse","PostToolUse","PreCompact","PostCompact","UserPromptSubmit","SubagentStop","Stop"]'
_build_codex() {
  local prefix="$1"
  local close_quote="${2:-}"
  jq --arg prefix "$prefix" --arg close "$close_quote" --argjson events "$CODEX_EVENTS" '
    def entry_script($e): if ($e|type) == "object" then $e.script else $e end;
    def command_hook($entry): {
      type: "command",
      command: ("f=" + $prefix + "/" + entry_script($entry) + $close + "; [ -x \"$f\" ] && exec \"$f\"; exit 0")
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
    # Codex has no PostToolBatch event. One adapter turns each edit call into
    # the batch protocol, keeping all checks inside a single process.
    | if (($root["x-codex-edit-dispatch"] // "") | length) > 0 then
        .hooks.PostToolUse = ([
          {
            matcher: "Edit|Write|apply_patch",
            hooks: [command_hook($root["x-codex-edit-dispatch"])]
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

# For plugin, rebuild with matching-quote prefix. Same entry normalization
# and Claude-only extra fields as settings — hooks/hooks.json is the Claude
# plugin surface.
NEW_PLUGIN=$(jq --arg prefix '"${CLAUDE_PLUGIN_ROOT}/.claude/hooks' "$JQ_CLAUDE_PRELUDE"'
  def plugin_hook($entry):
    norm($entry) as $e
    | {
        type: "command",
        command: ("f=" + $prefix + "/" + $e.script + "\"; [ -x \"$f\" ] && exec \"$f\"; exit 0")
      } + extra_fields($e);
  {
    hooks: (
      .hooks | to_entries | map(
        .key as $event
        | {
            key: $event,
            value: (
              .value | to_entries | map(
                (if .key == "" then {} else {matcher: .key} end) + {
                  hooks: (.value | map(plugin_hook(.)))
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
      if [ -f ".codex/rules/frontend-skills.rules" ] && ! cmp -s hooks/frontend-skills.rules .codex/rules/frontend-skills.rules; then
        echo "DRIFT: .codex/rules/frontend-skills.rules ≠ hooks/frontend-skills.rules" >&2
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
      if mkdir -p .codex/rules 2>/dev/null && (: >> .codex/rules/frontend-skills.rules) 2>/dev/null; then
        cp hooks/frontend-skills.rules .codex/rules/frontend-skills.rules
      else
        echo "WARN: .codex/rules not writable; skipped execpolicy copy" >&2
      fi
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
    # Verify scripts exist. Object entries contribute their .script value;
    # the grep keeps only *.sh strings so if/statusMessage text never trips it.
    _missing=0
    while IFS= read -r script; do
      [ -z "$script" ] && continue
      if [ ! -f ".claude/hooks/$script" ]; then
        echo "WARN: .claude/hooks/$script not found on disk" >&2
        _missing=$((_missing + 1))
      fi
    done < <(jq -r '.hooks | .. | strings' "$MANIFEST" | grep -E '^[a-z0-9-]+\.sh$' | sort -u)
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
