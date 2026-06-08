#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx|mts|cts"
hook_skip_generated
hook_get_added_lines

# ── Check: Block all new biome-ignore comments ───────────────────
# No lint suppression. Generated files are skipped above. Everything else
# must fix the lint/style/type issue at source; every ignore pattern gets
# copied by LLMs and becomes normalized debt.
#
# @ts-ignore/@ts-expect-error are owned by as-cast-check.sh.

ignore_lines=$(echo "$added_lines" | grep -E 'biome-ignore' || true)

if [ -n "$ignore_lines" ]; then
  sample=$(echo "$ignore_lines" | head -2 | sed 's/^+//' | tr '\n' ' ')
  if echo "$ignore_lines" | grep -qE 'noExplicitAny'; then
    hook_block "No lint suppression. biome-ignore noExplicitAny is banned; fix types with type guards, generics, or schema validation. Found: $sample" "biome-ignore"
  fi
  hook_block "No lint suppression. Every biome-ignore gets copied by LLMs; fix the lint/style issue at source. Found: $sample" "biome-ignore"
fi

exit 0
