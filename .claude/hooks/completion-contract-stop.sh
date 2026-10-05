#!/bin/bash
set -eo pipefail

# Stop hook: action turns may not end silently or leave subagents behind.
# Semantic completion stays the model's responsibility; this hook enforces
# only the visible intent/impact + status contract and cleanup checkpoint.

input=$(cat 2>/dev/null || echo '{}')

if [ -z "${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}" ]; then
  CODEX_SESSION_ID=$(printf '%s' "$input" | jq -r '.session_id // empty' 2>/dev/null)
  export CODEX_SESSION_ID
fi

[ -n "${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-}}" ] || exit 0

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true

active_dir="$_hook_session_dir/active-subagents"
if [ -d "$active_dir" ]; then
  active_count=0
  for active_file in "$active_dir"/*; do
    [ -f "$active_file" ] || continue
    active_count=$((active_count + 1))
  done
  if [ "$active_count" -gt 0 ]; then
    hook_stop_block "${active_count} active subagent(s) remain. Collect or stop them before final status; no background agent may outlive the turn."
  fi
fi

# Artifact-only turns do not owe an action status, but cleanup above is universal.
endpoint_file="$_hook_session_dir/task-endpoint"
[ -s "$endpoint_file" ] || exit 0

last_message=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null)
last_line=$(printf '%s\n' "$last_message" | awk 'NF { line=$0 } END { print line }')
reminder_line=$(printf '%s\n' "$last_message" | awk 'NF { previous=line; line=$0 } END { print previous }')

has_visible_detail() {
  printf '%s' "$1" | grep -q '[^[:space:]]'
}

reminder_valid=false
case "$reminder_line" in
  "Intent: "*" | Impact: "*)
    intent=${reminder_line#"Intent: "}
    impact=${intent#*" | Impact: "}
    intent=${intent%%" | Impact: "*}
    if has_visible_detail "$intent" && has_visible_detail "$impact"; then
      reminder_valid=true
    fi
    ;;
esac

# Delivery endpoints already authorize routine git on the current feature branch.
# Asking permission to push, rebase, or commit there stalls hands-free work.
endpoint=$(tr -d '[:space:]' < "$endpoint_file" 2>/dev/null || true)
case "$endpoint" in
  push|pr|ship)
    branch=$(git branch --show-current 2>/dev/null || true)
    default_branch=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || true)
    case "$branch" in
      ""|main|master|develop|"${default_branch#origin/}") ;;
      *)
        ask_re='(want me to|should i|shall i|would you like( me)? to|do you want( me)? to|may i|can i|ok(ay)? to|let me know if|if you( would|.d)? like|if you want|happy to)[^.?!]{0,80}(force-push|push|rebase|commit)([^a-z]|$)'
        decision_re='^🟡 awaiting decision — .*(push|rebase|commit)([^a-z]|$)'
        if printf '%s\n' "$last_message" | grep -qiE "$ask_re" \
          || printf '%s\n' "$last_line" | grep -qiE "$decision_re"; then
          hook_stop_block "Push permission request rejected: endpoint '$endpoint' already authorizes commit, push, rebase, and --force-with-lease on '$branch'; do not ask. Run the git step now, verify, and end with the evidence-bearing status line."
        fi
        ;;
    esac
    ;;
esac

case "$last_line" in
  "🟢 done — "*)
    detail=${last_line#"🟢 done — "}
    if [ "$reminder_valid" = true ] && has_visible_detail "$detail"; then
      touch "$_hook_session_dir/task-completed" 2>/dev/null || true
      exit 0
    fi
    ;;
  "🟡 awaiting decision — "*)
    detail=${last_line#"🟡 awaiting decision — "}
    [ "$reminder_valid" = true ] && has_visible_detail "$detail" && exit 0
    ;;
  "🔴 blocked — "*)
    detail=${last_line#"🔴 blocked — "}
    [ "$reminder_valid" = true ] && has_visible_detail "$detail" && exit 0
    ;;
esac

# Corrected valid statuses above still record completion. Avoid a repeated
# formatting-only block, without discarding a successful delivery retry.
if printf '%s' "$input" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then
  exit 0
fi

hook_stop_block "Silent or ambiguous stop rejected. Reread the active request and continue if work remains. Otherwise put Intent: <outcome> | Impact: <why it matters> immediately before exactly one evidence-bearing status line: 🟢 done — <evidence>, 🟡 awaiting decision — <specific decision>, or 🔴 blocked — <external blocker and needed input>. Keep the user's goal; use Impact: not established when unknown, never invent business claims or metrics."
