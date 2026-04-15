#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_generated
hook_skip_tests
hook_get_added_lines

# ── Skip config/build files ──────────────────────────────────────
case "$file_path" in
  *.config.*|*.setup.*|*scripts/*|*cli/*|*bin/*) exit 0 ;;
esac

# ── Check: console.log/error/warn in source files ────────────────
# Biome noConsole rule catches this too, but this hook provides
# immediate feedback before Biome runs at Stop.

console_usage=$(echo "$added_lines" | grep -E 'console\.(log|error|warn|info|debug)\(' | grep -vE '//.*console\.|process\.env\.' || true)

if [ -n "$console_usage" ]; then
  sample=$(echo "$console_usage" | head -2 | sed 's/^+//' | tr '\n' ' ')
  if ! hook_has_escape "console-log"; then
    hook_warn "console.log in source file. Remove or gate behind NODE_ENV. Found: $sample. Escape: // allow: console-log [reason]" "console-log-source"
  fi
fi

exit 0
