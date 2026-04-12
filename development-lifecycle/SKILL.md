---
name: development-lifecycle
description: "Use when doing frontend, React, TypeScript, or UI development work. Automatically guides through the right phase: brainstorm → plan → grill → implement (TDD) → review. One skill for the full lifecycle — no need to invoke other skills manually."
---

# Development Lifecycle

Auto-detects phase, guides through correct process. No need remember skill names.

## Phases

### 1. Understand

- Explore. Clarify one-at-a-time. New→2-3 approaches+tradeoffs. Bug→failing test→root cause.
- Spawn background agents: investigate alternatives, prior art, edge cases in parallel.
- Mixed patterns in area? Refactor to single pattern FIRST before adding features.
- **GATE: no impl code until approach approved.**

### 2. Plan

- Every step: exact file paths, exact code, expected output. No placeholders.
- Bite-sized tasks (2-5 min each).
- UI work: spawn 2-3 parallel prototype agents, review with user, pick best. See [REFERENCE.md](REFERENCE.md).
- 5+ tasks: plan as stacked PRs (one per logical group).
- Complex plan (5+ tasks, multi-stakeholder)? Consider `/ultraplan` — richer review surface, inline comments, frees terminal.
- If `/codex:rescue` available: auto-dispatch plan for second opinion.

### 2b. Grill

**GATE: no impl until plan survives grilling.**

- Auto-invoke `/grill-me`. Grill until every branch resolved.
- Update plan with changes. Get explicit user confirmation.
- Skip only if: trivial bug fix AND <3 tasks AND no architectural decisions.

### 3. Implement (TDD)

- RED: failing test first. GREEN: minimal code to pass.
- **Test deletion guard**: verify test+assertion count didn't decrease after GREEN. AI may weaken tests. If dropped, reject and redo.
- REFACTOR while green. No `setTimeout` hacks. Run `--detectAsyncLeaks`.

### 4. Verify

- **Never ask user to verify.** Use tools yourself:
  - `agent-browser`: open page → snapshot → verify → screenshot
  - `claude-in-chrome` MCP: authenticated pages
  - Playwright: automated assertions
- UI fix: `Monitor: bun run dev`, wait ready, open and verify.
- Optional: dispatch agent for edge-case test generation.
- **When green: commit immediately.** One commit per passing state.

### 4b. Refine (Self-Review Loop)

**After verify commits, before external review.** Catches quality gaps while context is fresh.

1. Dispatch `self-reviewer` agent on session diff.
2. If diff >50 lines OR touches auth/security paths: also dispatch `adversarial-reviewer` in parallel.
3. Process findings by priority — see [REFERENCE.md](REFERENCE.md) for protocol.
4. Fix P0/P1 immediately, apply P2 `safe_auto`, show P2 `gated_auto` to user.
5. Commit fixes, re-verify (tests + types + lint).
6. **Max 2 refinement rounds.** Then proceed to Review.
7. P3/advisory findings logged for Phase 6 (Compound).

**Skip if**: trivial change (<10 lines, no logic), test-only, or docs-only.

### 5. Review

- Security gate: SAST/SCA on changed files. Block on critical/high. See [REFERENCE.md](REFERENCE.md).
- Dispatch `code-reviewer` agent (fresh-eyes review).
- Optional: `/codex:adversarial-review`, `/simplify` for large refactors.
- Then: `gh pr create` → `@claude review`

### 5b. Iterate

Exactly two automated rounds (CI green → code-reviewer → `/resolve-pr-feedback` → repeat), then request human review. **Stop.** Never >2 rounds per session.

Use `Monitor: gh pr checks <number> --watch` after every push. See [REFERENCE.md](REFERENCE.md) for protocol.

### 6. Compound

After non-trivial tasks: "Did we learn something worth preserving?"
- Write rule to `.claude/rules/<topic>.md` with `paths:` glob. Auto-loads on match.
- Bug from AI code? Create eval/test fixture catching same error class in CI.

## Phase Selection

| User says | Phases |
|---|---|
| "Build a new feature" | 1→2→**2b**→3→4→**4b**→5→5b→6 |
| "Fix this bug" | 1(reproduce)→3(TDD)→4→**4b**→5→5b→6 |
| "Refactor this module" | 1→2→**2b**→3→4→**4b**→5→5b |
| "Write tests for X" | 3 only |
| "Create a PR" | 5 only |
| "Quick question" | Just answer |
| "Batch these 5 issues" | **Sandcastle** — parallel agents |
| "Work on this overnight" | **Sandcastle** — AFK delegation |

See [REFERENCE.md](REFERENCE.md) for detailed checklists and Sandcastle integration.