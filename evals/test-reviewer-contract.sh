# Public SubagentStop event contracts, not prompt-token assertions.
review_hook="$REPO_ROOT/.claude/hooks/subagent-stop.sh"
review_tmp=$(mktemp -d)
review_session="review-contract-${review_tmp##*/}"
review_dir="/tmp/hook-session-$review_session"
mkdir -p "$review_dir/active-subagents"
trap 'rm -rf "$review_tmp" "$review_dir"' EXIT

review_clean='{"schema_version":1,"reviewer":"code-reviewer","status":"APPROVED","findings":[],"testing_gaps":[],"simplification_opportunities":[]}'
review_finding='{"title":"Other tenants can read the secret","severity":"P1","file":"src/secrets.ts","line":42,"category":"security","why_it_matters":"Another tenant receives the secret.","scenario":"A tenant supplies a different namespace to the lookup.","evidence":"The lookup uses the requested namespace without authorization.","verification":"Replay the cross-tenant lookup with dummy credentials.","autofix_class":"gated_auto","suggested_fix":"Pin the lookup to the authenticated tenant.","pre_existing":false,"confidence":0.9}'
review_report=$(jq -cn --argjson clean "$review_clean" --argjson finding "$review_finding" '$clean | .status="NEEDS_CHANGES" | .findings=[$finding]')

review_event() {
  jq -cn --arg report "$1" --arg session "$review_session" \
    '{agent_type:"code-reviewer",agent_id:"contract-probe",session_id:$session,last_assistant_message:$report}'
}

for review_state in SKIPPED UNAVAILABLE FAILED; do
  printf 'code-reviewer\n' > "$review_dir/active-subagents/contract-probe"
  review_incomplete=$(jq -cn --arg state "$review_state" \
    '{schema_version:1,reviewer:"code-reviewer",status:$state,reason:"Coverage not completed",findings:[]}')
  run_hook_eval "$review_hook" "$(review_event "$review_incomplete")" 0 \
    "$review_state is recorded without approval" "$review_state"
  if [ ! -f "$review_dir/active-subagents/contract-probe" ]; then
    PASS=$((PASS + 1)); echo "  PASS  $review_state clears the completed agent marker"
  else
    FAIL=$((FAIL + 1)); echo "  FAIL  $review_state leaves a stale active agent"
  fi
done

run_hook_eval "$review_hook" "$(review_event "$review_report")" 0 \
  "a complete evidenced finding is accepted" "P1:1"
if jq -e -s 'map(.status) == ["SKIPPED","UNAVAILABLE","FAILED","NEEDS_CHANGES"] and .[3].findings[0].evidence != null' \
  "$review_dir/review-findings.json" >/dev/null; then
  PASS=$((PASS + 1)); echo "  PASS  stored coverage preserves incomplete states and finding evidence"
else
  FAIL=$((FAIL + 1)); echo "  FAIL  stored coverage lost review states or evidence"
fi

for review_invalid in \
  '.schema_version=2' \
  'del(.schema_version)' \
  '.reviewer="self-reviewer"' \
  'del(.findings)' \
  '.findings={}' \
  '.findings[0].severity="CRITICAL"' \
  '.findings[0].category="invented"' \
  '.findings[0].line=0' \
  '.findings[0].line=1.5' \
  '.findings[0].confidence=1.1' \
  '.findings[0].pre_existing="false"' \
  '.findings[0].autofix_class="execute_now"' \
  '.findings[0].suggested_fix=null' \
  '.findings[0].why_it_matters=" "' \
  'del(.findings[0].scenario)' \
  'del(.findings[0].evidence)' \
  'del(.findings[0].verification)' \
  '.status="APPROVED"' \
  '.status="CONCERNS"' \
  '.testing_gaps="none"'; do
  review_bad=$(printf '%s' "$review_report" | jq -c "$review_invalid")
  run_hook_eval "$review_hook" "$(review_event "$review_bad")" 2 \
    "reject invalid review: $review_invalid"
done

review_bad=$(printf '%s' "$review_clean" | jq -c '.karpathy_checks={"hallucinated-api":"fail"}')
run_hook_eval "$review_hook" "$(review_event "$review_bad")" 2 \
  "a failed critical check cannot approve"

review_bad=$(printf '%s' "$review_clean" | jq -c '.status="UNAVAILABLE" | .reason=" "')
run_hook_eval "$review_hook" "$(review_event "$review_bad")" 2 \
  "unavailable review needs a concrete reason"

run_hook_eval "$review_hook" "$(review_event "$review_clean
$review_clean")" 2 "multiple reports are rejected"

# A rejected report must not clear an active agent or append invalid evidence.
printf 'code-reviewer\n' > "$review_dir/active-subagents/contract-probe"
review_before=$(wc -l < "$review_dir/review-findings.json" 2>/dev/null || echo 0)
run_hook_eval "$review_hook" "$(review_event '{"status":"APPROVED"}')" 2 \
  "an invalid report stays retryable"
review_after=$(wc -l < "$review_dir/review-findings.json" 2>/dev/null || echo 0)
if [ -f "$review_dir/active-subagents/contract-probe" ] && [ "$review_before" = "$review_after" ]; then
  PASS=$((PASS + 1)); echo "  PASS  invalid reports preserve the active marker and log"
else
  FAIL=$((FAIL + 1)); echo "  FAIL  invalid reports changed completion evidence"
fi

# Installed hooks must use the bundled contract, not the consumer checkout.
mkdir -p "$review_tmp/agents/references"
printf 'true\n' > "$review_tmp/agents/references/findings-schema.jq"
(
  cd "$review_tmp" || exit 1
  run_hook_eval "$review_hook" "$(review_event "$review_clean")" 0 \
    "review validation works outside the harness checkout" "APPROVED"
  run_hook_eval "$review_hook" "$(review_event '{"status":"APPROVED"}')" 2 \
    "installed hook points to the bundled contract" "$REPO_ROOT/agents/references/findings-schema.md"
  printf '%s %s\n' "$PASS" "$FAIL" > "$review_tmp/counts"
)
read -r PASS FAIL < "$review_tmp/counts"

# The copyable completed-report example is part of the public prompt contract.
review_example=$(awk '/^```json/ {reading=1; next} /^```/ {if (reading) exit} reading' \
  "$REPO_ROOT/agents/references/findings-schema.md")
run_hook_eval "$review_hook" "$(review_event "$review_example")" 0 \
  "the documented completed report is valid" "NEEDS_CHANGES"

# A broken package needs installation repair, not an impossible report retry.
mkdir -p "$review_tmp/bundle/.claude/hooks"
cp "$review_hook" "$review_tmp/bundle/.claude/hooks/subagent-stop.sh"
run_hook_eval "$review_tmp/bundle/.claude/hooks/subagent-stop.sh" \
  "$(review_event "$review_clean")" 2 \
  "missing bundled validator is diagnosed" "validation contract is missing"

# The observable SubagentStart prompt must not suppress new defects in dirty files.
printf 'src/secrets.ts\n' > "$review_dir/dirty-files-baseline"
(
  cd "$review_tmp" || exit 1
  run_hook_eval "$REPO_ROOT/.claude/hooks/subagent-start.sh" \
    "$(jq -cn --arg session "$review_session" '{agent_type:"code-reviewer",session_id:$session}')" 0 \
    "dirty filenames do not classify every defect as pre-existing" "A dirty filename is not defect provenance"
  printf '%s %s\n' "$PASS" "$FAIL" > "$review_tmp/counts"
)
read -r PASS FAIL < "$review_tmp/counts"
