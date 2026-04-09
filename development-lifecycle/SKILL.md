---
name: development-lifecycle
description: "Use when doing any development work. Automatically guides through the right phase: brainstorm → plan → grill → implement (TDD) → review. One skill for the full lifecycle — no need to invoke other skills manually."
---

# Development Lifecycle

## How It Works

You don't need to remember skill names. This skill detects what phase you're in and guides you through the right process automatically.

## Phases

### 1. Understand — before writing any code

- Explore the problem space. Ask clarifying questions one at a time.
- If building something new: propose 2-3 approaches with trade-offs. Get approval.
- If fixing a bug: reproduce it with a failing test first. Trace to root cause.
- **Parallel research**: spawn background agents to investigate alternatives, prior art, and edge cases while discussing the approach with the user.
- **Refactor-first gate**: if the area has mixed patterns or incomplete migrations, refactor to a single pattern before adding new features. Mixed codebases confuse both humans and AI models.
- **Hard gate: do NOT write implementation code until the approach is agreed upon.**

### 2. Plan — break work into steps

- Write a plan so detailed that anyone can execute it correctly.
- Every step: exact file paths, exact code, expected output.
- No placeholders. No "add error handling later."
- Bite-sized tasks (2-5 minutes each).
- **For UI/interactive work**: spawn 2-3 parallel prototype agents with different constraints. Review results with the user and select the best approach before writing the full plan. See [REFERENCE.md](REFERENCE.md) for prototyping workflow.
- **For 5+ task features**: plan as stacked PRs (one per logical group of tasks) rather than a single monolithic PR. Smaller PRs get faster, higher-quality reviews.
- **Cross-model check**: if `/codex:rescue` is available, auto-dispatch the plan to Codex for a second opinion. Read its feedback, address concerns, finalize the stronger plan. If Codex isn't installed, skip.

### 2b. Grill — stress-test the plan before any code is written

**Hard gate: do NOT proceed to implementation until the plan survives grilling.**

- Auto-invoke `/grill-me` on the plan. Grill until every branch is resolved.
- Update the plan with any decisions that changed. Get explicit user confirmation to proceed.
- **Skip only if**: trivial bug fix AND < 3 tasks AND no architectural decisions. See [REFERENCE.md](REFERENCE.md) for details.

### 3. Implement — TDD for every change

- Write a failing test FIRST (RED).
- Write minimal code to pass (GREEN).
- **Test deletion guard**: after GREEN, verify test count and assertion count haven't decreased. AI agents may delete or weaken tests to make them pass. If count dropped, reject and redo.
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
- **Edge-case hardening** (optional): dispatch an agent to generate additional edge-case tests for the changed code. Prioritize boundary conditions, error paths, and concurrency scenarios.
- **When green: commit immediately.** Every passing state deserves a snapshot. Don't accumulate changes across multiple features in one commit.

### 5. Review — before creating PR

- **Security gate**: run SAST/SCA scan on changed files. Block PR creation on new critical/high findings. See [REFERENCE.md](REFERENCE.md) for tooling.
- Dispatch `code-reviewer` agent for fresh-eyes review (spec compliance + code quality)
- Optional: `/codex:adversarial-review` for cross-model challenge
- For large refactors: run `/simplify` to clean up the result
- Then: `gh pr create` → `@claude review`

### 5b. Iterate — two review rounds, then hand off

Run exactly two automated review rounds (CI green → code-reviewer → `/resolve-pr-feedback` → repeat), then post summary and request human review. **Stop.** Never poll for approval or run >2 rounds per session. See [REFERENCE.md](REFERENCE.md) for the full round-by-round protocol and exit conditions.

### 6. Compound — codify what we learned

After every non-trivial task, ask: "Did we learn something worth preserving?"

- If yes: write a rule to `.claude/rules/<topic>.md` with a `paths:` glob
- Rules auto-load only when matching files are touched (no CLAUDE.md bloat)
- Examples: "protobuf v2 migration gotcha", "form validation pattern", "route auth guard"
- **Regression eval**: if a bug was traced to AI-generated code, create a code-based eval or test fixture that catches the same class of error in CI. Build the project's quality signal over time, not just per-PR.

## When to Use Each Phase

| User says | Phases |
|---|---|
| "Build a new feature" | 1 → 2 → **2b (grill)** → 3 → 4 → 5 → 5b → 6 |
| "Fix this bug" | 1 (reproduce) → 3 (TDD fix) → 4 (verify) → 5 → 5b → 6 |
| "Refactor this module" | 1 (explore) → 2 (plan) → **2b (grill)** → 3 → 4 → 5 → 5b |
| "Write tests for X" | 3 (TDD only) |
| "Create a PR" | 5 (review only) |
| "Quick question" | Just answer — no lifecycle needed |
| "Batch these 5 issues" | **Sandcastle** — parallel agents, one per issue |
| "Work on this overnight" | **Sandcastle** — AFK delegation |

See [REFERENCE.md](REFERENCE.md) for detailed checklists per phase and Sandcastle integration.
