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

modified=false
rewritten="$command"

# ── Vitest / bun test optimization ──────────────────────────────

if echo "$rewritten" | grep -qE '(vitest|bun (test|run test\S*))'; then

  # Strip --verbose (wastes tokens)
  if echo "$rewritten" | grep -qE '\-\-verbose'; then
    rewritten=$(echo "$rewritten" | sed -E 's/[[:space:]]+--verbose//g; s/--verbose[[:space:]]+//g; s/--verbose$//g')
    modified=true
  fi

  # Inject --pool=forks if no --pool specified (prevents zombie processes)
  if ! echo "$rewritten" | grep -qE '\-\-pool[= ]'; then
    rewritten="$rewritten --pool=forks"
    modified=true
  fi

  # Inject --bail=1 if no --bail specified (fail fast, save tokens)
  if ! echo "$rewritten" | grep -qE '\-\-bail[= ]'; then
    rewritten="$rewritten --bail=1"
    modified=true
  fi

  # Inject --teardownTimeout if not specified (prevent hanging teardown → zombies)
  if ! echo "$rewritten" | grep -qE '\-\-teardownTimeout[= ]'; then
    rewritten="$rewritten --teardownTimeout=5000"
    modified=true
  fi

  # Inject reporter: github in CI, leave default otherwise
  if ! echo "$rewritten" | grep -qE '\-\-reporter[= ]'; then
    if [ "${CI:-}" = "true" ]; then
      rewritten="$rewritten --reporter=github"
      modified=true
    fi
  fi
fi

# ── Jest optimization ───────────────────────────────────────────

if echo "$rewritten" | grep -qE '\bjest\b'; then

  # Strip --verbose
  if echo "$rewritten" | grep -qE '\-\-verbose'; then
    rewritten=$(echo "$rewritten" | sed -E 's/[[:space:]]+--verbose//g; s/--verbose[[:space:]]+//g; s/--verbose$//g')
    modified=true
  fi

  # Inject --bail if not specified
  if ! echo "$rewritten" | grep -qE '\-\-bail'; then
    rewritten="$rewritten --bail"
    modified=true
  fi

  # Inject --forceExit to prevent zombie processes
  if ! echo "$rewritten" | grep -qE '\-\-forceExit'; then
    rewritten="$rewritten --forceExit"
    modified=true
  fi
fi

# ── Apply rewrite via updatedInput ──────────────────────────────

if [ "$modified" = true ]; then
  updated_input=$(echo "$input" | jq --arg cmd "$rewritten" '.tool_input | .command = $cmd')
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"permissionDecision\":\"allow\",\"updatedInput\":$updated_input}}" >&2
  exit 0
fi

exit 0
