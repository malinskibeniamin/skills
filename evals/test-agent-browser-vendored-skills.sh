# Verify the public import/check CLI and installed discovery without network.
if python3 "$REPO_ROOT/evals/test-agent-browser-vendoring.py"; then
  echo "  PASS  agent-browser pin, refresh, isolation and host discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  agent-browser vendoring contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: agent-browser vendoring contract"
fi
