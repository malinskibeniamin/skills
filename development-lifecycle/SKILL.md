---
name: development-lifecycle
description: "Use when doing any development work. Automatically guides through the right phase: brainstorm → plan → implement (TDD) → review. One skill for the full lifecycle — no need to invoke other skills manually."
---

# Development Lifecycle

## How It Works

You don't need to remember skill names. This skill detects what phase you're in and guides you through the right process automatically.

## Phases

### 1. Understand — before writing any code

- Explore the problem space. Ask clarifying questions one at a time.
- If building something new: propose 2-3 approaches with trade-offs. Get approval.
- If fixing a bug: reproduce it with a failing test first. Trace to root cause.
- **Hard gate: do NOT write implementation code until the approach is agreed upon.**

### 2. Plan — break work into steps

- Write a plan so detailed that anyone can execute it correctly.
- Every step: exact file paths, exact code, expected output.
- No placeholders. No "add error handling later."
- Bite-sized tasks (2-5 minutes each).
- **Cross-model check**: if `/codex:rescue` is available, auto-dispatch the plan to Codex for a second opinion. Read its feedback, address concerns, finalize the stronger plan. If Codex isn't installed, skip.

### 3. Implement — TDD for every change

- Write a failing test FIRST (RED).
- Write minimal code to pass (GREEN).
- Refactor while green (REFACTOR).
- No `setTimeout` hacks — use condition-based waiting.
- Run `--detectAsyncLeaks` on test files.

### 4. Verify — confirm it actually works

- **Never ask the user to verify.** Use browser tools yourself:
  - `agent-browser`: open the page, snapshot, verify elements, screenshot
  - `claude-in-chrome` MCP: for authenticated pages
  - Playwright tests: for automated assertions
- If it's a UI fix: open the page, verify the fix renders correctly
- If it's a logic fix: run the test, confirm green
- **When green: commit immediately.** Every passing state deserves a snapshot. Don't accumulate changes across multiple features in one commit.

### 5. Review — before creating PR

- Dispatch `code-reviewer` agent for fresh-eyes review (spec compliance + code quality)
- Optional: `/codex:adversarial-review` for cross-model challenge
- For large refactors: run `/simplify` to clean up the result
- Then: `gh pr create` → `@claude review`

### 5b. Iterate — two review rounds, then hand off

After the PR is created, run exactly two automated review rounds before handing off to a human.

**Round 1 — Initial review:**

1. Get CI green: `gh pr checks <pr-number> --watch`. If CI fails, fix and push until green.
2. Dispatch `code-reviewer` agent for first review.
3. Post review findings as a PR comment via `gh pr comment`.
4. Apply all fixes from the review. Push.
5. Get CI green again.

**Round 2 — Verification review:**

1. Dispatch `code-reviewer` agent for second review (verifies Round 1 fixes are correct and didn't introduce new issues).
2. Post review findings as a PR comment.
3. If new issues found: fix them, push, get CI green. Do NOT trigger a third review round.

**Hand off to human:**

After Round 2 completes:

1. Post a final PR comment summarizing: what changed, what both reviews found, how it was addressed, and test coverage.
2. Request review from the appropriate team member: `gh pr edit <number> --add-reviewer <username>`
3. **Stop.** Do not poll for human approval.

**If the human requests changes later** (new session):

1. Read their review comments: `gh pr view <number> --comments`
2. Apply feedback, push, get CI green
3. Run one more code-reviewer round, post findings
4. Post a comment addressing each review point
5. Re-request human review, then stop

**Exit conditions:**
- **Normal exit**: CI green + 2 automated review rounds complete + human reviewer requested → stop
- **Re-entry**: human requests changes → new session, one review round, then stop
- **Never**: poll waiting for human approval or run more than 2 review rounds per session

### 6. Compound — codify what we learned

After every non-trivial task, ask: "Did we learn something worth preserving?"

- If yes: write a rule to `.claude/rules/<topic>.md` with a `paths:` glob
- Rules auto-load only when matching files are touched (no CLAUDE.md bloat)
- Examples: "protobuf v2 migration gotcha", "form validation pattern", "route auth guard"

## When to Use Each Phase

| User says | Phases |
|---|---|
| "Build a new feature" | 1 → 2 → 3 → 4 → 5 → 5b → 6 |
| "Fix this bug" | 1 (reproduce) → 3 (TDD fix) → 4 (verify) → 5 → 5b → 6 |
| "Refactor this module" | 1 (explore) → 2 (plan) → 3 → 4 → 5 → 5b |
| "Write tests for X" | 3 (TDD only) |
| "Create a PR" | 5 (review only) |
| "Quick question" | Just answer — no lifecycle needed |
| "Batch these 5 issues" | **Sandcastle** — parallel agents, one per issue |
| "Work on this overnight" | **Sandcastle** — AFK delegation |

See [REFERENCE.md](REFERENCE.md) for detailed checklists per phase and Sandcastle integration.
