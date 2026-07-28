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

clear_active_agent() {
  [ -n "$safe_agent_id" ] || return 0
  rm -f "$session_dir/active-subagents/$safe_agent_id" 2>/dev/null || true
}

# Only validate reviewer agents
case "$agent_type" in
  self-reviewer|code-reviewer|adversarial-reviewer) ;;
  *)
    clear_active_agent
    exit 0
    ;;
esac

# ── Extract JSON from last message ───────────────────────────────
# Reviewers output a fenced ```json ... ``` block
json_block=$(echo "$last_message" | sed -n '/^```json/,/^```$/p' | sed '1d;$d')

if [ -z "$json_block" ]; then
  # Try raw JSON (no fencing)
  json_block=$(echo "$last_message" | jq -e '.' 2>/dev/null || echo "")
fi

if [ -z "$json_block" ]; then
  echo '{"hookSpecificOutput":{"hookEventName":"SubagentStop"},"systemMessage":"Output must contain ```json``` block per findings-schema.md. Re-read and output correct format."}' >&2
  exit 2
fi

# ── Validate schema ──────────────────────────────────────────────
# Check required top-level fields
has_reviewer=$(echo "$json_block" | jq -e '.reviewer' 2>/dev/null && echo "ok" || echo "")
has_status=$(echo "$json_block" | jq -e '.status' 2>/dev/null && echo "ok" || echo "")
has_findings=$(echo "$json_block" | jq -e '.findings | type == "array"' 2>/dev/null && echo "ok" || echo "")

if [ -z "$has_reviewer" ] || [ -z "$has_status" ] || [ -z "$has_findings" ]; then
  missing=""
  [ -z "$has_reviewer" ] && missing="${missing} reviewer,"
  [ -z "$has_status" ] && missing="${missing} status,"
  [ -z "$has_findings" ] && missing="${missing} findings[],"
  missing="${missing%,}"
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStop\"},\"systemMessage\":\"Missing fields:${missing}. Re-read findings-schema.md.\"}" >&2
  exit 2
fi

# Validate status enum
status=$(echo "$json_block" | jq -r '.status')
case "$status" in
  APPROVED|CONCERNS|NEEDS_CHANGES) ;;
  *)
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStop\"},\"systemMessage\":\"Invalid status '${status}'. Use APPROVED|CONCERNS|NEEDS_CHANGES.\"}" >&2
    exit 2
    ;;
esac

# Validate each finding has required fields
finding_count=$(echo "$json_block" | jq '.findings | length')
if [ "$finding_count" -gt 0 ]; then
  invalid_findings=$(echo "$json_block" | jq '[.findings[] | select(.title == null or .severity == null or .file == null or .category == null or .autofix_class == null)] | length')
  if [ "$invalid_findings" -gt 0 ]; then
    echo "{\"hookSpecificOutput\":{\"hookEventName\":\"SubagentStop\"},\"systemMessage\":\"${invalid_findings} finding(s) missing fields (title/severity/file/category/autofix_class). Fix.\"}" >&2
    exit 2
  fi
fi

# ── Log findings ─────────────────────────────────────────────────
mkdir -p "$session_dir" 2>/dev/null || true

# Append to review findings (multiple reviewers may contribute)
findings_file="$session_dir/review-findings.json"
echo "$json_block" >> "$findings_file"

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
