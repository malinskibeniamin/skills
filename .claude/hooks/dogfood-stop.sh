#!/bin/bash
set -eo pipefail

# Stop gate: a runnable PR state must have a matching /dogfood invocation
# and a structured PASS receipt. PR/ship endpoints inspect the whole branch;
# other endpoints activate only when this session changed runnable behavior.

input=$(cat 2>/dev/null || echo '{}')
if printf '%s' "$input" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
  exit 0
fi

if [ -z "${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}" ]; then
  CODEX_SESSION_ID=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)
  export CODEX_SESSION_ID
fi

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true
[ -n "${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}" ] || exit 0

state_lib="$(dirname "$0")/dogfood-state.sh"
if [ ! -f "$state_lib" ]; then
  hook_stop_block "Dogfood enforcement is incomplete: dogfood-state.sh is missing. Restore the plugin installation, then run /dogfood."
fi
# shellcheck source=dogfood-state.sh
source "$state_lib"

runnable_files=$(dogfood_runnable_files)
[ -n "$runnable_files" ] || exit 0

endpoint=$(cat "$_hook_session_dir/task-endpoint" 2>/dev/null | tr -d '[:space:]')
touched="$_hook_session_dir/session-touched-files"
touch_start="$_hook_session_dir/dogfood-task-start-touched-count"
baseline="$_hook_session_dir/dogfood-task-dirty-baseline"
[ -f "$baseline" ] || baseline="$_hook_session_dir/dirty-files-baseline"
start_head="$_hook_session_dir/dogfood-task-start-head"
[ -f "$start_head" ] || start_head="$_hook_session_dir/session-start-head"

list_has_runnable_pr_file() {
  local candidates="$1" raw path
  while IFS= read -r raw; do
    [ -n "$raw" ] || continue
    path=$(dogfood_normalize_touched_path "$raw" 2>/dev/null || printf '%s' "${raw#./}")
    if printf '%s\n' "$runnable_files" | grep -Fqx -- "$path"; then
      return 0
    fi
  done <<< "$candidates"
  return 1
}

session_changed_runnable=false
if [ -s "$touched" ]; then
  touched_candidates=$(cat "$touched")
  if [ -s "$touch_start" ]; then
    touched_checkpoint=$(tr -dc '0-9' < "$touch_start")
    touched_candidates=$(tail -n "+$((${touched_checkpoint:-0} + 1))" "$touched" 2>/dev/null || true)
  fi
  if [ -n "$touched_candidates" ] \
    && list_has_runnable_pr_file "$touched_candidates"; then
    session_changed_runnable=true
  fi
fi

current_dirty=$(
  {
    git diff --name-only HEAD 2>/dev/null
    git ls-files --others --exclude-standard 2>/dev/null
  } | LC_ALL=C sort -u
)
if [ -n "$current_dirty" ]; then
  new_dirty="$current_dirty"
  if [ -f "$baseline" ] && [ -s "$baseline" ]; then
    new_dirty=$(comm -23 \
      <(printf '%s\n' "$current_dirty" | LC_ALL=C sort -u) \
      <(LC_ALL=C sort -u "$baseline") 2>/dev/null || printf '%s\n' "$current_dirty")
  fi
  if [ -n "$new_dirty" ] && list_has_runnable_pr_file "$new_dirty"; then
    session_changed_runnable=true
  fi
fi

if [ -s "$start_head" ]; then
  initial_head=$(tr -d '[:space:]' < "$start_head")
  current_head=$(git rev-parse HEAD 2>/dev/null || true)
  if [ -n "$initial_head" ] && [ "$initial_head" != "$current_head" ]; then
    committed_this_session=$(git diff --name-only "$initial_head" HEAD -- 2>/dev/null || true)
    if [ -n "$committed_this_session" ] \
      && list_has_runnable_pr_file "$committed_this_session"; then
      session_changed_runnable=true
    fi
  fi
fi

case "$endpoint" in
  pr|ship) ;;
  local|commit|push)
    [ "$session_changed_runnable" = true ] || exit 0
    ;;
  *) exit 0 ;;
esac

marker="$_hook_session_dir/dogfood-invocation"
if [ ! -s "$marker" ]; then
  hook_stop_block "Runnable PR work lacks experiential verification. Run /dogfood against the whole PR diff through each real entrypoint, repair findings, replay, and include its PASS receipt."
fi

checkpoint=$(jq -r '.fingerprint // empty' "$marker" 2>/dev/null || true)
current_fingerprint=$(dogfood_state_fingerprint 2>/dev/null || true)
if [ -z "$checkpoint" ] || [ -z "$current_fingerprint" ]; then
  hook_stop_block "Dogfood checkpoint is invalid. Run /dogfood again so it can bind evidence to the current PR state."
fi
if [ "$checkpoint" != "$current_fingerprint" ]; then
  hook_stop_block "Runnable work changed after /dogfood. Run /dogfood again on the current PR state, repair findings, and replay."
fi

last_message=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null)
if ! dogfood_receipt_is_pass "$last_message"; then
  hook_stop_block "Dogfood invocation is current, but completion lacks a structured PASS receipt. Include Verdict: PASS plus Entrypoint, Actions, Observations, Repairs, and Limits."
fi

exit 0
