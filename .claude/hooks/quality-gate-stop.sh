#!/bin/bash
set -eo pipefail

# Escape hatch: when Claude is already responding to a Stop block, do not
# block again -- prevents infinite hostage loops (audit cluster 1).
_sha_in=$(cat); if printf '%s' "$_sha_in" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then exit 0; fi


# Aggregator Stop hook: reads all findings from quality hooks,
# reports them ALL at once so Claude fixes everything in one pass.
# Runs after all quality hooks, before lifecycle-stop.sh.
#
# Quality hooks (architecture-review, biome-autofix, typecheck,
# react-doctor, registry-check, orchestration) write findings to
# $session_dir/stop-findings via hook_stop_finding(). This hook
# reads that file, blocks with the combined report, then cleans up.

# Source hook-lib for safe JSON escaping and ERR trap
_shim="$(dirname "$0")/source-hook-lib.sh"; if [ -f "$_shim" ]; then . "$_shim" 2>/dev/null || true; fi

_session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
_findings="$_session_dir/stop-findings"

if [ -f "$_findings" ] && [ -s "$_findings" ]; then
  content=$(head -50 "$_findings")
  # Count findings by --- delimiters (each hook_stop_finding writes one)
  count=$(grep -c '^---$' "$_findings" 2>/dev/null) || count=1
  count=$(echo "$count" | tr -d '[:space:]')
  # Strip delimiter lines from display
  content=$(echo "$content" | grep -v '^---$')
  msg=$(printf "Quality gate: %s issue(s). Fix ALL before retrying:\n%s" "$count" "$content")

  if type _safe_json_escape &>/dev/null; then
    reason=$(_safe_json_escape "$msg")
  else
    # Inline fallback if hook-lib unavailable
    reason=$(printf '%s' "$msg" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/\\t/g' | tr '\n' ' ')
    reason="\"$reason\""
  fi

  echo "{\"decision\":\"block\",\"reason\":$reason}" >&2
  rm -f "$_findings"
  exit 2
fi

rm -f "$_findings" 2>/dev/null || true
exit 0
