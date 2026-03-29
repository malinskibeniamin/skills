#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_edit_write
hook_filter_extensions "ts|tsx|js|jsx"
hook_skip_tests
hook_get_added_lines

# ── Check 1: Ban console.error() ─────────────────────────────────
if echo "$added_lines" | grep -qE 'console\.error\('; then
  hook_block "console.error() is banned in production code. Use the structured logger instead:\n\n// BAD\nconsole.error(\\\"Something failed\\\", err)\n\n// GOOD\nimport { logger } from \\\"@/lib/logger\\\"\nlogger.error({ message: \\\"Something failed\\\", error: err })\n\nStructured logs are machine-parseable and work with log aggregators (Axiom, Datadog, etc)."
fi

# ── Check 2: Ban console.warn() ──────────────────────────────────
if echo "$added_lines" | grep -qE 'console\.warn\('; then
  hook_block "console.warn() is banned in production code. Use the structured logger instead:\n\n// BAD\nconsole.warn(\\\"Deprecated feature used\\\")\n\n// GOOD\nimport { logger } from \\\"@/lib/logger\\\"\nlogger.warn({ message: \\\"Deprecated feature used\\\", feature: \\\"oldApi\\\" })"
fi

# ── Check 3: Ban console.debug() ─────────────────────────────────
if echo "$added_lines" | grep -qE 'console\.debug\('; then
  hook_block "console.debug() is banned in production code. Use the structured logger instead:\n\n// BAD\nconsole.debug(\\\"Processing item\\\", item)\n\n// GOOD\nimport { logger } from \\\"@/lib/logger\\\"\nlogger.debug({ message: \\\"Processing item\\\", itemId: item.id })"
fi

# ── Check 4: Ban string concatenation in logger calls ────────────
if echo "$added_lines" | grep -qE 'logger\.(error|warn|info|debug|fatal|trace)\([^)]*"[^"]*"\s*\+' || \
   echo "$added_lines" | grep -qE "logger\.(error|warn|info|debug|fatal|trace)\([^)]*'[^']*'\s*\+" || \
   echo "$added_lines" | grep -qE 'logger\.(error|warn|info|debug|fatal|trace)\([^)]*`[^`]*\$\{'; then
  hook_block "Do not use string concatenation or template literals in logger calls. Pass a structured object instead:\n\n// BAD\nlogger.error(\\\"Failed to process: \\\" + err.message)\nlogger.error(\`Failed to process: \${err.message}\`)\n\n// GOOD\nlogger.error({ message: \\\"Failed to process\\\", error: err })\n\nStructured fields are searchable and filterable in log aggregators."
fi

exit 0
