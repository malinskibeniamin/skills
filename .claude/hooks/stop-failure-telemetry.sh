#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# StopFailure: the turn ended on an API error (rate_limit, overloaded,
# max_output_tokens, ...). The harness ignores this hook's output and exit
# code — observe-only by design. Feed /hook-audit and /stay-within-limits
# with the failure category so retro reports can correlate blocked sessions
# with limit pressure instead of guessing.

input=$(cat 2>/dev/null || echo '{}')

category=$(echo "$input" | jq -r '.matcher // .failure_type // .error_type // "unknown"' 2>/dev/null)
dir="$HOME/.claude/hook-metrics"
mkdir -p "$dir" 2>/dev/null || true
printf '{"ts":"%s","category":"%s","session":"%s"}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$category" "${CLAUDE_SESSION_ID:-unknown}" \
  >> "$dir/stop-failures.jsonl" 2>/dev/null || true

exit 0
