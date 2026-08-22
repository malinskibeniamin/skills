# Differential parity (issue #48 WS3/WS4): the Codex per-call wrapper and the
# Claude batch dispatcher must agree on decisions for the same edit.

_dp_tmp=$(mktemp -d /tmp/differential-XXXXXX)
_dp_file="$_dp_tmp/page.ts"
printf 'export function bad(x: any) { return x; }\n' > "$_dp_file"

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
printf 'export function ok(x: number) { return x; }\n' > "$_dp_file"
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

# Canonical Codex apply_patch (array command form, multi-file): both the
# installed per-call entrypoint and the batch dispatcher must block, and the
# stdin session_id must scope the session dir.
_dp_ap_dir=$(mktemp -d /tmp/apx-eval-XXXXXX)
printf 'export const a: any = 1;\n' > "$_dp_ap_dir/a.ts"
printf 'export const b = 2;\n' > "$_dp_ap_dir/b.ts"
_dp_patch=$(printf '*** Begin Patch\n*** Update File: %s/a.ts\n+export const a: any = 1;\n*** Update File: %s/b.ts\n+export const b = 2;\n*** End Patch' "$_dp_ap_dir" "$_dp_ap_dir")
_dp_ap_pc=$(jq -n --arg p "$_dp_patch" '{tool_name:"apply_patch",session_id:"apx-eval-pc",tool_input:{command:["apply_patch",$p]}}')
_dp_ap_b=$(jq -n --arg p "$_dp_patch" '{hook_event_name:"PostToolBatch",session_id:"apx-eval-b",tool_calls:[{tool_name:"apply_patch",tool_input:{command:["apply_patch",$p]}}]}')
_dp_pc_exit=0; printf '%s' "$_dp_ap_pc" | "$REPO_ROOT/.claude/hooks/ts-no-escape-hatches-check.sh" >/dev/null 2>&1 || _dp_pc_exit=$?
_dp_b_exit=0;  printf '%s' "$_dp_ap_b" | "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" >/dev/null 2>&1 || _dp_b_exit=$?
if [ "$_dp_pc_exit" -eq 2 ] && [ "$_dp_b_exit" -eq 2 ]; then
  echo "  PASS  canonical apply_patch blocks in both runtimes (exit 2/2)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  apply_patch divergence: per-call=$_dp_pc_exit batch=$_dp_b_exit"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: apply_patch divergence"
fi
if [ -d "/tmp/hook-session-apx-eval-pc" ]; then
  echo "  PASS  stdin session_id scopes the session dir"
  PASS=$((PASS + 1))
else
  echo "  FAIL  stdin session_id ignored"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: stdin session_id ignored"
fi

# Second rule (zustand) through both runtimes -- parity is not one-rule-deep.
printf 'import { create } from "zustand";\nexport const useS = create<S>((set) => ({}));\n' > "$_dp_ap_dir/store.ts"
_dp_z_pc=$(jq -n --arg f "$_dp_ap_dir/store.ts" '{tool_name:"Edit",tool_input:{file_path:$f,old_string:"x",new_string:"export const useS = create<S>((set) => ({}));"}}')
_dp_z_b=$(jq -n --arg f "$_dp_ap_dir/store.ts" '{hook_event_name:"PostToolBatch",tool_calls:[{tool_name:"Edit",tool_input:{file_path:$f,old_string:"x",new_string:"export const useS = create<S>((set) => ({}));"},tool_use_id:"z",tool_response:"{}"}]}')
_dp_pc_exit=0; printf '%s' "$_dp_z_pc" | CLAUDE_SESSION_ID=dp-z-pc-$$ "$REPO_ROOT/.claude/hooks/zustand-check.sh" >/dev/null 2>&1 || _dp_pc_exit=$?
_dp_b_exit=0;  printf '%s' "$_dp_z_b" | CLAUDE_SESSION_ID=dp-z-b-$$ "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" >/dev/null 2>&1 || _dp_b_exit=$?
if [ "$_dp_pc_exit" -eq 2 ] && [ "$_dp_b_exit" -eq 2 ]; then
  echo "  PASS  zustand rule BLOCKS in both runtimes (exit 2/2 -- 0/0 double-skip would fail)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  zustand divergence: per-call=$_dp_pc_exit batch=$_dp_b_exit"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: zustand divergence"
fi
command rm -f "$_dp_ap_dir"/*.ts 2>/dev/null || true; rmdir "$_dp_ap_dir" 2>/dev/null || true

# Relative-target apply_patch through the batch dispatcher (targets are
# repo-root-relative in canonical Codex patches; regression: silently dropped).
_dp_rel="$REPO_ROOT/.tmp-differential-rel.ts"
printf 'export const rel: any = 1;\n' > "$_dp_rel"
_dp_rel_patch=$(printf '*** Begin Patch\n*** Update File: .tmp-differential-rel.ts\n+export const rel: any = 1;\n*** End Patch')
_dp_rel_b=$(jq -n --arg p "$_dp_rel_patch" '{hook_event_name:"PostToolBatch",tool_calls:[{tool_name:"apply_patch",tool_input:{command:["apply_patch",$p]}}]}')
_dp_b_exit=0; printf '%s' "$_dp_rel_b" | "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" >/dev/null 2>&1 || _dp_b_exit=$?
if [ "$_dp_b_exit" -eq 2 ]; then
  echo "  PASS  relative-target apply_patch blocks via dispatcher (root-anchored)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  relative-target apply_patch dropped (exit=$_dp_b_exit)"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: relative apply_patch target dropped"
fi
command rm -f "$_dp_rel" 2>/dev/null || true
