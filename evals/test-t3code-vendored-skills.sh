# Exercise the importer and the shipped snapshot, not copies of its implementation.

if python3 "$REPO_ROOT/evals/test-t3code-sync.py" &&
   python3 "$REPO_ROOT/scripts/vendor-t3code-skills.py" --check; then
  echo "  PASS  T3/Effect import, integrity and registration contracts"
  PASS=$((PASS + 1))
else
  echo "  FAIL  T3/Effect import, integrity or registration contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: T3/Effect vendoring contract"
fi
