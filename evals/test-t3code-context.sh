# Public route selection, not a claim about model compliance or native RPC execution.
if python3 "$REPO_ROOT/evals/test-t3code-context.py"; then
  echo "  PASS  native T3 context selection and negative controls"
  PASS=$((PASS + 1))
else
  echo "  FAIL  native T3 context selection"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: native T3 context selection"
fi
