---
name: development-lifecycle
description: "Use when doing frontend/React/TypeScript/UI work. Auto-guides phase: understand → plan → grill → implement (TDD) → /go (4→4b review→5→5b→6). One skill, full lifecycle. Alias: /work."
---

# Development Lifecycle

Auto-detects phase, guides through correct process.

## Phases

### 1. Understand

- Explore · clarify one-at-a-time · new→2-3 approaches+tradeoffs · bug→failing test→root cause
- Spawn background agents: alternatives, prior art, edge cases in parallel
- Mixed patterns in area? Refactor to single pattern FIRST before adding features
- **GATE: no impl code until approach approved.**

### 2. Plan

- Every step: exact file paths, exact code, expected output. No placeholders.
- Bite-sized tasks (2-5 min each)
- UI work: spawn 2-3 parallel prototype agents, review with user, pick best. See [REFERENCE.md](REFERENCE.md).
- 5+ tasks → plan as stacked PRs (one per logical group)
- Complex plan (5+ tasks, multi-stakeholder)? Consider `/ultraplan`
- If `/codex:rescue` available → auto-dispatch for second opinion

### 2b. Grill

**GATE: no impl until plan survives grilling.**

- Auto-invoke `/domain-model` · grill until every branch resolved · update CONTEXT.md + ADRs inline
- Update plan with changes · get explicit user confirmation
- Skip only if: trivial bug fix AND <3 tasks AND no architectural decisions

### 3. Implement (TDD)

- RED: failing test first · GREEN: minimal code to pass
- **Test deletion guard**: verify test+assertion count didn't decrease after GREEN. AI may weaken tests → reject and redo.
- REFACTOR while green · no `setTimeout` hacks · run `--detectAsyncLeaks`

### 4-6. Ship — `/go`

Implementation done → run `/go` to ship. Handles everything from here:

- **4. Verify** — types + lint + tests + browser smoke
- **4b. Review / Refine** — self-reviewer + adversarial-reviewer agents (4b→5)
- **5. Ship** — `/simplify` → `/commit-push-pr` → code-reviewer agent
- **5b. Iterate** — monitor CI → `/resolve-pr-feedback` → AI self-review: up to 3 rounds with early-exit on clean; human review: address ALL (hook-enforced)
- **6. Compound** — codify lessons as `.claude/rules/`

See `/go` skill for full details. See [REFERENCE.md](REFERENCE.md) for phase-specific checklists.

## Phase Selection

Full flowchart in [REFERENCE.md#phase-flowchart](REFERENCE.md#phase-flowchart).

| User says | Phases |
|---|---|
| "Build a new feature" | 1→2→**2b**→3→**`/go`** |
| "Fix this bug" | 1(reproduce)→3(TDD)→**`/go`** |
| "Refactor this module" | 1→2→**2b**→3→**`/go`** |
| "Write tests for X" | 3 only |
| "Ship it" / "Create a PR" | **`/go`** only |
| "Quick question" | Just answer |
| "Batch these 5 issues" | **Sandcastle** — parallel agents |
| "Work on this overnight" | **Sandcastle** — AFK delegation |

See [REFERENCE.md](REFERENCE.md) for detailed checklists and Sandcastle integration.
