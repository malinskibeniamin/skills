# Exercise the public runner under a live host's session environment.
_runner_fixture=$(mktemp -d "${TMPDIR:-/tmp}/eval-runner-isolation.XXXXXX")
mkdir -p "$_runner_fixture/evals"
cp "$REPO_ROOT/evals/run.sh" "$_runner_fixture/evals/run.sh"
cat > "$_runner_fixture/evals/test-host-environment.sh" <<'EOF'
for key in CLAUDE_SESSION_ID CODEX_SESSION_ID CLAUDE_ENV_FILE; do
  if [ -z "${!key:-}" ]; then
    echo "  PASS  host $key is isolated"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  inherited host $key"
    FAIL=$((FAIL + 1))
  fi
done
EOF
if CLAUDE_SESSION_ID=host-claude-fixture CODEX_SESSION_ID=host-codex-fixture \
  CLAUDE_ENV_FILE="$_runner_fixture/host-env" \
  bash "$_runner_fixture/evals/run.sh" > "$_runner_fixture/result" 2>&1; then
  echo "  PASS  eval runner isolates host session identity and environment files"
  PASS=$((PASS + 1))
else
  echo "  FAIL  eval runner leaks the host session environment"
  cat "$_runner_fixture/result"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: eval runner host environment isolation"
fi
rm -rf "$_runner_fixture"
