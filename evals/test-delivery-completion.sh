# Real Stop events must verify delivery even after the working tree is clean.
_delivery_root=$(mktemp -d)
_delivery_repo="$_delivery_root/repo"
_delivery_remote="$_delivery_root/origin.git"
_delivery_sid="delivery-completion-eval-$$"
_delivery_session="/tmp/hook-session-$_delivery_sid"
trap 'rm -rf "$_delivery_root" "$_delivery_session"' EXIT

git init --bare -q "$_delivery_remote"
git init -q -b main "$_delivery_repo"
git -C "$_delivery_repo" config user.email eval@example.com
git -C "$_delivery_repo" config user.name Eval
git -C "$_delivery_repo" remote add origin "$_delivery_remote"
printf 'base\n' > "$_delivery_repo/file.txt"
git -C "$_delivery_repo" add file.txt
git -C "$_delivery_repo" commit -qm base
git -C "$_delivery_repo" push -qu origin main
git -C "$_delivery_repo" checkout -qb feature/delivery-completion
printf 'requested change\n' >> "$_delivery_repo/file.txt"
git -C "$_delivery_repo" commit -qam change

# Use the actual dispatcher and delivery hook, not stubbed Git responses.
mkdir -p "$_delivery_repo/.claude/hooks" "$_delivery_session"
for _delivery_script in stop-dispatch.sh lifecycle-stop.sh completion-contract-stop.sh; do
  ln -s "$REPO_ROOT/.claude/hooks/$_delivery_script" \
    "$_delivery_repo/.claude/hooks/$_delivery_script"
done
ln -s "$REPO_ROOT/shared" "$_delivery_repo/shared"
printf '%s\n' '{"x-stop-dispatch":["lifecycle-stop.sh","completion-contract-stop.sh"]}' \
  > "$_delivery_repo/skill-manifest.json"
printf '.claude/\nshared\nskill-manifest.json\n' >> "$_delivery_repo/.git/info/exclude"
: > "$_delivery_session/dirty-files-baseline"
printf 'push\n' > "$_delivery_session/task-endpoint"

_delivery_payload=$(jq -nc --arg sid "$_delivery_sid" \
  --arg last $'Intent: deliver the change | Impact: work is available remotely\n🟢 done — focused tests pass' \
  '{hook_event_name:"Stop",session_id:$sid,last_assistant_message:$last}')
pushd "$_delivery_repo" >/dev/null
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "clean committed work still requires a push at the Stop entrypoint" "unpushed"
if [ ! -e "$_delivery_session/task-completed" ]; then
  echo "  PASS  blocked delivery is not recorded as a completed task"
  PASS=$((PASS + 1))
else
  echo "  FAIL  blocked delivery is recorded as a completed task"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: blocked delivery completion marker"
fi
CLAUDE_SESSION_ID= CODEX_SESSION_ID= run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "payload-only session retains the requested delivery endpoint" "unpushed"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" \
  "$(printf '%s' "$_delivery_payload" | jq '.stop_hook_active = true')" 2 \
  "a repeated successful Stop cannot waive an unpushed commit" "unpushed"
printf '99\n' > "$_delivery_session/stop-block-count"
CLAUDE_SESSION_ID="$_delivery_sid" HOOK_STOP_BLOCK_CAP_GUARD=1 run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "exhausting the soft-gate budget cannot mark unpushed work complete" "unpushed"
rm "$_delivery_session/stop-block-count"
rm "$_delivery_session/dirty-files-baseline"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "missing file-touch tracking cannot waive remote delivery" "unpushed"
: > "$_delivery_session/dirty-files-baseline"
git -C "$_delivery_repo" push -qu origin feature/delivery-completion
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 0 \
  "pushing the requested commit permits completion"
rm "$_delivery_session/task-completed"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" \
  "$(printf '%s' "$_delivery_payload" | jq '.stop_hook_active = true')" 0 \
  "a corrected Stop permits verified remote delivery"
if [ -e "$_delivery_session/task-completed" ]; then
  echo "  PASS  successful delivery retry records task completion"
  PASS=$((PASS + 1))
else
  echo "  FAIL  successful delivery retry loses task completion"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: successful delivery retry completion marker"
