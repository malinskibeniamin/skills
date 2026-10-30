#!/bin/bash
# PostToolUse Bash: replace oversized stdout/stderr, never duplicate it into a
# user-facing systemMessage. Preserve the structured Bash output contract.
#
# Cap threshold: LLM_TRUNCATE_BYTES (default 4096).
# Keep-head and keep-tail: LLM_TRUNCATE_HEAD (80), LLM_TRUNCATE_TAIL (120).

set -euo pipefail
trap 'exit 0' ERR

# Source hook-lib for _hook_log_bash_drain. Optional — silently skip if missing.
_shim="$(dirname "$0")/source-hook-lib.sh"; if [ -f "$_shim" ]; then . "$_shim" 2>/dev/null || true; fi

input=$(cat)
result=$(printf '%s' "$input" | jq -ce '
  select(.tool_name == "Bash") | (.tool_response // .tool_result)
  | select(type == "object")
  | select((.stdout | type) == "string" and (.stderr | type) == "string")
  | select(.isImage != true)
' 2>/dev/null) || exit 0

cap_bytes="${LLM_TRUNCATE_BYTES:-4096}"
head_lines="${LLM_TRUNCATE_HEAD:-80}"
tail_lines="${LLM_TRUNCATE_TAIL:-120}"

[[ "$cap_bytes" =~ ^[1-9][0-9]{0,7}$ ]] || exit 0
[[ "$head_lines" =~ ^(0|[1-9][0-9]{0,7})$ ]] || exit 0
[[ "$tail_lines" =~ ^(0|[1-9][0-9]{0,7})$ ]] || exit 0
[ "$head_lines" -gt 0 ] || [ "$tail_lines" -gt 0 ] || exit 0

result_bytes=$(printf '%s' "$result" | jq '[.stdout, .stderr] | map(utf8bytelength) | add')

if [ "$result_bytes" -le "$cap_bytes" ]; then
  exit 0
fi

# Save the complete structured result in a private, collision-free file first.
log_path=$(mktemp "${TMPDIR:-/tmp}/claude-bash-output.XXXXXX" 2>/dev/null) || exit 0
printf '%s' "$result" 2>/dev/null > "$log_path" || exit 0

# jq slices strings by code point. Binary-search each byte budget so Unicode
# stays valid, and include the marker in the shared stdout + stderr budget.
replacement=$(printf '%s' "$result" | jq -c \
  --argjson cap "$cap_bytes" --argjson head "$head_lines" \
  --argjson tail "$tail_lines" --arg path "$log_path" '
  def clip_bytes($budget; $from_end):
    . as $text |
    def part($n):
      $text | if $from_end then .[(length - $n):] else .[:$n] end;
    def search($lo; $hi):
      if $lo >= $hi then part($lo)
      else (($lo + $hi + 1) / 2 | floor) as $mid |
        if (part($mid) | utf8bytelength) <= $budget
        then search($mid; $hi) else search($lo; $mid - 1) end
      end;
    search(0; ([length, $budget] | min));
  def truncate($budget):
    if utf8bytelength <= $budget then .
    else "\n... [output truncated; full: \($path)] ...\n" as $marker |
      if ($marker | utf8bytelength) > $budget then clip_bytes($budget; false)
      else ($budget - ($marker | utf8bytelength)) as $remaining |
        ($remaining * $head / ($head + $tail) | floor) as $head_budget |
        (split("\n")[:$head] | join("\n") | clip_bytes($head_budget; false)) as $start |
        (if $tail == 0 then ""
          elif endswith("\n") then
            rtrimstr("\n") | split("\n")[-$tail:] | join("\n") + "\n"
          else split("\n")[-$tail:] | join("\n") end
          | clip_bytes($remaining - ($start | utf8bytelength); true)) as $end |
        $start + $marker + $end
      end
    end;
  (.stdout | utf8bytelength) as $out_bytes |
  (.stderr | utf8bytelength) as $err_bytes |
  # Keep small channels intact; otherwise reserve up to half for stderr.
  ([$err_bytes, ([$cap / 2 | floor, $cap - $out_bytes] | max)] | min) as $err_budget |
  .stdout |= truncate($cap - $err_budget) |
  .stderr |= truncate($err_budget) |
  {hookSpecificOutput: {hookEventName: "PostToolUse", updatedToolOutput: .}}
') || exit 0

if command -v _hook_log_bash_drain >/dev/null 2>&1; then
  cmd_for_log=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
  kept_bytes=$(printf '%s' "$replacement" | jq '
    .hookSpecificOutput.updatedToolOutput | [.stdout, .stderr] | map(utf8bytelength) | add
  ')
  _hook_log_bash_drain "cap_hit" "$cmd_for_log" "$((result_bytes - kept_bytes))"
fi
printf '%s\n' "$replacement"
exit 0
