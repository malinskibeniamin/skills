#!/bin/bash
set -euo pipefail

# UserPromptSubmit hook: inject project state into every prompt.
# Target: <200ms total. Claude starts each response knowing the project state
# without wasting tool calls on git status, file reads, or config checks.

input=$(cat)
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')

if [ "$hook_event" != "UserPromptSubmit" ]; then
  exit 0
fi

context=""

# ── Git state (~80ms) ────────────────────────────────────────────

branch=$(git branch --show-current 2>/dev/null || echo "detached")
dirty=$(git diff --stat HEAD 2>/dev/null | tail -1 || echo "clean")
last_commit=$(git log --oneline -1 2>/dev/null || echo "no commits")
ahead_behind=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null | awk '{print "ahead:"$1" behind:"$2}' || echo "")

context="Branch: $branch"
[ -n "$dirty" ] && context="$context | $dirty"
[ -n "$ahead_behind" ] && context="$context | $ahead_behind"
context="$context\nLast commit: $last_commit"

# ── Package.json scripts (~30ms) ─────────────────────────────────

if [ -f "package.json" ]; then
  scripts=$(jq -r '.scripts // {} | keys[]' package.json 2>/dev/null | paste -sd ", " - || echo "")
  [ -n "$scripts" ] && context="$context\nAvailable scripts: $scripts"
fi

# ── Session violations (~5ms) ────────────────────────────────────

vfile="/tmp/claude-hook-violations-${CLAUDE_SESSION_ID:-$$}"
if [ -f "$vfile" ] && [ -s "$vfile" ]; then
  total=$(wc -l < "$vfile" | tr -d ' ')
  summary=$(sort "$vfile" | uniq -c | sort -rn | head -5 | awk '{print $1"x "$2}' | paste -sd ", " -)
  context="$context\nSession violations ($total total): $summary"
fi

# ── Active configuration (~5ms) ──────────────────────────────────

config=""
[ "${REACT_COMPILER_MODE:-}" ] && config="$config compiler=$REACT_COMPILER_MODE"
[ "${ISSUE_TRACKER:-}" ] && config="$config tracker=$ISSUE_TRACKER"
[ "${REACT_RULES_BAN_USEEFFECT:-}" = "1" ] && config="$config useEffect=banned"
[ "${HOOKS_FAIL_CLOSED:-}" = "1" ] && config="$config fail-closed=on"
[ -n "$config" ] && context="$context\nConfig:$config"

# ── Output ───────────────────────────────────────────────────────

if [ -n "$context" ]; then
  # Escape for JSON
  escaped=$(printf '%s' "$context" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":$escaped}}" >&2
fi

exit 0
