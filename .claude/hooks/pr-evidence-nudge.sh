#!/bin/bash
set -euo pipefail

# Advisory routing, not a shell parser or proof that visual evidence is complete.
# Successful-hook context must be in stdout JSON, not debug-only stderr.
command=$(jq -r '.tool_input.command // empty' | tr -d "\\\\\"'")
if printf '%s' "$command" | grep -qE '(^|[[:space:];|&/])(gh[[:space:]]+((--repo|-R|--hostname)[=[:space:]]+[^[:space:]]+[[:space:]]+)*(pr[[:space:]]+(create|edit|reopen|ready)|stack[[:space:]]+submit)|git[[:space:]]+push)([[:space:];|&]|$)'; then
  jq -nc --arg context '[pr-evidence] Before PR publication (or push to an existing PR), follow commit-push-pr/REFERENCE.md: every PR gets /quantify-impact; any visible change, however small, needs a complete affected-surface inventory, fresh embedded before/after images, reviewed snapshot updates and a passing visual regression run. No local image paths or silent skips. Re-read the published body; refresh stale evidence after changes. Push alone never authorizes creating a PR.' \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$context}}'
fi
