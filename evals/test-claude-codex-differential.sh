# Differential parity (issue #48 WS3/WS4): the Codex per-call wrapper and the
# Claude batch dispatcher must agree on decisions for the same edit.

_dp_tmp=$(mktemp -d /tmp/differential-XXXXXX)
_dp_file="$_dp_tmp/page.ts"
printf '// Copyright 2026 Redpanda Data, Inc.\nexport function bad(x: any) { return x; }\n' > "$_dp_file"

_dp_percall=$(jq -n --arg f "$_dp_file" '{tool_name:"Edit",tool_input:{file_path:$f,old_string:"export function bad(x: number) { return x; }",new_string:"export function bad(x: any) { return x; }"}}')
_dp_batch=$(jq -n --arg f "$_dp_file" '{hook_event_name:"PostToolBatch",tool_calls:[{tool_name:"Edit",tool_input:{file_path:$f,old_string:"export function bad(x: number) { return x; }",new_string:"export function bad(x: any) { return x; }"},tool_use_id:"a",tool_response:"{}"}]}')

_dp_pc_exit=0; _dp_pc_err=$(printf '%s' "$_dp_percall" | CLAUDE_SESSION_ID=dp-pc-$$ "$REPO_ROOT/.claude/hooks/ts-no-escape-hatches-check.sh" 2>&1 >/dev/null) || _dp_pc_exit=$?
_dp_b_exit=0;  _dp_b_err=$(printf '%s' "$_dp_batch" | CLAUDE_SESSION_ID=dp-b-$$ "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" 2>&1 >/dev/null) || _dp_b_exit=$?

if [ "$_dp_pc_exit" -eq 2 ] && [ "$_dp_b_exit" -eq 2 ]; then
  echo "  PASS  per-call and batch agree: ': any' blocks in both runtimes (exit 2/2)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  decision divergence: per-call exit=$_dp_pc_exit batch exit=$_dp_b_exit"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: claude/codex decision divergence (: any)"
fi

if printf '%s' "$_dp_pc_err" | grep -q "any" && printf '%s' "$_dp_b_err" | grep -q "any"; then
  echo "  PASS  both runtimes name the ': any' finding"
  PASS=$((PASS + 1))
else
  echo "  FAIL  finding text diverges between runtimes"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: finding text divergence"
fi

# Clean edit: both silent, both exit 0.
printf '// Copyright 2026 Redpanda Data, Inc.\nexport function ok(x: number) { return x; }\n' > "$_dp_file"
_dp_pc2=$(jq -n --arg f "$_dp_file" '{tool_name:"Edit",tool_input:{file_path:$f,old_string:"a",new_string:"export function ok(x: number) { return x; }"}}')
_dp_b2=$(jq -n --arg f "$_dp_file" '{hook_event_name:"PostToolBatch",tool_calls:[{tool_name:"Edit",tool_input:{file_path:$f,old_string:"a",new_string:"export function ok(x: number) { return x; }"},tool_use_id:"a",tool_response:"{}"}]}')
_dp_pc_exit=0; printf '%s' "$_dp_pc2" | CLAUDE_SESSION_ID=dp-pc2-$$ "$REPO_ROOT/.claude/hooks/ts-no-escape-hatches-check.sh" >/dev/null 2>&1 || _dp_pc_exit=$?
_dp_b_exit=0;  printf '%s' "$_dp_b2" | CLAUDE_SESSION_ID=dp-b2-$$ "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" >/dev/null 2>&1 || _dp_b_exit=$?
if [ "$_dp_pc_exit" -eq 0 ] && [ "$_dp_b_exit" -eq 0 ]; then
  echo "  PASS  per-call and batch agree on clean edit (exit 0/0)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  clean-edit divergence: per-call=$_dp_pc_exit batch=$_dp_b_exit"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: clean-edit divergence"
fi

command rm -f "$_dp_file" 2>/dev/null || true
rmdir "$_dp_tmp" 2>/dev/null || true
for _dp_d in "/tmp/hook-session-dp-pc-$$" "/tmp/hook-session-dp-b-$$" "/tmp/hook-session-dp-pc2-$$" "/tmp/hook-session-dp-b2-$$"; do
  command rm -f "$_dp_d"/* 2>/dev/null || true
  rmdir "$_dp_d" 2>/dev/null || true
done
