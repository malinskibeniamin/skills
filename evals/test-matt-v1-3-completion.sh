# Published skill instructions are the public artifact, not proxies for runtime code.
# Preserve the release's invocation and human-selection boundaries in shipped guidance.

for skill in diagnosing-bugs grilling improve-codebase-architecture tdd to-spec \
  to-tickets triage wayfinder implement-spec retro review codebase-design wizard handoff; do
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" 'Call the Skill tool' \
    "v1.3 dependency calls are explicit: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" 'SKILL-MECHANICS.md#loading-dependencies' \
    "v1.3 dependency calls have a host-neutral fallback: $skill"
done

run_content_eval "$REPO_ROOT/retro/SKILL.md" '[Ww]ait.*user.*select|[Uu]ntil.*user.*select' \
  "retro waits for the user's selection before changing the environment"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" 'fix.*retro|retro.*fix' \
  "router recommends retro after a bug fix"
run_content_eval "$REPO_ROOT/implement-spec/SKILL.md" 'requested.*draft|draft.*requested' \
  "whole-spec implementation preserves a requested draft endpoint"

if grep -qE 'post-mortem|/improve-codebase-architecture' "$REPO_ROOT/diagnosing-bugs/SKILL.md"; then
  echo "  FAIL  diagnosis cleanup no longer hands off to a user-invoked skill"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: stale diagnosis post-mortem handoff"
else
  echo "  PASS  diagnosis cleanup no longer hands off to a user-invoked skill"
  PASS=$((PASS + 1))
fi
