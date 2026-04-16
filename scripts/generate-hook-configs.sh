#!/bin/bash
set -euo pipefail

# Generate hook configuration files from skill-manifest.json (single source of truth).
#
# Inputs:
#   skill-manifest.json  — events → matcher → [hook scripts]
#
# Outputs:
#   .claude/settings.json        — uses `git rev-parse --show-toplevel` path
#   hooks/hooks.json             — uses ${CLAUDE_PLUGIN_ROOT} path
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

# Build hook config from manifest using prefix string.
# jq auto-escapes embedded " → \" during JSON serialization.
_build() {
  local prefix="$1"
  jq --arg prefix "$prefix" '
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
                      command: ("f=" + $prefix + "/" + . + "; [ -x \"$f\" ] && exec \"$f\"; exit 0")
                    }))
                  }
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

NEW_SETTINGS=$(_build "$SETTINGS_PREFIX")

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

# Merge permissions from existing settings.json (hand-edited, not generated)
if [ -f ".claude/settings.json" ]; then
  _perms=$(jq '.permissions // empty' .claude/settings.json)
  if [ -n "$_perms" ] && [ "$_perms" != "null" ]; then
    NEW_SETTINGS=$(echo "$NEW_SETTINGS" | jq --argjson p "$_perms" '{permissions: $p, hooks}')
  fi
fi

case "$MODE" in
  check)
    _drift=0
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
    [ "$_drift" = "0" ] && echo "OK: both configs match manifest"
    exit $_drift
    ;;
  apply)
    echo "$NEW_SETTINGS" > .claude/settings.json
    echo "$NEW_PLUGIN" > hooks/hooks.json
    if ! jq empty .claude/settings.json 2>&1; then
      echo "ERROR: generated settings.json invalid" >&2
      exit 1
    fi
    if ! jq empty hooks/hooks.json 2>&1; then
      echo "ERROR: generated hooks.json invalid" >&2
      exit 1
    fi
    echo "Generated .claude/settings.json and hooks/hooks.json from $MANIFEST"
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
