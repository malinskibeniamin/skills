#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# Notification (matchers: permission_prompt, idle_prompt, agent_needs_input,
# agent_completed): surface a desktop notification via the terminalSequence
# output field (OSC 9 + BEL) — works without a controlling terminal, which is
# exactly the background-agent case where these notifications matter.

input=$(cat 2>/dev/null || echo '{}')
kind=$(echo "$input" | jq -r '.matcher // .notification_type // empty' 2>/dev/null)

case "$kind" in
  permission_prompt)  title="Claude Code: waiting for permission" ;;
  idle_prompt)        title="Claude Code: waiting for input" ;;
  agent_needs_input)  title="Claude Code: background agent needs input" ;;
  agent_completed)    title="Claude Code: background agent finished" ;;
  *) exit 0 ;;
esac

detail=$(echo "$input" | jq -r '.message // empty' 2>/dev/null | head -c 120 | tr -d '\n\r\007\033')
[ -n "$detail" ] && title="$title — $detail"

_esc=$(printf '\033')
_bel=$(printf '\007')
jq -cn --arg s "${_esc}]9;${title}${_bel}" '{"suppressOutput":true,"terminalSequence":$s}' 2>/dev/null || true
exit 0
