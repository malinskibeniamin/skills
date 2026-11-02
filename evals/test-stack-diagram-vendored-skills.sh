# Exercise the public importer/build CLIs and installed skill discovery offline.
if python3 "$REPO_ROOT/evals/test-stack-diagram-vendoring.py"; then
  echo "  PASS  stack-diagram pin, refresh, resources and host discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  stack-diagram vendoring contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: stack-diagram vendoring contract"
fi
