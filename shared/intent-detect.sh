#!/bin/bash
set -euo pipefail

# UserPromptSubmit hook: detect intent from prompt keywords and inject
# workflow directives as additionalContext. Runs alongside user-prompt-context.sh.
# Target: <30ms (keyword grep cascade).

input=$(cat)
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')

if [ "$hook_event" != "UserPromptSubmit" ]; then
  exit 0
fi

prompt=$(echo "$input" | jq -r '.prompt // empty' | tr '[:upper:]' '[:lower:]')

if [ -z "$prompt" ]; then
  exit 0
fi

directives=""

# ── Test writing ─────────────────────────────────────────────────

if echo "$prompt" | grep -qiE 'write.*test|add.*test|create.*test|test for|spec for|\btdd\b|red.green'; then
  directives="$directives\n[TDD] RED→GREEN→REFACTOR. No prod w/o failing test. Condition waits, no setTimeout. --detectAsyncLeaks."
fi

# ── Component/UI creation ────────────────────────────────────────

if echo "$prompt" | grep -qiE 'create.*component|new.*component|build.*form|add.*page|add.*dialog|add.*modal|add.*view'; then
  directives="$directives\n[COMPONENT] @/components/ui/ only. kbd-nav, aria-labels, test co-located. DS tokens, no inline."
fi

# ── Bug fix / debugging ─────────────────────────────────────────

if echo "$prompt" | grep -qiE 'fix.*bug|debug|broken|not working|error.*in|crash|triage|investigate|regression'; then
  directives="$directives\n[TRIAGE] reproduce(test)→analyze→hypothesize(one)→fix ROOT CAUSE. /codex:rescue if available."
fi

# ── PR/review ────────────────────────────────────────────────────

if echo "$prompt" | grep -qiE 'create.*pr|open.*pr|pull request|push.*branch|submit.*review'; then
  # Only suggest @claude review if we haven't already this session
  review_marker="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}/review-requested"
  if [ -f "$review_marker" ]; then
    directives="$directives\n[PR] quality:gate + type:check first. Conventional commits. (Review already requested.)"
  else
    directives="$directives\n[PR] quality:gate + type:check first. After: @claude review. Conventional commits."
    touch "$review_marker" 2>/dev/null || true
  fi
fi

# ── Refactoring ──────────────────────────────────────────────────

if echo "$prompt" | grep -qiE '\brefactor\b|extract.*into|move.*to|split.*into|consolidate|clean.?up'; then
  directives="$directives\n[REFACTOR] Tests BEFORE (baseline). Small steps, test each. No barrel imports. type:check+tests after."
fi

# ── E2E testing ──────────────────────────────────────────────────

if echo "$prompt" | grep -qiE '\be2e\b|playwright|end.to.end|browser test|user workflow|acceptance test'; then
  directives="$directives\n[E2E] Base fixture (axe-core). makeAxeBuilder(). data-testid. Explicit waits, no hard delays."
fi

# ── Verification / testing in browser ────────────────────────────

if echo "$prompt" | grep -qiE 'test.*browser|check.*browser|verify.*works|test the flow|test.*ui|check.*page|verify.*page|does it work|try it|smoke test'; then
  directives="$directives\n[VERIFY] Self-verify (browser tools/Playwright). Never ask user to test. Confirm BEFORE reporting."
fi

# ── General: never delegate verification to user ─────────────────
# Only fire on substantive bug fixes, not trivial ("fix indentation", "fix typo")

if echo "$prompt" | grep -qiE 'fix.*bug|broken|not working|blank.*screen|error.*page|crash|regression'; then
  directives="$directives\n[SELF-VERIFY] Verify fix yourself. Never ask user to check."
fi

# ── Implementation work → full lifecycle mandate ─────────────────
# Detect: build/implement/add/create feature work (not just tests/reviews)
# Inject the full lifecycle sequence so Claude auto-follows every step.

if echo "$prompt" | grep -qiE 'build.*feature|implement|add.*support|create.*endpoint|add.*page|add.*route|add.*hook|add.*component|new.*feature|wire.*up|integrate|set.*up'; then
  directives="$directives\n[LIFECYCLE] MANDATORY sequence: (1) Plan approach (2) /tdd for every new file — failing test first (3) Implement minimal code to pass (4) /simplify changed code (5) Self-verify with browser/tests (6) /commit-push → PR → Monitor CI → fix failures → request review. Hooks enforce this — do NOT skip steps."
fi

# ── Risk tier (informs auto mode confidence) ────────────────────
# low: tests, components, refactoring — fully guarded by hooks
# medium: bug fixes, debugging — may need exploratory actions
# high: PRs, deploys, infra — touches shared/external systems

risk=""

if echo "$prompt" | grep -qiE 'fix.*bug|debug|broken|not working|crash|triage|investigate|regression'; then
  risk="medium"
fi

if echo "$prompt" | grep -qiE 'create.*pr|open.*pr|pull request|push|deploy|migration|drop|delete.*branch|force'; then
  risk="high"
fi

# Only emit risk tier for medium/high — low is default, no need to announce
if [ -n "$risk" ]; then
  directives="$directives\n[RISK:$risk]"
fi

# ── Output ───────────────────────────────────────────────────────

if [ -n "$directives" ]; then
  escaped=$(printf '%s' "$directives" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":$escaped}}" >&2
fi

exit 0
