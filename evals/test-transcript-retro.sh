# Evals for skill fixes mined from 90 days of Claude and Codex transcripts
# (2026-06-29 to 2026-09-27; 2641 Codex and 261 Claude sessions).

# 117 "no more questions" / "just do it" turns across 112 sessions; grilling was
# loaded before 76 of them, often asking reversible questions it had already
# answered with **Recommended:**.
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "confident, reversible \*\*Recommended:\*\*" \
  "grilling adopts confident reversible recommendations instead of asking"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "no more questions" \
  "grilling honors a stop-asking signal"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "rest of the session" \
  "grilling stop-asking signal persists for the session"

# 29 corrections about added dependencies, overrides, resolutions, and patches.
run_content_eval "$REPO_ROOT/upgrade-dependency/SKILL.md" "Manifest budget" \
  "upgrade-dependency defines a manifest budget"
run_content_eval "$REPO_ROOT/upgrade-dependency/SKILL.md" "overrides/resolutions/patches" \
  "upgrade-dependency justifies every new override, resolution, or patch"

# 26 requests to keep internal names out of public commits and PRs.
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "visibility" \
  "commit-push-pr checks repository visibility before publishing"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "internal org, repo, product, person" \
  "commit-push-pr scrubs internal names from public artifacts"

# TypeScript 7 moved back to tsc; the stop-hook diagram must not advertise tsgo.
if grep -q 'typecheck-stop.sh\\ntsgo' "$REPO_ROOT/README.md"; then
  echo "  FAIL  README hook diagram still says typecheck-stop runs tsgo"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: README advertises tsgo"
else
  echo "  PASS  README hook diagram names the tsc type check"
  PASS=$((PASS + 1))
fi
