# Public runner integration; temporary git repository and fake external CLIs.
if python3 "$REPO_ROOT/codex-review/scripts/test_codex_review.py"; then
  echo "  PASS  Codex review capture, publishing, failure, and snapshot contracts"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Codex review CLI contracts"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Codex review CLI contracts"
fi
