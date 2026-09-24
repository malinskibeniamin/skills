# Regression coverage for the mattpocock/skills v1.3 graduation (upstream PR #1120).

HOOK_AUDIT_REF="$REPO_ROOT/hook-audit/REFERENCE.md"
PR_REF="$REPO_ROOT/commit-push-pr/REFERENCE.md"
SWARM="$REPO_ROOT/swarm/SKILL.md"
ASK_BEN="$REPO_ROOT/ask-ben/SKILL.md"

# retro -> hook-audit --retro.
run_content_eval "$HOOK_AUDIT_REF" "own check scripts and CI workflow first" \
  "retro reads existing checks before proposing new ones"
run_content_eval "$HOOK_AUDIT_REF" "finding in its own right" \
  "retro flags a repository without guardrails"
run_content_eval "$HOOK_AUDIT_REF" "Classify first: a mechanical" \
  "retro turns mechanical violations into deterministic checks"
run_content_eval "$HOOK_AUDIT_REF" "judgment calls no check can replace" \
  "retro keeps written standards for judgment calls"
run_content_eval "$HOOK_AUDIT_REF" "skills/blob/a600ef4b25/skills/engineering/retro/SKILL.md" \
  "retro attribution pins the graduated upstream skill"

# pr -> commit-push-pr body template.
run_content_eval "$PR_REF" "^## Merge danger$" "PR body carries a merge danger section"
run_content_eval "$PR_REF" "Door: <one-way or two-way" "PR body makes a one-way or two-way door call"
run_content_eval "$PR_REF" "Blast radius:" "PR body names the blast radius"
run_content_eval "$PR_REF" "smallest \`/show-me\` view" "PR summary reuses the show-me view menu"
run_content_eval "$PR_REF" "failed before and passes after" \
  "non-visual PR evidence is a before and after test run"
run_content_eval "$PR_REF" "skills/blob/a600ef4b25/skills/engineering/pr/SKILL.md" \
  "PR template attribution pins the upstream pr skill"
if grep -q '^```tsx$' "$REPO_ROOT/show-me/SKILL.md"; then
  echo "  FAIL  show-me component tree uses a text fence"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: show-me component tree still uses a tsx fence"
else
  echo "  PASS  show-me component tree uses a text fence"
  PASS=$((PASS + 1))
fi

# implement-spec -> swarm ticket graph; consent stays with /swarm.
run_content_eval "$SWARM" "^## Ticket graph$" "swarm owns ticket-graph execution"
run_content_eval "$SWARM" "ready frontier.*relaunch" "swarm relaunches the frontier as merges unblock tickets"
run_content_eval "$SWARM" "based on the integration branch" "swarm lanes verify their integration base"
run_content_eval "$SWARM" "merges the integration tip before reporting" \
  "swarm lanes merge the integration tip so integration fast-forwards"
run_content_eval "$SWARM" "\`/go\` owns any PR or ticket closure" "swarm leaves delivery to /go"
run_content_eval "$ASK_BEN" "/to-tickets\` \\(parallel: \`/swarm\`\\)" "ask-ben routes parallel ticket work to swarm"
run_content_eval "$ASK_BEN" "retro \`/hook-audit --retro\`" "ask-ben routes retrospectives to hook-audit"

# Graduated upstream skills are adapted into existing owners, not registered.
for adapted in implement-spec pr retro; do
  if [ -e "$REPO_ROOT/$adapted/SKILL.md" ] || grep -q "\"./$adapted/\"" "$REPO_ROOT/.claude-plugin/plugin.json"; then
    echo "  FAIL  graduated Matt skill folds into an existing owner: $adapted"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: graduated Matt skill registered separately: $adapted"
  else
    echo "  PASS  graduated Matt skill folds into an existing owner: $adapted"
    PASS=$((PASS + 1))
  fi
done

# resolving-merge-conflicts removed upstream; versioned docs snapshots keep its page.
if [ -e "$REPO_ROOT/resolving-merge-conflicts" ] || [ -e "$REPO_ROOT/codex-skills/resolving-merge-conflicts" ] ||
  grep -q '"\./resolving-merge-conflicts/"' "$REPO_ROOT/.claude-plugin/plugin.json" ||
  grep -q "resolving-merge-conflicts" "$ASK_BEN" \
    "$REPO_ROOT/scripts/generate-skill-catalog.sh" "$REPO_ROOT/docs-site/generate-skill-diagrams.ts"; then
  echo "  FAIL  resolving-merge-conflicts is unregistered everywhere"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: resolving-merge-conflicts still registered"
else
  echo "  PASS  resolving-merge-conflicts is unregistered everywhere"
  PASS=$((PASS + 1))
fi
run_file_eval "$REPO_ROOT/docs-site/content/v4.38.0/skills/resolving-merge-conflicts.md" \
  "released docs snapshot keeps the resolving-merge-conflicts page"
run_file_eval "$REPO_ROOT/docs-site/public/diagrams/skills/resolving-merge-conflicts.svg" \
  "released docs snapshot keeps the resolving-merge-conflicts diagram"
