# Public updater CLI contracts; sourced by evals/run.sh.
if [ -z "$target_skill" ] || [ "$target_skill" = "refresh-skill-upstreams" ]; then
  echo "--- refresh-skill-upstreams ---"
  refresh_output=""
  if refresh_output=$(python3 "$REPO_ROOT/evals/test-refresh-skill-upstreams.py" 2>&1); then
    echo "  PASS  priority skill refresh, trust boundaries and draft publication"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  priority skill refresh contracts"
    echo "$refresh_output"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: priority skill refresh contracts"
  fi
fi
