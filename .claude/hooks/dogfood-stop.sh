#!/bin/bash
set -eo pipefail

# Stop gate: runnable work must have a /dogfood invocation after its latest
# runnable edit. The skill owns evidence quality; this hook only prevents
# silent omission and stale receipts.

input=$(cat 2>/dev/null || echo '{}')
if printf '%s' "$input" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
  exit 0
fi

if [ -z "${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}" ]; then
  CODEX_SESSION_ID=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)
  export CODEX_SESSION_ID
fi

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true
hook_has_session_tracking 2>/dev/null || exit 0

touched="$_hook_session_dir/session-touched-files"
[ -s "$touched" ] || exit 0

is_runnable_artifact() {
  local path="$1"
  [ -n "$path" ] || return 1
  case "$path" in
    */.context/*|*/node_modules/*|*/dist/*|*/build/*|*/coverage/*|*/.cache/*|*/.turbo/*)
      return 1 ;;
    */evals/*|*/agent-evals/*|*/e2e/*|*.test.*|*.spec.*|*.snap)
      return 1 ;;
    */SKILL.md)
      return 0 ;;
    *.md|*.mdx|*.txt|*.rst|*.png|*.jpg|*.jpeg|*.gif|*.webp|*.svg|*.ico|*.woff|*.woff2|*.ttf)
      return 1 ;;
  esac
  return 0
}

range_has_runnable_artifact() {
  local path
  while IFS= read -r path; do
    if is_runnable_artifact "$path"; then
      return 0
    fi
  done
  return 1
}

dogfood_block() {
  # hook_stop_block's cap bookkeeping reads optional fresh-session files.
  # Keep those absent reads from tripping this script's global `set -e`.
  set +e
  hook_stop_block "$1"
}

if ! range_has_runnable_artifact < "$touched"; then
  exit 0
fi

marker="$_hook_session_dir/dogfood-invocation"
if [ ! -s "$marker" ]; then
  dogfood_block "Runnable work changed without experiential verification. Run /dogfood through the real entrypoint, repair findings, replay, and include its receipt."
fi

checkpoint=$(tr -d '[:space:]' < "$marker")
case "$checkpoint" in
  ''|*[!0-9]*)
    dogfood_block "Dogfood checkpoint is invalid. Run /dogfood again on the current implementation."
    ;;
esac

current_count=$(wc -l < "$touched" | tr -d '[:space:]')
if [ "$checkpoint" -gt "$current_count" ]; then
  dogfood_block "Dogfood checkpoint is stale. Run /dogfood again on the current implementation."
fi

next_line=$((checkpoint + 1))
if tail -n "+$next_line" "$touched" | range_has_runnable_artifact; then
  dogfood_block "Runnable work changed after the last dogfood checkpoint. Run /dogfood after the latest runnable edit, then repair and replay any findings."
fi

exit 0
