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

### 5. Review — before creating PR

- Stage 1: Does it match the requirements? (spec compliance)
- Stage 2: Is it well-built? (code quality, a11y, security, types)
- Optional: `/codex:adversarial-review` for cross-model challenge.
- Then: `gh pr create` → `@claude review`.

### 6. Compound — codify what we learned

After every non-trivial task, ask: "Did we learn something worth preserving?"

- If yes: write a rule to `.claude/rules/<topic>.md` with a `paths:` glob
- Rules auto-load only when matching files are touched (no CLAUDE.md bloat)
- Examples: "protobuf v2 migration gotcha", "form validation pattern", "route auth guard"

## When to Use Each Phase

| User says | Phases |
|---|---|
| "Build a new feature" | 1 → 2 → 3 → 4 → 5 → 6 |
| "Fix this bug" | 1 (reproduce) → 3 (TDD fix) → 4 (verify) → 5 → 6 |
| "Refactor this module" | 1 (explore) → 2 (plan) → 3 → 4 → 5 |
| "Write tests for X" | 3 (TDD only) |
| "Create a PR" | 5 (review only) |
| "Quick question" | Just answer — no lifecycle needed |

See [REFERENCE.md](REFERENCE.md) for detailed checklists per phase.