fi
git --git-dir="$_delivery_remote" update-ref -d refs/heads/feature/delivery-completion
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "a stale origin tracking ref is not proof of remote publication" "not published"
git -C "$_delivery_repo" push -q origin feature/delivery-completion
git --git-dir="$_delivery_remote" update-ref refs/heads/feature/delivery-completion \
  "$(git -C "$_delivery_repo" rev-parse origin/main)"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "a different actual remote head requires reconciliation" "does not match HEAD"
git -C "$_delivery_repo" push -q origin feature/delivery-completion
git -C "$_delivery_repo" remote set-url origin "$_delivery_root/unavailable.git"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "unavailable remote access is not delivery evidence" "Cannot verify origin"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" \
  "$(printf '%s' "$_delivery_payload" | jq \
    '.last_assistant_message = "Intent: deliver the change | Impact: not established\n🔴 blocked — origin unavailable; restore remote access"')" 0 \
  "a genuine external blocker can be reported without a successful handoff"
git -C "$_delivery_repo" remote set-url origin "$_delivery_remote"
printf 'uncommitted requested work\n' > requested.txt
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" \
  "$(printf '%s' "$_delivery_payload" | jq '.stop_hook_active = true')" 2 \
  "a repeated Stop still requires committing session-owned files" "uncommitted"
rm "$_delivery_session/dirty-files-baseline"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "missing ownership tracking cannot claim uncommitted work is delivered" "uncommitted"
printf 'requested.txt\n' > "$_delivery_session/dirty-files-baseline"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 0 \
  "pre-existing unrelated dirty work remains outside the requested scope"
printf '%s\n' "$_delivery_repo/requested.txt" > "$_delivery_session/session-touched-files"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "adopting a pre-existing dirty file still requires committing it" "uncommitted"
rm "$_delivery_session/session-touched-files"
: > "$_delivery_session/dirty-files-baseline"
printf 'local\n' > "$_delivery_session/task-endpoint"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 0 \
  "an explicit local-only endpoint remains respected"
git add requested.txt
git commit -qm 'requested follow-up'
printf 'commit\n' > "$_delivery_session/task-endpoint"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 0 \
  "an explicit commit-only endpoint does not require a push"
printf '%s\n' "$_delivery_repo/requested.txt" > "$_delivery_session/session-touched-files"
printf 'unrelated local work\n' > unrelated.txt
printf 'unrelated.txt\n' > "$_delivery_session/dirty-files-baseline"
printf 'push\n' > "$_delivery_session/task-endpoint"
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 2 \
  "recovered work cannot stop after a local commit" "unpushed"
git push -q origin feature/delivery-completion
CLAUDE_SESSION_ID="$_delivery_sid" run_hook_eval \
  "$_delivery_repo/.claude/hooks/stop-dispatch.sh" "$_delivery_payload" 0 \
  "recovered commit permits completion only after remote publication"
if [ "$(git --git-dir="$_delivery_remote" rev-parse refs/heads/feature/delivery-completion)" = "$(git rev-parse HEAD)" ] \
  && [ "$(cat unrelated.txt)" = 'unrelated local work' ] \
  && [ -z "$(git ls-files unrelated.txt)" ]; then
  echo "  PASS  recovery reaches the actual remote without staging unrelated work"
  PASS=$((PASS + 1))
else
  echo "  FAIL  recovery loses remote evidence or unrelated work"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: scoped recovery publication"
fi
popd >/dev/null

printf 'local\n' > "$_delivery_session/task-endpoint"
_draft_prompt=$'"Changes local, uncommitted, not pushed."\n\nnever allow this to happen. we never want things to only be on a worktree or local.\n\ndraft PR please.'
printf '%s' "$(jq -nc --arg sid "$_delivery_sid" --arg prompt "$_draft_prompt" \
  '{hook_event_name:"UserPromptSubmit",session_id:$sid,prompt:$prompt}')" \
  | CLAUDE_SESSION_ID="$_delivery_sid" "$REPO_ROOT/.claude/hooks/intent-detect.sh" >/dev/null
if [ "$(cat "$_delivery_session/task-endpoint")" = "pr" ]; then
  echo "  PASS  draft PR shorthand replaces a prior local endpoint"
  PASS=$((PASS + 1))
else
  echo "  FAIL  draft PR shorthand leaves a prior local endpoint"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: draft PR shorthand endpoint"
fi
