#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

# Only check TS/TSX/JS/JSX files
case "$file_path" in
  *.ts|*.tsx|*.js|*.jsx) ;;
  *) exit 0 ;;
esac

# Skip test files
case "$file_path" in
  *.test.*|*.spec.*) exit 0 ;;
esac
if echo "$file_path" | grep -qE '/__tests__/'; then
  exit 0
fi

# Get added lines from diff
diff_output=""
diff_output=$(git diff HEAD -- "$file_path" 2>/dev/null) || true

if [ -z "$diff_output" ]; then
  added_lines=$(cat "$file_path")
else
  added_lines=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
fi

if [ -z "$added_lines" ]; then
  exit 0
fi

# ── Check 1: Ban console.error() ─────────────────────────────────
if echo "$added_lines" | grep -qE 'console\.error\('; then
  echo '{"suppressOutput":true,"systemMessage":"console.error() is banned in production code. Use the structured logger instead:\n\n// BAD\nconsole.error(\"Something failed\", err)\n\n// GOOD\nimport { logger } from \"@/lib/logger\"\nlogger.error({ message: \"Something failed\", error: err })\n\nStructured logs are machine-parseable and work with log aggregators (Axiom, Datadog, etc)."}' >&2
  exit 2
fi

# ── Check 2: Ban console.warn() ──────────────────────────────────
if echo "$added_lines" | grep -qE 'console\.warn\('; then
  echo '{"suppressOutput":true,"systemMessage":"console.warn() is banned in production code. Use the structured logger instead:\n\n// BAD\nconsole.warn(\"Deprecated feature used\")\n\n// GOOD\nimport { logger } from \"@/lib/logger\"\nlogger.warn({ message: \"Deprecated feature used\", feature: \"oldApi\" })"}' >&2
  exit 2
fi

# ── Check 3: Ban console.debug() ─────────────────────────────────
if echo "$added_lines" | grep -qE 'console\.debug\('; then
  echo '{"suppressOutput":true,"systemMessage":"console.debug() is banned in production code. Use the structured logger instead:\n\n// BAD\nconsole.debug(\"Processing item\", item)\n\n// GOOD\nimport { logger } from \"@/lib/logger\"\nlogger.debug({ message: \"Processing item\", itemId: item.id })"}' >&2
  exit 2
fi

# ── Check 4: Ban string concatenation in logger calls ────────────
if echo "$added_lines" | grep -qE 'logger\.(error|warn|info|debug|fatal|trace)\([^)]*"[^"]*"\s*\+' || \
   echo "$added_lines" | grep -qE "logger\.(error|warn|info|debug|fatal|trace)\([^)]*'[^']*'\s*\+" || \
   echo "$added_lines" | grep -qE 'logger\.(error|warn|info|debug|fatal|trace)\([^)]*`[^`]*\$\{'; then
  echo '{"suppressOutput":true,"systemMessage":"Do not use string concatenation or template literals in logger calls. Pass a structured object instead:\n\n// BAD\nlogger.error(\"Failed to process: \" + err.message)\nlogger.error(`Failed to process: ${err.message}`)\n\n// GOOD\nlogger.error({ message: \"Failed to process\", error: err })\n\nStructured fields are searchable and filterable in log aggregators."}' >&2
  exit 2
fi

exit 0
