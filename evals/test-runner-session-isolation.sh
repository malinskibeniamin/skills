# Eval fixtures must not inherit the host's real session state.
_runner_root=$(mktemp -d /tmp/eval-runner-isolation-XXXXXX)
trap 'rm -f "$_runner_root/run.sh" "$_runner_root/test-session-isolation.sh"; rmdir "$_runner_root"' EXIT
cp "$REPO_ROOT/evals/run.sh" "$_runner_root/run.sh"
cat > "$_runner_root/test-session-isolation.sh" <<'EOF'
if [ -z "${CLAUDE_SESSION_ID:-}" ] && [ -z "${CODEX_SESSION_ID:-}" ]; then
  PASS=$((PASS + 1))
else
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: inherited host sessions leak into eval fixtures"
fi
EOF

CLAUDE_SESSION_ID=parent-claude CODEX_SESSION_ID=parent-codex run_hook_eval \
  "$_runner_root/run.sh" "" 0 \
  "eval runner isolates fixtures from both host sessions" "Results: 1 passed, 0 failed, 0 skipped"
