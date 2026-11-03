# Public importer behavior and offline packaging drift; no downloads/model calls.
if python3 "$REPO_ROOT/evals/test-rea-sync.py" &&
   python3 "$REPO_ROOT/scripts/vendor-rea.py" --check &&
   bash "$REPO_ROOT/scripts/generate-skill-catalog.sh" --check; then
  echo "  PASS  REA release import, safety and generated discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  REA release import, safety or generated discovery"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: REA release import and packaging"
fi
