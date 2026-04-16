#!/bin/bash
set -eo pipefail

# Stop hook: enforce development lifecycle completion with auto-remediation.
# Ensures code changes are tested, simplified, pushed, PR'd, CI-checked,
# and review-requested. Instead of just blocking, prescribes exact actions
# so Claude auto-follows and retries.
#
# Lifecycle gates (sequential):
#   0. Untested code? → prescribe: run /tdd
#   1. Uncommitted changes? → prescribe: run /commit-push
#   2. Unpushed commits? → prescribe: git push
#   3. No PR? → prescribe: gh pr create
#   4. CI failing? → prescribe: fix and push
#   5. CI pending? → prescribe: monitor with Monitor tool
#   6. No reviewer? → prescribe: request review
#   All pass → allow finish

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true

# ── Quick exits (most sessions hit one of these) ────────────────

# Need session tracking to know what we changed
if ! hook_has_session_tracking 2>/dev/null; then
  exit 0
fi

# Need gh CLI for PR/CI operations
if ! command -v gh &>/dev/null; then
  exit 0
fi

# Only enforce on feature branches
branch=$(git branch --show-current 2>/dev/null || true)
case "$branch" in
  main|master|develop|"") exit 0 ;;
esac

# Only enforce if this session touched code files (even if already committed)
_touched_file="$_hook_session_dir/session-touched-files"
if [ ! -f "$_touched_file" ] || [ ! -s "$_touched_file" ]; then
  exit 0
fi
_session_code=$(grep -E '\.(ts|tsx)$' "$_touched_file" 2>/dev/null || true)
if [ -z "$_session_code" ]; then
  exit 0
fi

# ── Step 0: Coverage gap analysis ──────────────────────────────
# Run vitest coverage on session-changed source files. If coverage
# is below threshold, block with specific gap report. If vitest/
# coverage not available, fall back to session-level test check.

_new_source=false
_has_tests=false
_source_files=""

while IFS= read -r _src_file; do
  [ -z "$_src_file" ] && continue
  case "$_src_file" in
    *.test.*|*.spec.*)
      _has_tests=true
      continue ;;
    *.gen.*|*_pb.*|*_connectquery.*)
      continue ;;
  esac
  if echo "$_src_file" | grep -qE '/(routes|components|hooks|features|modules|pages|views)/'; then
    _new_source=true
    _source_files="${_source_files} ${_src_file}"
  fi
done <<< "$_session_code"

# Skip if no new source files in testable dirs
if [ "$_new_source" = false ]; then
  : # no enforcement needed
elif command -v vitest &>/dev/null || [ -x "./node_modules/.bin/vitest" ]; then
  # Try coverage analysis — run related tests with coverage
  _vitest_bin="vitest"
  [ -x "./node_modules/.bin/vitest" ] && _vitest_bin="./node_modules/.bin/vitest"

  _cov_json=$(mktemp -d)/coverage
  _cov_report=""
  _cov_report=$($_vitest_bin run --coverage.enabled --coverage.reporter=json \
    --coverage.reportsDirectory="$_cov_json" \
    --reporter=json --run 2>/dev/null || true)

  _cov_summary="$_cov_json/coverage-summary.json"
  if [ -f "$_cov_summary" ]; then
    # Check coverage for each session-changed source file
    _low_coverage=""
    _threshold=60  # line coverage threshold

    for _sf in $_source_files; do
      # Try absolute and relative path keys in coverage JSON
      _abs_path=$(cd "$(dirname "$_sf")" 2>/dev/null && echo "$(pwd -P)/$(basename "$_sf")" || echo "$_sf")
      _pct=$(jq -r --arg f "$_abs_path" '.[$f].lines.pct // empty' "$_cov_summary" 2>/dev/null || true)
      [ -z "$_pct" ] && _pct=$(jq -r --arg f "$_sf" '.[$f].lines.pct // empty' "$_cov_summary" 2>/dev/null || true)

      if [ -n "$_pct" ] && [ "$_pct" != "100" ]; then
        _pct_int=${_pct%.*}
        if [ "${_pct_int:-0}" -lt "$_threshold" ]; then
          _low_coverage="${_low_coverage}\n  $(basename "$_sf"): ${_pct}% lines covered"
        fi
      fi
    done

    if [ -n "$_low_coverage" ]; then
      hook_stop_block "Coverage gaps found in session-changed files:${_low_coverage}\nRun /tdd to analyze coverage gaps and write tests targeting uncovered code. Then run /simplify."
    fi

    rm -rf "$(dirname "$_cov_json")" 2>/dev/null || true
  else
    # Coverage run failed or not configured — fall back to test existence check
    if [ "$_has_tests" = false ]; then
      hook_stop_block "New source files created but no test files written this session (coverage analysis unavailable). Run /tdd to write tests for the feature. Then run /simplify."
    fi
  fi
