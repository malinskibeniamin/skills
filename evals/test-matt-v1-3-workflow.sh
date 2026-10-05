# Public instruction contracts for the v1.3 dependency-loading adaptation.

MECHANICS="$REPO_ROOT/writing-for-agents/SKILL-MECHANICS.md"
LIFECYCLE="$REPO_ROOT/development-lifecycle/SKILL.md"
DELIVERY="$REPO_ROOT/commit-push-pr/SKILL.md"

run_content_eval "$MECHANICS" 'invoke each.*separately' "Claude loads each dependency separately"
run_content_eval "$MECHANICS" 'canonical.*SKILL\.md.*completely' "Codex reads complete canonical guidance"
run_content_eval "$MECHANICS" 'already loaded.*current context' "loading reuses current guidance"
run_content_eval "$MECHANICS" 'user-invoked.*recommend.*human' "dependency loading preserves human-only skills"
run_content_eval "$LIFECYCLE" 'SKILL-MECHANICS.md#loading-dependencies' "lifecycle loads its invocation contract"
run_content_eval "$LIFECYCLE" 'Load.*tdd/SKILL.md' "meaningful behavior explicitly loads TDD"
run_content_eval "$DELIVERY" 'Load.*quantify-impact/SKILL.md.*pr/SKILL.md' "PR publication explicitly loads impact and PR guidance"
run_content_eval "$REPO_ROOT/implement-spec/SKILL.md" 'approved spec.*blocker edges.*independently verifiable' "whole-spec delegation has a selective fit"
run_content_eval "$REPO_ROOT/development-lifecycle/REFERENCE.md" '[Ss]uggest.*retro.*review-heavy' "retro is suggested at an evidence-triggered boundary"
run_content_eval "$REPO_ROOT/development-lifecycle/REFERENCE.md" 'next similar task.*same.*failure' "retro measures a concrete follow-up rather than assumed gains"

# Existing invocation metadata is the permission boundary, not a slash mention.
for skill in retro implement-spec work-automation-kit; do
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" '^disable-model-invocation: true$' "human-only boundary remains: $skill"
done
