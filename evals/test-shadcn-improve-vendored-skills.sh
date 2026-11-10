# Exercise pinned-source distribution, refresh, drift rejection and discovery offline.
if python3 "$REPO_ROOT/evals/test-shadcn-improve-vendoring.py"; then
  echo "  PASS  shadcn/improve pin, refresh, license and host discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  shadcn/improve vendoring contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: shadcn/improve vendoring contract"
fi
