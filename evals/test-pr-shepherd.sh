# Evals for the stateful, single-sweep PR shepherd.

SKILL="$REPO_ROOT/pr-shepherd/SKILL.md"
STATE_HELPER="$REPO_ROOT/pr-shepherd/scripts/state.sh"

run_file_eval "$SKILL" "pr-shepherd skill exists"
run_file_eval "$STATE_HELPER" "pr-shepherd state helper exists"
run_executable_eval "$STATE_HELPER" "pr-shepherd state helper is executable"

run_content_eval "$SKILL" '^name: pr-shepherd$' "pr-shepherd has matching name"
run_content_eval "$SKILL" 'one (idempotent )?sweep|single sweep' \
  "pr-shepherd performs one sweep"
run_content_eval "$SKILL" 'current repository' \
  "pr-shepherd defaults to the current repository"
run_content_eval "$SKILL" 'HEAD SHA|head SHA|head_sha' \
  "pr-shepherd binds evidence to the PR head"
run_content_eval "$SKILL" 'worktree list --porcelain' \
  "pr-shepherd respects workspace ownership"
run_content_eval "$SKILL" 'git status.*git rev-parse HEAD|git rev-parse HEAD.*git status' \
  "pr-shepherd verifies local cleanliness and head identity"
run_content_eval "$SKILL" 'mergeable,mergeStateStatus|mergeStateStatus,mergeable' \
  "pr-shepherd snapshots merge conflicts"
run_content_eval "$SKILL" 'Never (approve|merge)|never (approve|merge)' \
  "pr-shepherd never auto-approves or merges"
run_content_eval "$SKILL" 'untrusted' \
  "pr-shepherd treats PR text as untrusted"
run_content_eval "$SKILL" 'No background|no background|does not poll|Do not poll' \
  "pr-shepherd avoids persistent polling"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"\./pr-shepherd/"' \
  "Claude plugin registers pr-shepherd"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"pr-shepherd":' \
  "Codex metadata defines pr-shepherd"
run_file_eval "$REPO_ROOT/codex-skills/pr-shepherd/SKILL.md" \
  "generated Codex pr-shepherd proxy exists"
run_file_eval "$REPO_ROOT/codex-skills/pr-shepherd/agents/openai.yaml" \
  "generated Codex pr-shepherd metadata exists"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" '/pr-shepherd' \
  "generated catalog lists pr-shepherd"

if [ -x "$STATE_HELPER" ]; then
  _shepherd_tmp=$(mktemp -d)
  _shepherd_state="$_shepherd_tmp/state.json"
  _shepherd_snapshot="$_shepherd_tmp/snapshot.json"

  cat > "$_shepherd_snapshot" <<'JSON'