else
  # No vitest available — fall back to session-level test check
  if [ "$_has_tests" = false ]; then
    hook_stop_block "New source files created but no test files written this session. Run /tdd to write tests for the feature. Then run /simplify."
  fi
fi

# ── Step 0b: Uncommitted changes → commit ──────────────────────
if [ -n "$(git diff --name-only 2>/dev/null)" ] || [ -n "$(git diff --cached --name-only 2>/dev/null)" ]; then
  hook_stop_block "Uncommitted changes remain. Run /commit-push to commit and push all changes. Then retry."
fi

# Need a remote to push to
if ! git remote get-url origin &>/dev/null 2>&1; then
  exit 0
fi

# ── Step 1: Unpushed commits → push ─────────────────────────────

unpushed=""
if git rev-parse --verify "origin/$branch" &>/dev/null 2>&1; then
  unpushed=$(git log "origin/$branch..HEAD" --oneline 2>/dev/null || true)
else
  # Branch never pushed — all commits since default branch are unpushed
  for base in origin/main origin/master; do
    if git rev-parse --verify "$base" &>/dev/null 2>&1; then
      unpushed=$(git log --oneline "$base..HEAD" 2>/dev/null || true)
      break
    fi
  done
fi

if [ -n "$unpushed" ]; then
  _count=$(echo "$unpushed" | wc -l | tr -d ' ')
  hook_stop_block "${_count} unpushed on '$branch'. Run: git push -u origin $branch — then retry."
fi

# ── Step 2: No PR → create one ──────────────────────────────────

pr_number=$(gh pr list --head "$branch" --json number --jq '.[0].number' 2>/dev/null || true)

if [ -z "$pr_number" ]; then
  hook_stop_block "No PR for '$branch'. Create one NOW: gh pr create --fill — then retry."
fi

# ── Step 3 & 4: CI status ───────────────────────────────────────

pr_data=$(gh pr view "$pr_number" --json statusCheckRollup,reviewRequests 2>/dev/null || true)
ci_states=$(echo "$pr_data" | jq -r '.statusCheckRollup[]?.state // empty' 2>/dev/null || true)

if [ -n "$ci_states" ]; then
  if echo "$ci_states" | grep -qi "FAILURE\|ERROR"; then
    hook_stop_block "CI FAILING on PR #$pr_number. Read failures with: gh pr checks $pr_number — fix the issues, commit, push. Then use Monitor tool on 'gh pr checks $pr_number --watch' to stream results. Do not stop until CI green."
  fi

  if echo "$ci_states" | grep -qi "PENDING\|EXPECTED\|QUEUED\|IN_PROGRESS"; then
    if ! echo "$ci_states" | grep -qi "SUCCESS"; then
      hook_stop_block "CI still running on PR #$pr_number. Use Monitor tool on 'gh pr checks $pr_number --watch' to stream CI status. Wait for completion, then retry."
    fi
  fi
fi

# ── Step 5: Review requested → assign reviewer ──────────────────

reviewer_count=$(echo "$pr_data" | jq -r '.reviewRequests | length' 2>/dev/null || echo "0")

if [ "$reviewer_count" = "0" ] || [ -z "$reviewer_count" ]; then
  hook_stop_block "CI green but no reviewer on PR #$pr_number. Request review NOW: gh pr edit $pr_number --add-reviewer <user> — then retry."
fi

# ── Lifecycle complete ───────────────────────────────────────────
exit 0
