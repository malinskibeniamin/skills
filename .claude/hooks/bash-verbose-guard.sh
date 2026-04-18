#!/bin/bash
set -eo pipefail

# PreToolUse Bash: warn (never deny) on commands that blow up token cost.
# Complements llm-truncate.sh (post-output cap). This fires pre-execution
# so the model sees the nudge before it pays the cost.

source "$(dirname "$0")/source-hook-lib.sh" 2>/dev/null || true
hook_parse_bash

nudge=""

# find without scope limit
case "$command" in
  *"find "*)
    if ! echo "$command" | grep -qE '\-maxdepth|\| *head|\| *tail'; then
      nudge="$nudge | find without -maxdepth or head: output may be huge. Prefer Glob tool or add -maxdepth N."
    fi
    ;;
esac

# git log without limit
if echo "$command" | grep -qE '\bgit log\b' && \
   ! echo "$command" | grep -qE '(\-n [0-9]|\-\-max-count|\-\-oneline|\| *head)'; then
  nudge="$nudge | git log without -n/--oneline: default shows all history. Add -n 30 or --oneline."
fi

# cat on large file (heuristic: specific large-looking paths)
if echo "$command" | grep -qE '\bcat (node_modules|dist|build|coverage|\.git/)'; then
  nudge="$nudge | cat on build artifacts: prefer Read with range or Grep for specific content."
fi

# grep -r on repo root
if echo "$command" | grep -qE '\bgrep -r [^ ]* (\.|/Users|/home)' && \
   ! echo "$command" | grep -qE '\-\-include|\| *head'; then
  nudge="$nudge | grep -r at repo/home: prefer Grep tool (respects .gitignore, faster, filtered)."
fi

[ -z "$nudge" ] && exit 0

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"additionalContext\":\"[bash-verbose]$nudge\"}}" >&2
exit 0
