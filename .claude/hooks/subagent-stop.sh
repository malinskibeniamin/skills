#!/bin/bash
# SubagentStop hook — clears all active markers and validates reviewer output.
# Matcher: all subagents; schema validation applies only to reviewer types.
# Blocks (exit 2) if output doesn't match findings schema — forces retry.
# Writes valid findings to session dir for downstream consumption.

set -euo pipefail

# ── Parse stdin ──────────────────────────────────────────────────
input=$(cat)
agent_type=$(echo "$input" | jq -r '.agent_type // empty')
agent_id=$(echo "$input" | jq -r '.agent_id // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')
last_message=$(echo "$input" | jq -r '.last_assistant_message // empty')
session_dir="/tmp/hook-session-${session_id:-${CLAUDE_SESSION_ID:-$$}}"
safe_agent_id=$(printf '%s' "$agent_id" | tr -cd '[:alnum:]_.-')
# Resolve the installed bundle, not the consuming repository's checkout.
harness_root=$(cd "$(dirname "$0")/../.." && pwd)
findings_schema="$harness_root/agents/references/findings-schema.md"
validator="$harness_root/agents/references/findings-schema.jq"

clear_active_agent() {
  [ -n "$safe_agent_id" ] || return 0
  rm -f "$session_dir/active-subagents/$safe_agent_id" 2>/dev/null || true
}

# Only validate reviewer agents
case "$agent_type" in
  self-reviewer|code-reviewer|adversarial-reviewer|interface-reviewer|integration-reviewer|runtime-reviewer|contracts-data-reviewer|performance-reviewer) ;;
  *)
    clear_active_agent
    exit 0
    ;;
esac

reject_report() {
  jq -cn --arg message "$1" \
    '{hookSpecificOutput:{hookEventName:"SubagentStop"},systemMessage:$message}' >&2
  exit 2
}

if [ ! -f "$validator" ]; then
  reject_report "Installed reviewer validation contract is missing: $validator. Repair the harness installation; a different report cannot restore it."
fi

# ── Extract JSON from last message ───────────────────────────────
# Reviewers output a fenced ```json ... ``` block
json_block=$(printf '%s\n' "$last_message" | sed -n '/^```json/,/^```$/p' | sed '1d;$d')

if [ -z "$json_block" ]; then
  # Try raw JSON (no fencing)
  json_block="$last_message"
fi

# ── Validate schema ──────────────────────────────────────────────
if ! printf '%s\n' "$json_block" | jq -e -s --arg reviewer "$agent_type" -f "$validator" >/dev/null 2>&1; then
  reject_report "Invalid reviewer report. Read $findings_schema; return exactly one version 1 JSON report with valid status, findings, evidence, and verdict consistency. Incomplete reviews need an explicit reason, not approval."
fi
status=$(printf '%s\n' "$json_block" | jq -r '.status')
finding_count=$(printf '%s\n' "$json_block" | jq '.findings | length')

# ── Log findings ─────────────────────────────────────────────────
mkdir -p "$session_dir" 2>/dev/null || true

# Append to review findings (multiple reviewers may contribute)
findings_file="$session_dir/review-findings.json"
printf '%s\n' "$json_block" | jq -c . >> "$findings_file"

# Summary for session log
p0_count=$(echo "$json_block" | jq '[.findings[] | select(.severity == "P0")] | length')
p1_count=$(echo "$json_block" | jq '[.findings[] | select(.severity == "P1")] | length')
p2_count=$(echo "$json_block" | jq '[.findings[] | select(.severity == "P2")] | length')
p3_count=$(echo "$json_block" | jq '[.findings[] | select(.severity == "P3")] | length')

summary="${agent_type}: ${status} — ${finding_count} findings (P0:${p0_count} P1:${p1_count} P2:${p2_count} P3:${p3_count})"
echo "$summary" >> "$session_dir/review-summary.log"

# ── Emit summary as system message ───────────────────────────────
clear_active_agent
echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStop\"},\"systemMessage\":\"${summary}\"}"
exit 0
