#!/bin/bash
set -eo pipefail

input=$(cat)

# Stop hook: enforce the delivery endpoint resolved from the user's request.
# Ordinary action work defaults to push; explicit local/no-delivery intent stops locally.
#
# Lifecycle gates (sequential):
#   commit → commit, stop
#   push   → commit + push, stop
#   pr     → verify + commit + push + PR + one CI snapshot, stop
#   ship   → full PR + CI remediation loop
#   All pass → allow finish

source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true
_hook_input="$input"
hook_adopt_stdin_session

# ── Quick exits (most sessions hit one of these) ────────────────

endpoint=$(cat "$_hook_session_dir/task-endpoint" 2>/dev/null | tr -d '[:space:]')
case "$endpoint" in
  commit|push|pr|ship) ;;
  *) exit 0 ;;
esac

# A real blocker or reserved decision may end an incomplete turn. A corrected
# Stop event still owes delivery; stop_hook_active alone is not proof of it.
last_line=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null \
  | awk 'NF { line=$0 } END { print line }' || true)
case "$last_line" in
  "🔴 blocked — "*|"🟡 awaiting decision — "*) exit 0 ;;
esac

# Missing delivery is a hard completion failure, not a soft quality reminder.
# The explicit incomplete statuses above remain the escape for real blockers.
HOOK_STOP_BLOCK_CAP_GUARD=0

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
  if ! hook_has_session_tracking; then
    hook_stop_block "${_dirty_count} uncommitted file(s) without ownership tracking. Identify and commit only the requested scope; preserve unrelated work. If ownership is unclear, report the reserved decision instead of completion."
  fi
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
  _divergence=$(git rev-list --left-right --count "origin/$branch...HEAD" 2>/dev/null || true)
  _remote_only=$(printf '%s' "$_divergence" | awk '{print $1}')
  _local_only=$(printf '%s' "$_divergence" | awk '{print $2}')
  if [ "${_remote_only:-0}" -gt 0 ] && [ "${_local_only:-0}" -gt 0 ]; then
    hook_stop_block "Branch '$branch' diverged: ahead $_local_only, behind $_remote_only. For current user-owned rewritten history, run: git push --force-with-lease origin $branch — then retry. If remote commits may be foreign or concurrent, reconcile instead of overwriting them."
  fi
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

# Cached origin refs can survive a failed push or remote branch deletion.
# Confirm the actual remote head before treating delivery as complete.
remote_status=0
remote_ref=$(git ls-remote --exit-code origin "refs/heads/$branch" 2>/dev/null) \
  || remote_status=$?
case "$remote_status" in
  0) ;;
  2)
    hook_stop_block "Branch '$branch' is not published. Run: git push -u origin $branch — then retry."
    ;;
  *)
    hook_stop_block "Cannot verify origin for '$branch'. Resolve remote access and retry, or report the external blocker with 🔴 blocked —; do not claim delivery complete."
    ;;
esac
remote_head=$(printf '%s' "$remote_ref" | awk '{print $1}')
if [ "$remote_head" != "$(git rev-parse HEAD)" ]; then
  hook_stop_block "Remote head for '$branch' does not match HEAD. Fetch and reconcile the current feature branch, then push the requested scope and retry. Preserve foreign or concurrent remote commits."
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
