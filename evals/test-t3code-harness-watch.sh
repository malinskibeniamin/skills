# Public watcher CLI contracts; sourced by evals/run.sh.

eval_t3code_harness_watch() {
  echo "--- t3code-harness-watch ---"
  local output status=0
  output=$(python3 "$REPO_ROOT/evals/test-t3code-harness-watch.py" 2>&1) || status=$?
  if [ "$status" -eq 0 ]; then
    echo "  PASS  T3 harness detection, draft publication and recovery contracts"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  T3 harness watcher contracts"
    echo "$output"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: T3 harness watcher contracts"
  fi
}

if [ -z "$target_skill" ] || [ "$target_skill" = "t3code-harness-watch" ]; then
  eval_t3code_harness_watch
fi
