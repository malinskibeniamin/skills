#!/bin/bash
set -euo pipefail

# One endpoint-aware Stop process. Child checks keep their existing contracts;
# this dispatcher shares the payload, aggregates findings, and emits once.

input=$(cat 2>/dev/null || echo '{}')
script_dir=$(cd "$(dirname "$0")" && pwd)
root=$(cd "$script_dir/../.." && pwd)
manifest="$root/skill-manifest.json"
[ -f "$manifest" ] || exit 0

sid="${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}"
[ -z "$sid" ] && sid=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null || true)
session_dir=""
[ -n "$sid" ] && session_dir="/tmp/hook-session-${sid}"

endpoint=""
[ -n "$session_dir" ] && [ -f "$session_dir/task-endpoint" ] \
  && endpoint=$(head -1 "$session_dir/task-endpoint")

has_changes=0
if { [ -n "$session_dir" ] && [ -s "$session_dir/session-touched-files" ]; } \
  || [ -n "$(git status --porcelain --untracked-files=normal 2>/dev/null)" ]; then
  has_changes=1
fi

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
blocks="$tmp_dir/blocks"
notes="$tmp_dir/notes"
: >"$blocks"
: >"$notes"

extract_message() {
  local file="$1"
  jq -r '
    .systemMessage //
    .reason //
    .hookSpecificOutput.additionalContext //
    empty
  ' "$file" 2>/dev/null || cat "$file"
}

while IFS= read -r script; do
  [ -n "$script" ] || continue

  case "$script" in
    pr-feedback-completeness-stop.sh)
      if [ "$endpoint" != "pr" ] && [ "$endpoint" != "ship" ] \
        && { [ -z "$session_dir" ] || [ ! -f "$session_dir/pr-feedback-active" ]; }; then
        continue
      fi
      ;;
    biome-autofix.sh | typecheck-stop.sh | react-doctor-stop.sh | registry-check.sh | \
      orchestration-stop.sh | test-perf-stop.sh | quality-gate-stop.sh | dogfood-stop.sh | \
      lifecycle-stop.sh | suppression-gate-stop.sh)
      [ "$has_changes" = "1" ] || continue
      ;;
  esac

  child="$script_dir/$script"
  [ -x "$child" ] || continue
  out="$tmp_dir/${script}.out"
  err="$tmp_dir/${script}.err"
  status=0
  printf '%s' "$input" | "$child" >"$out" 2>"$err" || status=$?

  if [ "$status" -eq 2 ]; then
    message=$(extract_message "$err")
    [ -z "$message" ] && message=$(extract_message "$out")
    [ -n "$message" ] && printf '[%s] %s\n' "${script%.sh}" "$message" >>"$blocks"
  elif [ "$status" -ne 0 ]; then
    printf '[%s] check exited %s; inspect the hook directly.\n' "${script%.sh}" "$status" >>"$notes"
  else
    message=$(extract_message "$out")
    [ -n "$message" ] && printf '[%s] %s\n' "${script%.sh}" "$message" >>"$notes"
  fi
done < <(jq -r '."x-stop-dispatch"[] | if type == "object" then .script else . end' "$manifest")

if [ -s "$blocks" ]; then
  message=$(cat "$blocks")
  jq -n --arg message "$message" '{suppressOutput:true,systemMessage:$message}' >&2
  exit 2
fi

if [ -s "$notes" ]; then
  message=$(cat "$notes")
  jq -n --arg message "$message" \
    '{hookSpecificOutput:{hookEventName:"Stop",additionalContext:$message}}'
fi