[
  {
    "number": 12,
    "url": "https://github.com/acme/app/pull/12",
    "title": "Add dashboard",
    "headRefName": "ben-malinski/UX-12/dashboard",
    "headRefOid": "abc123",
    "updatedAt": "2026-08-05T10:00:00Z",
    "isDraft": false,
    "mergeable": "MERGEABLE",
    "mergeStateStatus": "CLEAN",
    "reviewDecision": "",
    "statusCheckRollup": [
      {"status": "COMPLETED", "conclusion": "SUCCESS", "name": "test"}
    ]
  }
]
JSON

  _first_scan=$(
    "$STATE_HELPER" classify \
      --repo acme/app \
      --state-file "$_shepherd_state" \
      --snapshot "$_shepherd_snapshot"
  )
  if printf '%s' "$_first_scan" | jq -e \
    '.active_count == 1 and .prs[0].classification == "active" and (.prs[0].reasons | index("new_pr"))' \
    >/dev/null; then
    echo "  PASS  unseen PR is active"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  unseen PR is active"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: unseen PR classification"
  fi

  "$STATE_HELPER" acknowledge \
    --repo acme/app \
    --state-file "$_shepherd_state" \
    --snapshot "$_shepherd_snapshot" \
    --pr 12 \
    --review-status pass \
    --dogfood-status pass \
    --threads-status clean >/dev/null

  _quiet_scan=$(
    "$STATE_HELPER" classify \
      --repo acme/app \
      --state-file "$_shepherd_state" \
      --snapshot "$_shepherd_snapshot"
  )
  if printf '%s' "$_quiet_scan" | jq -e \
    '.active_count == 0 and .quiet_count == 1 and .prs[0].classification == "quiet"' \
    >/dev/null; then
    echo "  PASS  acknowledged terminal-good PR becomes quiet"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  acknowledged terminal-good PR becomes quiet"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: acknowledged quiet classification"
  fi

  jq '.[0].headRefOid = "def456" | .[0].updatedAt = "2026-08-05T11:00:00Z"' \
    "$_shepherd_snapshot" > "$_shepherd_tmp/changed.json"
  mv "$_shepherd_tmp/changed.json" "$_shepherd_snapshot"
  _changed_scan=$(
    "$STATE_HELPER" classify \
      --repo acme/app \
      --state-file "$_shepherd_state" \
      --snapshot "$_shepherd_snapshot"
  )
  if printf '%s' "$_changed_scan" | jq -e \
    '.prs[0].classification == "active"
      and (.prs[0].reasons | index("head_changed"))
      and (.prs[0].reasons | index("review_stale"))
      and (.prs[0].reasons | index("dogfood_stale"))
      and (.prs[0].reasons | index("threads_stale"))' >/dev/null; then
    echo "  PASS  new head invalidates review, dogfood, and thread evidence"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  new head invalidates review, dogfood, and thread evidence"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: evidence freshness classification"
  fi

  "$STATE_HELPER" acknowledge \
    --repo acme/app \
    --state-file "$_shepherd_state" \
    --snapshot "$_shepherd_snapshot" \
    --pr 12 \
    --review-status pass \
    --dogfood-status skipped \
    --threads-status deferred \
    --deferred-thread RT_kwDOExample >/dev/null
  _deferred_scan=$(
    "$STATE_HELPER" classify \
      --repo acme/app \
      --state-file "$_shepherd_state" \
      --snapshot "$_shepherd_snapshot"
  )
  if printf '%s' "$_deferred_scan" | jq -e \
    '.active_count == 0 and .deferred_count == 1
      and .prs[0].classification == "deferred"
      and .prs[0].deferred_thread_ids == ["RT_kwDOExample"]' >/dev/null; then
    echo "  PASS  deferred decisions stay visible without repeated work"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  deferred decisions stay visible without repeated work"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: deferred decision classification"
  fi

  jq '.[0].statusCheckRollup = [{"status":"IN_PROGRESS","conclusion":"","name":"test"}]' \
    "$_shepherd_snapshot" > "$_shepherd_tmp/pending.json"
  mv "$_shepherd_tmp/pending.json" "$_shepherd_snapshot"
  _pending_scan=$(
    "$STATE_HELPER" classify \
      --repo acme/app \
      --state-file "$_shepherd_state" \
      --snapshot "$_shepherd_snapshot"
  )
  if printf '%s' "$_pending_scan" | jq -e \
    '.prs[0].classification == "active"
      and .prs[0].ci_state == "pending"
      and (.prs[0].reasons | index("ci_pending"))' >/dev/null; then
    echo "  PASS  pending CI stays active despite prior acknowledgement"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  pending CI stays active despite prior acknowledgement"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: pending CI classification"
  fi

  jq '.repositories["acme/app"].prs["https://github.com/acme/app/pull/99"] = {
        "number": 99,
        "url": "https://github.com/acme/app/pull/99",
        "head_sha": "other",
        "updated_at": "2026-08-05T09:00:00Z",
        "ci_state": "success",
        "review": {"sha": "other", "status": "pass"},
        "dogfood": {"sha": "other", "status": "skipped"},
        "threads": {"status": "clean", "deferred_thread_ids": []}
      }' "$_shepherd_state" > "$_shepherd_tmp/state-with-peer.json"
  mv "$_shepherd_tmp/state-with-peer.json" "$_shepherd_state"
  "$STATE_HELPER" acknowledge \
    --repo acme/app \
    --state-file "$_shepherd_state" \
    --snapshot "$_shepherd_snapshot" \
    --pr 12 \
    --review-status pass \
    --dogfood-status blocked \
    --threads-status clean >/dev/null
  if jq -e '.repositories["acme/app"].prs["https://github.com/acme/app/pull/99"].head_sha == "other"' \
    "$_shepherd_state" >/dev/null; then
    echo "  PASS  limited snapshots do not erase unscanned PR state"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  limited snapshots do not erase unscanned PR state"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: unscanned PR state preservation"
  fi

  mkdir "$_shepherd_state.lock"
  printf '%s\n' "$$" > "$_shepherd_state.lock/pid"
  _locked_exit=0
  "$STATE_HELPER" acknowledge \
    --repo acme/app \
    --state-file "$_shepherd_state" \
    --snapshot "$_shepherd_snapshot" \
    --pr 12 \
    --review-status pass \
    --dogfood-status blocked \
    --threads-status clean >/dev/null 2>&1 || _locked_exit=$?
  if [ "$_locked_exit" -eq 3 ] && [ -f "$_shepherd_state.lock/pid" ] \
    && [ "$(cat "$_shepherd_state.lock/pid")" = "$$" ]; then
    echo "  PASS  concurrent state writers fail without clobbering"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  concurrent state writers fail without clobbering"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: concurrent state writer guard"
  fi
  rm -f "$_shepherd_state.lock/pid"
  rmdir "$_shepherd_state.lock" 2>/dev/null || true

  jq '.[0].statusCheckRollup = [{"status":"COMPLETED","conclusion":"SUCCESS","name":"test"}]
      | .[0].mergeable = "CONFLICTING"
      | .[0].mergeStateStatus = "DIRTY"' \
    "$_shepherd_snapshot" > "$_shepherd_tmp/conflicting.json"
  _conflict_scan=$(
    "$STATE_HELPER" classify \
      --repo acme/app \
      --state-file "$_shepherd_state" \
      --snapshot "$_shepherd_tmp/conflicting.json"
  )
  if printf '%s' "$_conflict_scan" | jq -e \
    '.prs[0].classification == "active"
      and (.prs[0].reasons | index("merge_conflict"))' >/dev/null; then
    echo "  PASS  merge conflicts remain active"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  merge conflicts remain active"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: merge conflict classification"
  fi

  jq '.[0].statusCheckRollup = [{"status":"COMPLETED","conclusion":"SUCCESS","name":"test"}]
      | .[0].mergeable = "MERGEABLE"
      | .[0].mergeStateStatus = "CLEAN"
      | .[0].reviewDecision = "REVIEW_REQUIRED"' \
    "$_shepherd_snapshot" > "$_shepherd_tmp/human-review.json"
  "$STATE_HELPER" acknowledge \
    --repo acme/app \
    --state-file "$_shepherd_state" \
    --snapshot "$_shepherd_tmp/human-review.json" \
    --pr 12 \
    --review-status pass \
    --dogfood-status skipped \
    --threads-status clean >/dev/null
  _human_review_scan=$(
    "$STATE_HELPER" classify \
      --repo acme/app \
      --state-file "$_shepherd_state" \
      --snapshot "$_shepherd_tmp/human-review.json"
  )
  if printf '%s' "$_human_review_scan" | jq -e \
    '.active_count == 0 and .deferred_count == 1
      and .prs[0].classification == "deferred"
      and .prs[0].human_review_required == true' >/dev/null; then
    echo "  PASS  required human approval stays visible without rework"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  required human approval stays visible without rework"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: required human review classification"
  fi

  mkdir "$_shepherd_tmp/shared-state-parent"
  chmod 755 "$_shepherd_tmp/shared-state-parent"
  "$STATE_HELPER" acknowledge \
    --repo acme/app \
    --state-file "$_shepherd_tmp/shared-state-parent/state.json" \
    --snapshot "$_shepherd_tmp/human-review.json" \
    --pr 12 \
    --review-status pass \
    --dogfood-status skipped \
    --threads-status clean >/dev/null
  if [ "$(uname -s)" = "Darwin" ]; then
    _parent_mode=$(stat -f '%Lp' "$_shepherd_tmp/shared-state-parent")
  else
    _parent_mode=$(stat -c '%a' "$_shepherd_tmp/shared-state-parent")
  fi
  if [ "$_parent_mode" = "755" ]; then
    echo "  PASS  state writes do not change existing parent permissions"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  state writes do not change existing parent permissions"
    FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: state parent permission preservation"
  fi

  rm -rf "$_shepherd_tmp"
fi
