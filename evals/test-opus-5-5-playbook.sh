# Opus 5.5 playbook: keep long runs moving, keep task state in a file, name design
# exclusions, and mark unconfirmed research.

run_content_eval "$REPO_ROOT/CLAUDE.md" "offers to continue" \
  "ambient contract rejects non-blocking continuation offers"
run_content_eval "$REPO_ROOT/CLAUDE.md" "status notes beside the next action" \
  "status notes ride with the next action"
run_content_eval "$REPO_ROOT/CLAUDE.md" "task checklist, evidence, and pause triggers" \
  "long runs keep their task checklist in a file"
run_content_eval "$REPO_ROOT/AGENTS.md" "offers to continue" \
  "Codex parity carries the continuation rule"
run_content_eval "$REPO_ROOT/efficient-frontier/SKILL.md" "evidence, stop.*acceptance" \
  "delegated lanes return evidence and the coordinator owns acceptance"
run_content_eval "$REPO_ROOT/research/SKILL.md" "could not confirm.*where you looked" \
  "research marks unconfirmed claims and search locations"
run_content_eval "$REPO_ROOT/read-the-damn-docs/SKILL.md" "could not confirm.*where you looked" \
  "doc checks mark unconfirmed facts and search locations"
run_content_eval "$REPO_ROOT/prototype/UI.md" "cream or off-white background" \
  "UI prototypes name concrete design exclusions"
run_content_eval "$REPO_ROOT/visual-review/REFERENCE.md" "numbered 01 / 02 / 03 section labels" \
  "visual review detects model-default styling"

_pc_tmp=$(mktemp -d)
mkdir -p "$_pc_tmp/.context"
printf -- '- [ ] migrate endpoint\n' > "$_pc_tmp/.context/implementation-notes.md"
_pc_out=$(
  cd "$_pc_tmp" \
    && printf '%s' '{"hook_event_name":"PostCompact","session_id":"opus-playbook-eval-'$$'"}' \
      | CLAUDE_SESSION_ID="opus-playbook-eval-$$" "$REPO_ROOT/.claude/hooks/post-compact-context.sh"
)
if printf '%s' "$_pc_out" | jq -e '.hookSpecificOutput.additionalContext
    | contains(".context/implementation-notes.md") and contains("reread its checklist")' >/dev/null 2>&1; then
  echo "  PASS  compaction sends the model back to its task checklist"
  PASS=$((PASS + 1))
else
  echo "  FAIL  compaction sends the model back to its task checklist"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: post-compact task checklist pointer"
fi
rm -rf "$_pc_tmp" "/tmp/hook-session-opus-playbook-eval-$$"

# Opus 5.5 always thinks and effort is the control. Instruction surfaces must not
# ask for deliberation or for internal reasoning reproduced in the reply.
_deliberation_hits=$(
  grep -nEi \
    'think (hard|harder|carefully|deeply|step[- ]by[- ]step)|ultrathink|(show|reveal|output|reproduce|print) (your|its) (internal )?(reasoning|chain[- ]of[- ]thought|thinking)' \
    "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/AGENTS.md" "$REPO_ROOT"/*/SKILL.md \
    "$REPO_ROOT"/agents/*.md "$REPO_ROOT"/.claude/hooks/*.sh "$REPO_ROOT"/shared/*.sh \
    2>/dev/null || true
)
if [ -z "$_deliberation_hits" ]; then
  echo "  PASS  instruction surfaces carry no deliberation or reasoning-extraction prompts"
  PASS=$((PASS + 1))
else
  echo "  FAIL  instruction surfaces carry deliberation or reasoning-extraction prompts"
  printf '%s\n' "$_deliberation_hits" | head -5
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: deliberation prompt in instruction surface"
fi
