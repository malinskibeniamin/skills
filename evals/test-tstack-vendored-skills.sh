# Public CLI contracts plus the shipped snapshot and discoverable host guidance.

if python3 "$REPO_ROOT/evals/test-tstack-sync.py" &&
   python3 "$REPO_ROOT/scripts/vendor-tstack.py" --check &&
   bash "$REPO_ROOT/scripts/generate-skill-catalog.sh" --check; then
  echo "  PASS  tstack pin, resources, owner preservation and discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  tstack vendoring contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: tstack vendoring contract"
fi

# These are public prompt-byte contracts, not claims about model adherence.
run_content_eval "$REPO_ROOT/shared/TSTACK.md" 'Honor requested drafts' 'tstack preserves draft-only requests'
run_content_eval "$REPO_ROOT/shared/TSTACK.md" 'Delegation requires an explicit user request' 'tstack review delegation stays opt-in'
run_content_eval "$REPO_ROOT/shared/TSTACK.md" 'not a readiness gate' 'tstack watcher cannot certify merge readiness'
run_content_eval "$REPO_ROOT/full-send/SKILL.md" 'TSTACK.md#full-send' 'full-send retains its owner and composes tstack'
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" 'tstack-skills/file-pr/SKILL.md' 'publication reaches tstack PR guidance'
run_content_eval "$REPO_ROOT/shared/delivery-workflow.md" 'tstack-skills/babysit-pr/SKILL.md' 'delivery reaches tstack monitoring guidance'
run_content_eval "$REPO_ROOT/agent-watchdog/references/takeover.md" 'tstack-skills/takeover/SKILL.md' 'watchdog reaches contributor-credit guidance'
run_content_eval "$REPO_ROOT/resolve-pr-feedback/SKILL.md" 'tstack-skills/leaving-pr-comments/SKILL.md' 'feedback reaches attributed-comment guidance'
