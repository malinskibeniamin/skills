# Latency budget for the per-batch hook dispatcher (2026-07-08 benchmark:
# 1-edit median 2182ms on this branch vs 11134ms on main). Budget frozen at
# 5000ms so a regression toward per-call-era latency fails a check.

_lb_tmp=$(mktemp -d /tmp/latency-budget-XXXXXX)
printf 'export const ok = 1;\n' > "$_lb_tmp/clean.ts"
_lb_payload=$(printf '{"hook_event_name":"PostToolBatch","tool_calls":[{"tool_name":"Edit","tool_input":{"file_path":"%s/clean.ts","old_string":"a","new_string":"export const ok = 1;"}}]}' "$_lb_tmp")

_lb_start=$(perl -MTime::HiRes=time -e 'printf "%d", time()*1000000')
printf '%s' "$_lb_payload" | "$REPO_ROOT/.claude/hooks/post-tool-batch.sh" >/dev/null 2>&1 || true
_lb_end=$(perl -MTime::HiRes=time -e 'printf "%d", time()*1000000')
_lb_ms=$(( (_lb_end - _lb_start) / 1000 ))
if [ "$_lb_ms" -le 0 ]; then
  echo "  FAIL  latency timer returned ${_lb_ms}ms -- timer broken, budget unverifiable"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: latency timer broken"
fi
rm -f "$_lb_tmp/clean.ts"; rmdir "$_lb_tmp" 2>/dev/null || true

if [ "$_lb_ms" -lt 5000 ]; then
  echo "  PASS  batch dispatcher under latency budget (${_lb_ms}ms < 5000ms)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  batch dispatcher over latency budget (${_lb_ms}ms >= 5000ms)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: dispatcher latency ${_lb_ms}ms"
fi

# enforce-toolchain fast path: one union grep exits innocent commands early.
run_content_eval "$REPO_ROOT/.claude/hooks/enforce-toolchain.sh" "Fast path: one union grep" \
  "enforce-toolchain has the union fast path"
_ff=$(echo '{"tool_name":"Bash","tool_input":{"command":"npm install x"}}' | bash "$REPO_ROOT/.claude/hooks/enforce-toolchain.sh" 2>&1 || true)
if printf '%s' "$_ff" | grep -q "npm banned"; then
  echo "  PASS  fast path does not swallow npm deny"
  PASS=$((PASS + 1))
else
  echo "  FAIL  fast path swallowed the npm deny"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: fast path swallowed npm deny"
fi
