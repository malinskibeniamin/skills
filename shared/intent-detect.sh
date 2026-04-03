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
  directives="$directives\n[TDD] Iron law: no production code without failing test first. RED (failing test) → GREEN (minimal code) → REFACTOR (clean up). Use condition-based waiting, never setTimeout. Run --detectAsyncLeaks after."
fi

# ── Component/UI creation ────────────────────────────────────────

if echo "$prompt" | grep -qiE 'create.*component|new.*component|build.*form|add.*page|add.*dialog|add.*modal|add.*view'; then
  directives="$directives\n[COMPONENT] Use @/components/ui/ (never raw HTML). Verify: keyboard navigable, aria-labels on icon buttons, aria-labelledby on dialogs. Co-locate a test file. Use design tokens (Tailwind), never inline styles or raw hex."
fi

# ── Bug fix / debugging ─────────────────────────────────────────

if echo "$prompt" | grep -qiE 'fix.*bug|debug|broken|not working|error.*in|crash|triage|investigate|regression'; then
  directives="$directives\n[TRIAGE] 4 phases: reproduce (failing test) → analyze (find working examples) → hypothesize (one theory at a time) → fix at ROOT CAUSE (not symptom). Add defense-in-depth validation. If /codex:rescue available, cross-check hypothesis with Codex before implementing."
fi

# ── PR/review ────────────────────────────────────────────────────

if echo "$prompt" | grep -qiE 'create.*pr|open.*pr|pull request|push.*branch|submit.*review'; then
  # Only suggest @claude review if we haven't already this session
  review_marker="/tmp/claude-session-${CLAUDE_SESSION_ID:-$$}/review-requested"
  if [ -f "$review_marker" ]; then
    directives="$directives\n[PR] Before creating: run quality:gate, verify type:check passes. Use conventional commit format: type(scope): description. (Review already requested this session.)"
  else
    directives="$directives\n[PR] Before creating: run quality:gate, verify type:check passes. After creating: comment @claude review on the PR. Use conventional commit format: type(scope): description."
    touch "$review_marker" 2>/dev/null || true
  fi
fi

# ── Refactoring ──────────────────────────────────────────────────

if echo "$prompt" | grep -qiE '\brefactor\b|extract.*into|move.*to|split.*into|consolidate|clean.?up'; then
  directives="$directives\n[REFACTOR] Run tests BEFORE changing code (establish baseline). Make small steps, test after each. No barrel imports. Verify type:check + tests pass after refactoring."
fi

# ── E2E testing ──────────────────────────────────────────────────

if echo "$prompt" | grep -qiE '\be2e\b|playwright|end.to.end|browser test|user workflow|acceptance test'; then
  directives="$directives\n[E2E] Use base fixture from e2e/fixtures/base.ts (includes axe-core). Include accessibility audit: makeAxeBuilder().analyze(). Use data-testid for selectors. Add explicit waits (waitForSelector, toBeVisible), never hard delays."
fi

# ── Verification / testing in browser ────────────────────────────

if echo "$prompt" | grep -qiE 'test.*browser|check.*browser|verify.*works|test the flow|test.*ui|check.*page|verify.*page|does it work|try it|smoke test'; then
  directives="$directives\n[VERIFY] Do NOT ask the user to test manually. Use browser tools to verify yourself:\n- agent-browser: open URL → snapshot → verify elements → screenshot\n- claude-in-chrome MCP: for authenticated pages\n- Playwright: for automated e2e assertions\nVerify the fix works BEFORE reporting success."
fi

# ── General: never delegate verification to user ─────────────────
# Only fire on substantive bug fixes, not trivial ("fix indentation", "fix typo")

if echo "$prompt" | grep -qiE 'fix.*bug|broken|not working|blank.*screen|error.*page|crash|regression'; then
  directives="$directives\n[SELF-VERIFY] After fixing: verify the fix works yourself using browser tools or tests. Do NOT ask the user to check — confirm it works before declaring done."
fi

# ── Output ───────────────────────────────────────────────────────

if [ -n "$directives" ]; then
  escaped=$(printf '%s' "$directives" | jq -Rs .)
  echo "{\"hookSpecificOutput\":{\"hookEventName\":\"UserPromptSubmit\",\"additionalContext\":$escaped}}" >&2
fi

exit 0
