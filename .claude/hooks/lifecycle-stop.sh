#!/bin/bash
set -eo pipefail

# Escape hatch: when Claude is already responding to a Stop block, do not
# block again -- prevents infinite hostage loops (audit cluster 1).
_sha_in=$(cat); if printf '%s' "$_sha_in" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then exit 0; fi


# Stop hook: enforce delivery completion with auto-remediation.
# Ensures session changes are committed, pushed, PR'd, CI-checked, and
# review-requested. Instead of just blocking, prescribes exact actions.
#
# Lifecycle gates (sequential):
#   0. Uncommitted changes? → prescribe: run /commit-push
#   1. Unpushed commits? → prescribe: git push
#   2. No PR? → prescribe: gh pr create
#   3. CI failing? → prescribe: fix and push
#   4. CI pending? → prescribe: monitor with Monitor tool
#   5. No reviewer? → prescribe: request review
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
# Defense-in-depth: drop any path that points at a secondary worktree
# (subagent scope), lives outside the current worktree (sibling
# worktree / session-id collision), no longer exists, or is not part
# of the current branch diff (stale tracker entry from a prior session,
# rolled-back edit, or subagent that never landed). Prevents false
# "untested source" blocks on sessions that did no real editing.
if [ -n "$_session_code" ] && type _hook_in_secondary_worktree &>/dev/null; then
  # Branch-local change set: files currently dirty OR committed since
  # branch-off. If a tracked entry isn't in this set, it's stale.
  _repo_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
  _branch_changes=""
  for _base in origin/main origin/master main master; do
    if git rev-parse --verify "$_base" &>/dev/null; then
      _branch_changes=$(
        { git diff --name-only "$_base...HEAD" 2>/dev/null
          git diff --name-only HEAD 2>/dev/null
          git ls-files --others --exclude-standard 2>/dev/null; } | sort -u
      )
      break
    fi
  done
  _filtered=""
  while IFS= read -r _p; do
    [ -z "$_p" ] && continue
    [ -e "$_p" ] || continue
    if _hook_in_secondary_worktree "$_p"; then
      continue
    fi
    if type _hook_file_outside_current_worktree &>/dev/null \
      && _hook_file_outside_current_worktree "$_p"; then
      continue
    fi
    if [ -n "$_branch_changes" ] && [ -n "$_repo_root" ]; then
      # Resolve symlinks before stripping (macOS /var → /private/var)
      _p_real=$(cd "$(dirname "$_p")" 2>/dev/null && echo "$(pwd -P)/$(basename "$_p")" || echo "$_p")
      _rel="${_p_real#"$_repo_root"/}"
      if ! grep -Fxq -- "$_rel" <<< "$_branch_changes"; then
        continue
      fi
    fi
    _filtered="${_filtered}${_p}"$'\n'
  done <<< "$_session_code"
  _session_code="${_filtered%$'\n'}"
fi
if [ -z "$_session_code" ]; then
  exit 0
fi

# ── Step 0: Uncommitted changes → commit ───────────────────────
# Session-scoped: only block on dirty files this session actually touched.
# Pre-existing dirty work (dep-bumps, WIP from prior sessions, untracked
# scratch files) must not hostage-hold the Stop hook — that was the
# original "hook is super noisy" bug.
_session_dirty=$(hook_session_changed_files)
if [ -n "$_session_dirty" ]; then
  _dirty_count=$(echo "$_session_dirty" | wc -l | tr -d ' ')
  hook_stop_block "${_dirty_count} uncommitted file(s) from this session. Run /commit-push-pr --no-pr to commit and push. Then retry."
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

  # CI pending is a wait condition, not a code-quality issue. Emit a
  # warn (exit 0) instead of blocking: hostage-holding the session
  # across long CI runs is noise, and the user can stream status with
  # Monitor if they actively want to watch. Failures still block.
  if echo "$ci_states" | grep -qi "PENDING\|EXPECTED\|QUEUED\|IN_PROGRESS"; then
    if ! echo "$ci_states" | grep -qi "SUCCESS"; then
      hook_warn "CI still running on PR #$pr_number. Stream with: gh pr checks $pr_number --watch (via Monitor tool) if you want live status."
    fi
  fi
fi

# ── Step 5: Review requested → assign reviewer ──────────────────

reviewer_count=$(echo "$pr_data" | jq -r '.reviewRequests | length' 2>/dev/null || echo "0")

# Advisory only (audit: Stop hooks gate code properties, not the org chart --
# a solo repo must never be hostage to an unassignable reviewer).
if [ "$reviewer_count" = "0" ] || [ -z "$reviewer_count" ]; then
  echo '{"suppressOutput":true,"systemMessage":"CI green, no reviewer on the PR yet -- consider: gh pr edit '"$pr_number"' --add-reviewer <user>."}'
fi

# ── Lifecycle complete ───────────────────────────────────────────
exit 0
