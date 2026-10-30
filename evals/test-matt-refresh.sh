# Full importer and published prompt/discovery contracts; no model calls.
if python3 "$REPO_ROOT/evals/test-matt-sync.py" &&
   python3 "$REPO_ROOT/scripts/vendor-mattpocock.py" --check &&
   bash "$REPO_ROOT/scripts/generate-skill-catalog.sh" --check; then
  echo "  PASS  complete pinned Matt inventory, resources, owners and discovery"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Matt refresh/distribution contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Matt refresh/distribution contract"
fi

run_content_eval "$REPO_ROOT/implement-spec/SKILL.md" 'fresh.*implementer.*each ticket' \
  "spec implementation starts a fresh implementer for each ticket"
run_content_eval "$REPO_ROOT/work-automation-kit/REFERENCE.md" 'CONTEXT.md.*CONTEXT-MAP.md' \
  "setup recognizes legacy domain documents"
run_content_eval "$REPO_ROOT/work-automation-kit/REFERENCE.md" 'gh repo view.*glab repo view' \
  "setup verifies the selected hosted tracker is reachable"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-github.md" 'already-closed.*drops|drops.*already-closed' \
  "GitHub resolution retains explanations on already-closed issues"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-github.md" 'gh repo view --json nameWithOwner' \
  "GitHub creation verifies the fork target"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-gitlab.md" 'glab mr list --output json' \
  "GitLab MR listing uses its supported output flag"
run_content_eval "$REPO_ROOT/pr/SKILL.md" 'vendor/mattpocock/upstream/skills/engineering/pr/' \
  "local pr retains a direct provenance pointer"
