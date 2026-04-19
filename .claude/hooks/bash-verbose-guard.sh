#!/bin/bash
set -eo pipefail

# PreToolUse Bash: warn (never deny) on commands that blow up token cost.
# Complements llm-truncate.sh (post-output cap). This fires pre-execution
# so the model sees the nudge before it pays the cost.
#
# Every nudge also logs to ~/.claude/hook-metrics/bash-drains.jsonl via
# _hook_log_bash_drain so we can measure fire rate against baseline.

source "$(dirname "$0")/source-hook-lib.sh" 2>/dev/null || true
hook_parse_bash

nudge=""

_fire() {
  # $1 = drain_type, $2 = nudge text appended to $nudge
  local dtype="$1" text="$2"
  nudge="$nudge | $text"
  if command -v _hook_log_bash_drain >/dev/null 2>&1; then
    _hook_log_bash_drain "$dtype" "$command" 0
  fi
}

# find without scope limit
case "$command" in
  *"find "*)
    if ! echo "$command" | grep -qE '\-maxdepth|\| *head|\| *tail'; then
      _fire "nudge-find" "find without -maxdepth or head: output may be huge. Prefer Glob tool or add -maxdepth N."
    fi
    ;;
esac

# git log without limit
if echo "$command" | grep -qE '\bgit log\b' && \
   ! echo "$command" | grep -qE '(\-n [0-9]|\-\-max-count|\-\-oneline|\| *head)'; then
  _fire "nudge-git-log" "git log without -n/--oneline: default shows all history. Add -n 30 or --oneline."
fi

# cat on large file (heuristic: specific large-looking paths)
if echo "$command" | grep -qE '\bcat (node_modules|dist|build|coverage|\.git/)'; then
  _fire "nudge-cat-artifact" "cat on build artifacts: prefer Read with range or Grep for specific content."
fi

# grep -r on repo root
if echo "$command" | grep -qE '\bgrep -r [^ ]* (\.|/Users|/home)' && \
   ! echo "$command" | grep -qE '\-\-include|\| *head'; then
  _fire "nudge-grep-root" "grep -r at repo/home: prefer Grep tool (respects .gitignore, faster, filtered)."
fi

# git commit without --quiet when lefthook/husky present
# Lefthook/Ultracite pre-commit output (~26k chars per commit) is the #1
# measured bash drain. --quiet suppresses the hook output without
# disabling the hook itself.
if echo "$command" | grep -qE '\bgit +commit\b' && \
   ! echo "$command" | grep -qE '(\-\-quiet|\s-q\b)'; then
  _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
  if [ -n "$_repo_root" ] && \
     { [ -f "$_repo_root/lefthook.yml" ] || [ -f "$_repo_root/lefthook.yaml" ] || [ -d "$_repo_root/.husky" ]; }; then
    _fire "nudge-git-commit" "git commit without --quiet in a lefthook/husky repo: pre-commit output spams tokens. Add --quiet (keeps hooks running, hides their logs)."
  fi
fi

# gh with --json but no --jq / pipe filter
# Measured: gh pr view/api with --json and no filter averaged 6.7k chars,
# 3 calls hit the 30k output cap on the same PR in the sample.
if echo "$command" | grep -qE '\bgh +(pr +view|api|pr +list|issue +view|run +view|repo +view)\b' && \
   echo "$command" | grep -qE '\-\-json\b' && \
   ! echo "$command" | grep -qE '(\-\-jq\b|\| *jq\b|\| *head\b|\| *wc\b|\| *tail\b)'; then
  _fire "nudge-gh-jq" "gh --json without --jq/pipe: returns full blob (often >10k chars). Add --jq '.field' or pipe to jq/head."
fi

# Repeat-command detection: same command run twice in a session = wasted tokens.
# Measured: same gh api fired 4x in one session, same README fetch 3x.
# Uses md5 of the raw command string; session-scoped state.
if [ -n "${_hook_session_dir:-}" ] && [ -d "$_hook_session_dir" ]; then
  _seen_file="$_hook_session_dir/bash-cmd-seen"
  # Hash the command. md5 (macOS) or md5sum (linux). Silent fallback.
  _cmd_hash=""
  if command -v md5 >/dev/null 2>&1; then
    _cmd_hash=$(printf '%s' "$command" | md5 2>/dev/null | cut -c1-16)
  elif command -v md5sum >/dev/null 2>&1; then
    _cmd_hash=$(printf '%s' "$command" | md5sum 2>/dev/null | cut -c1-16)
  fi
  # Only flag commands that are worth caching — skip trivial ones.
  # Heuristic: commands with `gh api`, `gh pr view`, `curl`, `fetch`, longer than 40 chars.
  if [ -n "$_cmd_hash" ] && [ ${#command} -gt 40 ] && \
     echo "$command" | grep -qE '(\bgh +(api|pr +view|issue +view|run +view)\b|\bcurl\b|\bwget\b|\btaskw\b|\bbun +run\b)'; then
    if [ -f "$_seen_file" ] && grep -q "^${_cmd_hash}\$" "$_seen_file" 2>/dev/null; then
      _fire "nudge-repeat-cmd" "Command already ran in this session — output still available via /tmp/claude-bash-logs/ or earlier tool_result. Consider re-using instead of re-fetching."
    fi
    echo "$_cmd_hash" >> "$_seen_file" 2>/dev/null || true
  fi
fi

[ -z "$nudge" ] && exit 0

echo "{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"additionalContext\":\"[bash-verbose]$nudge\"}}" >&2
exit 0
