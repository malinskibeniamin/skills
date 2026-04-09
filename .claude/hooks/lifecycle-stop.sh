#!/bin/bash
set -eo pipefail

# Stop hook: enforce development lifecycle completion.
# Ensures code changes are pushed, PR'd, CI-checked, and review-requested.
# Only enforces on feature branches when this session modified code.
#
# Lifecycle gates (sequential):
#   1. Unpushed commits? → block: push
#   2. No PR? → block: create PR
#   3. CI failing? → block: fix and push
#   4. CI pending? → block: wait for CI
#   5. No reviewer? → block: request review
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
_session_code=$(grep -E '\.(ts|tsx|js|jsx)$' "$_touched_file" 2>/dev/null || true)
if [ -z "$_session_code" ]; then
  exit 0
fi

# If there are uncommitted changes, let typecheck/lint hooks handle first
if [ -n "$(git diff --name-only 2>/dev/null)" ] || [ -n "$(git diff --cached --name-only 2>/dev/null)" ]; then
  exit 0
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
  hook_stop_block "You have $_count unpushed commit(s) on '$branch'. Push before finishing: git push -u origin $branch"
fi

# ── Step 2: No PR → create one ──────────────────────────────────

pr_number=$(gh pr list --head "$branch" --json number --jq '.[0].number' 2>/dev/null || true)

if [ -z "$pr_number" ]; then
  hook_stop_block "Branch '$branch' is pushed but has no PR. Create one: gh pr create --fill"
fi

# ── Step 3 & 4: CI status ───────────────────────────────────────

pr_data=$(gh pr view "$pr_number" --json statusCheckRollup,reviewRequests 2>/dev/null || true)
ci_states=$(echo "$pr_data" | jq -r '.statusCheckRollup[]?.state // empty' 2>/dev/null || true)

if [ -n "$ci_states" ]; then
  if echo "$ci_states" | grep -qi "FAILURE\|ERROR"; then
    hook_stop_block "CI checks are failing on PR #$pr_number. Fix the failures, push, and verify: gh pr checks $pr_number --watch"
  fi

  if echo "$ci_states" | grep -qi "PENDING\|EXPECTED\|QUEUED\|IN_PROGRESS"; then
    if ! echo "$ci_states" | grep -qi "SUCCESS"; then
      hook_stop_block "CI checks are still running on PR #$pr_number. Wait for completion: gh pr checks $pr_number --watch"
    fi
  fi
fi

# ── Step 5: Review requested → assign reviewer ──────────────────

reviewer_count=$(echo "$pr_data" | jq -r '.reviewRequests | length' 2>/dev/null || echo "0")

if [ "$reviewer_count" = "0" ] || [ -z "$reviewer_count" ]; then
  hook_stop_block "CI is green on PR #$pr_number but no reviewer assigned. Request review: gh pr edit $pr_number --add-reviewer <username>"
fi

# ── Lifecycle complete ───────────────────────────────────────────
exit 0
