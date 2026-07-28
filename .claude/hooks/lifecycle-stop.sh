#!/bin/bash
set -eo pipefail

# Escape hatch: when Claude is already responding to a Stop block, do not
# block again -- prevents infinite hostage loops (audit cluster 1).
_sha_in=$(cat); if printf '%s' "$_sha_in" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then exit 0; fi


# Stop hook: enforce only the external delivery endpoint the user requested.
# Local build/fix/implement work never commits, pushes, or opens a PR.
#
# Lifecycle gates (sequential):
#   commit → commit, stop
#   push   → commit + push, stop
#   pr     → verify + commit + push + PR + one CI snapshot, stop
#   ship   → full PR + CI remediation loop
#   All pass → allow finish

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true

# ── Quick exits (most sessions hit one of these) ────────────────

# Need session tracking to know what we changed
if ! hook_has_session_tracking 2>/dev/null; then
  exit 0
fi

endpoint=$(cat "$_hook_session_dir/task-endpoint" 2>/dev/null | tr -d '[:space:]')
case "$endpoint" in
  commit|push|pr|ship) ;;
  *) exit 0 ;;
esac

branch=$(git branch --show-current 2>/dev/null || true)
case "$branch" in
  main|master|develop|"")
    hook_stop_block "Requested '$endpoint' endpoint cannot finish on the default or detached branch. Create or switch to the intended feature branch, then retry."
    ;;
esac

# ── Step 0: Uncommitted changes → commit ───────────────────────
# Session-scoped: only block on dirty files this session actually touched.
# Pre-existing dirty work (dep-bumps, WIP from prior sessions, untracked
# scratch files) must not hostage-hold the Stop hook — that was the
# original "hook is super noisy" bug.
_session_dirty=$(hook_session_changed_files)
if [ -n "$_session_dirty" ]; then
  _dirty_count=$(echo "$_session_dirty" | wc -l | tr -d ' ')
  hook_stop_block "${_dirty_count} uncommitted file(s) from this session. Commit the requested scope, then retry."
fi

if [ "$endpoint" = "commit" ]; then
  exit 0
fi

# Need a remote to push to
if ! git remote get-url origin &>/dev/null 2>&1; then
  hook_stop_block "Requested '$endpoint' endpoint needs an origin remote. Configure or identify the intended remote, then retry."
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

if [ "$endpoint" = "push" ]; then
  exit 0
fi

# Need gh CLI for PR/CI operations
if ! command -v gh &>/dev/null; then
  hook_stop_block "Requested '$endpoint' endpoint needs the authenticated gh CLI. Install or authenticate gh, then retry."
fi

# ── Step 2: No PR → create one ──────────────────────────────────

pr_number=$(gh pr list --head "$branch" --json number --jq '.[0].number' 2>/dev/null || true)

if [ -z "$pr_number" ]; then
  hook_stop_block "No PR for '$branch'. Create one NOW: gh pr create --fill — then retry."
fi

# ── Step 3 & 4: CI status ───────────────────────────────────────

pr_data=$(gh pr view "$pr_number" --json statusCheckRollup 2>/dev/null || true)
ci_states=$(echo "$pr_data" | jq -r '.statusCheckRollup[]?.state // empty' 2>/dev/null || true)

if [ -n "$ci_states" ]; then
  if echo "$ci_states" | grep -qi "FAILURE\|ERROR"; then
    if [ "$endpoint" = "ship" ]; then
      hook_stop_block "CI FAILING on PR #$pr_number. Read failures with: gh pr checks $pr_number — fix, commit, push, and re-monitor until green."
    fi
    hook_warn "CI snapshot is failing on PR #$pr_number. Requested PR endpoint is complete; report failures without starting an unrequested fix loop."
  fi

  # CI pending is a wait condition, not a code-quality issue. Emit a
  # warning instead of hostage-holding an ordinary PR request.
  if echo "$ci_states" | grep -qi "PENDING\|EXPECTED\|QUEUED\|IN_PROGRESS"; then
    if ! echo "$ci_states" | grep -qi "SUCCESS"; then
      if [ "$endpoint" = "ship" ]; then
        hook_stop_block "CI still running on PR #$pr_number. Continue the explicit ship loop with: gh pr checks $pr_number --watch."
      else
        hook_warn "CI snapshot is pending on PR #$pr_number. Report it and stop; do not leave a monitor running."
      fi
    fi
  fi
fi

# ── Lifecycle complete ───────────────────────────────────────────
exit 0
