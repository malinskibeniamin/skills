#!/bin/bash
set -euo pipefail

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Bash" ]; then
  exit 0
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

suggestions=""
rewritten="$command"
must_rewrite=false

# ── Vitest / bun test optimization ──────────────────────────────

if echo "$rewritten" | grep -qE '(vitest|bun (test|run test\S*))'; then

  # Strip --verbose (hard enforcement — wastes tokens)
  if echo "$rewritten" | grep -qE '\-\-verbose'; then
    rewritten=$(echo "$rewritten" | sed -E 's/[[:space:]]+--verbose//g; s/--verbose[[:space:]]+//g; s/--verbose$//g')
    must_rewrite=true
  fi

  # Suggest --pool=forks if no --pool specified
  if ! echo "$rewritten" | grep -qE '\-\-pool[= ]'; then
    suggestions="$suggestions\n- Add --pool=forks to prevent zombie processes (each test file gets its own process)"
  fi

  # Suggest --bail=1 if no --bail specified
  if ! echo "$rewritten" | grep -qE '\-\-bail[= ]'; then
    suggestions="$suggestions\n- Add --bail=1 to fail fast and save tokens"
  fi

  # Suggest --teardownTimeout if not specified
  if ! echo "$rewritten" | grep -qE '\-\-teardownTimeout[= ]'; then
    suggestions="$suggestions\n- Add --teardownTimeout=5000 to prevent hanging teardown (zombie source)"
  fi

  # Suggest reporter in CI
  if ! echo "$rewritten" | grep -qE '\-\-reporter[= ]'; then
    if [ "${CI:-}" = "true" ]; then
      suggestions="$suggestions\n- Add --reporter=github for inline PR annotations"
    fi
  fi
fi

# ── Jest optimization ───────────────────────────────────────────

if echo "$rewritten" | grep -qE '\bjest\b'; then

  # Strip --verbose (hard enforcement)
  if echo "$rewritten" | grep -qE '\-\-verbose'; then
    rewritten=$(echo "$rewritten" | sed -E 's/[[:space:]]+--verbose//g; s/--verbose[[:space:]]+//g; s/--verbose$//g')
    must_rewrite=true
  fi

  # Suggest --bail if not specified
  if ! echo "$rewritten" | grep -qE '\-\-bail'; then
    suggestions="$suggestions\n- Add --bail to fail fast"
  fi

  # Suggest --forceExit if not specified
  if ! echo "$rewritten" | grep -qE '\-\-forceExit'; then
    suggestions="$suggestions\n- Add --forceExit to prevent zombie processes from open handles"
  fi
fi

# ── Apply ────────────────────────────────────────────────────────

# If --verbose was stripped, rewrite the command
if [ "$must_rewrite" = true ]; then
  updated_input=$(echo "$input" | jq --arg cmd "$rewritten" '.tool_input | .command = $cmd')
  if [ -n "$suggestions" ]; then
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"updatedInput\":$updated_input,\"additionalContext\":\"Test runner suggestions (optional):$suggestions\"}}" >&2
  else
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"updatedInput\":$updated_input}}" >&2
  fi
  exit 0
fi

# If only suggestions (no rewrite needed), pass them as context
if [ -n "$suggestions" ]; then
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"additionalContext\":\"Test runner suggestions (optional):$suggestions\"}}" >&2
  exit 0
fi

exit 0
