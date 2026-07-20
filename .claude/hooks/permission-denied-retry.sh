#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# PermissionDenied (matcher: Bash): the auto-mode classifier denied a tool
# call. Log every denial for /hook-audit; return {"retry": true} ONLY for
# plainly read-only single commands, so Claude retries a different approach
# instead of stalling on a false-positive classifier deny. Anything with
# shell composition (pipes, chains, substitution, redirects) stays denied —
# the classifier may have seen something this allowlist cannot.

input=$(cat 2>/dev/null || echo '{}')
cmd=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$cmd" ] || exit 0

dir="$HOME/.claude/hook-metrics"
mkdir -p "$dir" 2>/dev/null || true
printf '{"ts":"%s","command":%s,"session":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  "$(printf '%s' "$cmd" | head -c 300 | jq -Rs . 2>/dev/null || echo '""')" \
  "${CLAUDE_SESSION_ID:-unknown}" \
  >> "$dir/permission-denied.jsonl" 2>/dev/null || true

# No composition of any kind — one simple command line.
case "$cmd" in
  *'|'*|*';'*|*'&'*|*'>'*|*'<'*|*'$('*|*'`'*|*$'\n'*) exit 0 ;;
esac

if printf '%s' "$cmd" | grep -qE '^[[:space:]]*(git (status|log|diff|show|branch|remote -v)|ls|rg|grep|fgrep|egrep|cat|head|tail|wc|file|stat|which|jq|gh pr (view|checks|list|diff)|gh run (view|list)|bun run (lint|type:check))([[:space:]]|$)'; then
  echo '{"retry": true}'
fi

exit 0
