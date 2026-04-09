#!/bin/bash
set -eo pipefail

# Source hook-lib for session-scoped file tracking
source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true

# Session-scoped: only check files this session touched
if type hook_session_changed_files &>/dev/null; then
  changed_files=$(hook_session_changed_files "tsx|jsx")
else
  changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(tsx|jsx)$' || true)
fi

if [ -z "$changed_files" ]; then
  exit 0
fi

# Skip if project doesn't have a doctor script
if [ ! -f "package.json" ] || ! jq -e '.scripts["doctor"]' package.json >/dev/null 2>&1; then
  exit 0
fi

# Run react-doctor in diff mode
output=""
exit_code=0
output=$(bun run doctor -- --diff --score 2>&1) || exit_code=$?

# Track consecutive failures — downgrade to warn after 3 to avoid infinite loops
_doctor_fail_counter="$_hook_session_dir/doctor-fail-count"
_doctor_fail_count=0
if [ -f "$_doctor_fail_counter" ]; then
  _doctor_fail_count=$(cat "$_doctor_fail_counter" 2>/dev/null || echo "0")
fi

# Block on errors (non-zero exit)
if [ $exit_code -ne 0 ]; then
  _doctor_fail_count=$((_doctor_fail_count + 1))
  echo "$_doctor_fail_count" > "$_doctor_fail_counter"
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)

  if [ "$_doctor_fail_count" -ge 3 ]; then
    echo "{\"decision\":\"allow\",\"reason\":\"React Doctor errors still present after $_doctor_fail_count attempts (may be pre-existing). Allowing finish:\\n\"$escaped\"\"}" >&2
    exit 0
  fi

  echo "{\"decision\":\"block\",\"reason\":\"React Doctor found errors in changed files:\\n\"$escaped\"\"}" >&2
  exit 2
fi

# Extract score
score=$(echo "$output" | grep -oE '[0-9]+' | tail -1 || echo "")

# Block on critical score
if [ -n "$score" ] && [ "$score" -lt 50 ]; then
  _doctor_fail_count=$((_doctor_fail_count + 1))
  echo "$_doctor_fail_count" > "$_doctor_fail_counter"

  if [ "$_doctor_fail_count" -ge 3 ]; then
    echo "{\"decision\":\"allow\",\"reason\":\"React Doctor score $score/100 after $_doctor_fail_count attempts (may be pre-existing). Allowing finish.\"}" >&2
    exit 0
  fi

  echo "{\"decision\":\"block\",\"reason\":\"React Doctor health score is $score/100 (critical). Fix issues before finishing.\"}" >&2
  exit 2
fi

# Reset counter on success
echo "0" > "$_doctor_fail_counter" 2>/dev/null || true

# Warn on low score (surface warnings without blocking)
if [ -n "$score" ] && [ "$score" -lt 80 ]; then
  echo "{\"decision\":\"allow\",\"reason\":\"React Doctor health score is $score/100. Consider fixing warnings to improve code health.\"}" >&2
  exit 0
fi

# Surface any warnings in output even if score is OK
if echo "$output" | grep -qiE 'warn|warning'; then
  warning_count=$(echo "$output" | grep -ciE 'warn|warning' || echo "0")
  echo "{\"decision\":\"allow\",\"reason\":\"React Doctor passed (score: ${score:-N/A}/100) but found $warning_count warning(s). Run 'bun run doctor' for details.\"}" >&2
fi

exit 0
