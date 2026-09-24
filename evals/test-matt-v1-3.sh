# Regression coverage for the mattpocock/skills v1.3 graduation (upstream PR #1120).

IMPLEMENT_SPEC="$REPO_ROOT/implement-spec/SKILL.md"
PR="$REPO_ROOT/pr/SKILL.md"
RETRO="$REPO_ROOT/retro/SKILL.md"
ASK_BEN="$REPO_ROOT/ask-ben/SKILL.md"

for skill in implement-spec pr retro; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "vendored v1.3 skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "vendored v1.3 skill has matching name: $skill"
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\"\\./$skill/\"" "Claude plugin registers $skill"
  run_file_eval "$REPO_ROOT/codex-skills/$skill/SKILL.md" "Codex packages $skill"
done

# implement-spec: user-invoked parallel orchestration onto one integration branch.
run_content_eval "$IMPLEMENT_SPEC" "^disable-model-invocation: true$" "implement-spec is user-invoked"
run_content_eval "$REPO_ROOT/codex-skills/implement-spec/agents/openai.yaml" "allow_implicit_invocation: false" \
  "Codex keeps implement-spec explicit-use only"
run_content_eval "$IMPLEMENT_SPEC" "explicit request for delegation" "implement-spec invocation is the delegation consent"
run_content_eval "$IMPLEMENT_SPEC" "single \*\*integration branch\*\*" "implement-spec targets one integration branch"
run_content_eval "$IMPLEMENT_SPEC" "\*\*task graph\*\*.*\*\*frontier\*\*" "implement-spec works the ticket frontier"
run_content_eval "$IMPLEMENT_SPEC" "after the first merge" "implement-spec opens a draft PR only after the first merge"
run_content_eval "$IMPLEMENT_SPEC" "based on the integration branch" "implementers verify their integration base"
run_content_eval "$IMPLEMENT_SPEC" "builds the ticket with \`/tdd\`" "implementers build through tdd"
run_content_eval "$IMPLEMENT_SPEC" "merges the integration branch tip" "implementers merge the integration tip first"
run_content_eval "$IMPLEMENT_SPEC" "run \`/review\` on the integration branch" "implement-spec closes with review"
run_content_eval "$IMPLEMENT_SPEC" "Follow its Issue tracker pointer" "implement-spec resolves the tracker from agent instructions"
if grep -q "setup-matt-pocock-skills\|code-review\|Skill tool" "$IMPLEMENT_SPEC"; then
  echo "  FAIL  implement-spec uses harness skill names"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: implement-spec references upstream-only skills"
else
  echo "  PASS  implement-spec uses harness skill names"
  PASS=$((PASS + 1))
fi

# pr: model-invoked PR-body shape, credited to show-me.
if grep -q '^disable-model-invocation:' "$PR"; then
  echo "  FAIL  pr is model-invoked"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: pr should be model-invoked"
else
  echo "  PASS  pr is model-invoked"
  PASS=$((PASS + 1))
fi
run_content_eval "$PR" "^## Merge Danger$" "pr template has merge danger"
run_content_eval "$PR" "one-way or two-way" "pr makes a door call"
run_content_eval "$PR" "Blast Radius" "pr names the blast radius"
run_content_eval "$REPO_ROOT/pr/CREDITS.md" "Dex Horthy" "pr credits show-me"
run_content_eval "$REPO_ROOT/pr/SUMMARY-VIEWS.md" "runtime control flow as a call tree" "pr keeps the full summary view menu"
run_content_eval "$PR" "SUMMARY-VIEWS\.md" "pr links its summary view menu"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "follow \`/pr\`" "commit-push-pr template builds on pr"
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" "^## Merge danger$" "commit-push-pr template carries merge danger"
if grep -q '^```tsx$' "$REPO_ROOT/show-me/SKILL.md" "$REPO_ROOT/pr/SUMMARY-VIEWS.md"; then
  echo "  FAIL  component trees use text fences"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: a component tree still uses a tsx fence"
else
  echo "  PASS  component trees use text fences"
  PASS=$((PASS + 1))
fi

# retro: user-invoked environment retrospective.
run_content_eval "$RETRO" "^disable-model-invocation: true$" "retro is user-invoked"
run_content_eval "$RETRO" "Classify the violation first" "retro classifies mechanical versus judgement findings"
run_content_eval "$RETRO" "no \*\*guardrail\*\*" "retro flags a repository without guardrails"
run_content_eval "$RETRO" "/hook-audit --retro" "retro points to hook telemetry"
run_content_eval "$REPO_ROOT/hook-audit/REFERENCE.md" "standalone \`/retro\` skill" "hook-audit retro points to the vendored skill"

run_content_eval "$ASK_BEN" "/to-tickets\` \\(parallel: \`/implement-spec\`\\)" "ask-ben routes parallel ticket work"
run_content_eval "$ASK_BEN" "retro \`/retro\`" "ask-ben routes retrospectives"

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
