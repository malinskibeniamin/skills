#!/bin/bash
set -euo pipefail

# Skill Eval Runner
# Usage: ./evals/run.sh [skill-name] [--json]
# Run all evals: ./evals/run.sh
# Run one skill: ./evals/run.sh setup-toolchain
# JSON output:   ./evals/run.sh --json

EVALS_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$EVALS_DIR/.." && pwd)"
PASS=0
FAIL=0
SKIP=0
ERRORS=""
JSON_MODE=false
FAILURES_JSON="[]"

# Parse args
target_skill=""
for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
    *) target_skill="$arg" ;;
  esac
done

run_hook_eval() {
  local script="$1"
  local input="$2"
  local expected_exit="$3"
  local description="$4"
  local expected_pattern="${5:-}"

  if [ ! -x "$script" ]; then
    echo "  SKIP  $description (script not found: $script)"
    SKIP=$((SKIP + 1))
    return
  fi

  local stderr_file
  stderr_file=$(mktemp)
  local stdout_file
  stdout_file=$(mktemp)

  local actual_exit=0
  echo "$input" | "$script" > "$stdout_file" 2> "$stderr_file" || actual_exit=$?

  local passed=true

  if [ "$actual_exit" -ne "$expected_exit" ]; then
    passed=false
  fi

  if [ -n "$expected_pattern" ]; then
    local combined
    combined=$(cat "$stdout_file" "$stderr_file")
    if ! echo "$combined" | grep -qF -- "$expected_pattern"; then
      passed=false
    fi
  fi

  if [ "$passed" = true ]; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    echo "        expected exit=$expected_exit, got exit=$actual_exit"
    if [ -n "$expected_pattern" ]; then
      echo "        expected pattern: $expected_pattern"
      echo "        stderr: $(cat "$stderr_file")"
    fi
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi

  rm -f "$stderr_file" "$stdout_file"
}

run_file_eval() {
  local file="$1"
  local description="$2"

  if [ -e "$file" ]; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

run_executable_eval() {
  local file="$1"
  local description="$2"

  if [ -x "$file" ]; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description (not executable)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

run_content_eval() {
  local file="$1"
  local pattern="$2"
  local description="$3"

  if [ ! -f "$file" ]; then
    echo "  FAIL  $description (file not found)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
    return
  fi

  if grep -qE -- "$pattern" "$file"; then
    echo "  PASS  $description"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  $description (pattern not found: $pattern)"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $description"
  fi
}

# Discover and run eval files

if [ "$JSON_MODE" = false ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  Skill Evals"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
fi

for eval_file in "$EVALS_DIR"/test-*.sh; do
  [ -f "$eval_file" ] || continue

  skill_name=$(basename "$eval_file" | sed 's/^test-//' | sed 's/\.sh$//')

  if [ -n "$target_skill" ] && [ "$skill_name" != "$target_skill" ]; then
    continue
  fi

  # Isolation: each eval file runs in its own subshell so leaked variables
  # (an undefined $HOOK inheriting a prior file's value), cd's into tmpdirs,
  # and exported session ids cannot poison later files. Counters cross the
  # boundary via a marker line on fd 3.
  cd "$REPO_ROOT"
  unset CLAUDE_SESSION_ID

  _counts=$(
    (
      PASS=0; FAIL=0; SKIP=0; ERRORS=""
      if [ "$JSON_MODE" = true ]; then
        source "$eval_file" > /dev/null
      else
        echo "[$skill_name]"
        source "$eval_file"
        echo ""
      fi
      printf 'EVAL_COUNTS %d %d %d %s\n' "$PASS" "$FAIL" "$SKIP" "$(printf '%b' "$ERRORS" | base64 | tr -d '\n')" >&3
    ) 3>&1 1>&2
  )
  _p=$(echo "$_counts" | awk '/^EVAL_COUNTS/{print $2}'); _f=$(echo "$_counts" | awk '/^EVAL_COUNTS/{print $3}'); _s=$(echo "$_counts" | awk '/^EVAL_COUNTS/{print $4}')
  _e=$(echo "$_counts" | awk '/^EVAL_COUNTS/{print $5}' | base64 -d 2>/dev/null || true)
  if [ -z "$_p" ]; then
    echo "  FAIL  eval file crashed before reporting: $skill_name"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: eval file crashed: $skill_name"
  else
    PASS=$((PASS + _p)); FAIL=$((FAIL + _f)); SKIP=$((SKIP + _s))
    [ -n "$_e" ] && ERRORS="$ERRORS$_e"
  fi
done

if [ "$JSON_MODE" = true ]; then
  # Build failures array
  failures_json="[]"
  if [ -n "$ERRORS" ]; then
    failures_json=$(printf '%b' "$ERRORS" | grep -E '^\s*FAIL:' | sed 's/^\s*FAIL: //' | jq -R . | jq -s .)
  fi
  total=$((PASS + FAIL + SKIP))
  echo "{\"total\":$total,\"passed\":$PASS,\"failed\":$FAIL,\"skipped\":$SKIP,\"failures\":$failures_json}"
  [ $FAIL -gt 0 ] && exit 1
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Results: $PASS passed, $FAIL failed, $SKIP skipped"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $FAIL -gt 0 ]; then
  echo ""
  echo "Failures:"
  printf '%b\n' "$ERRORS"
  echo ""
  exit 1
fi

exit 0
