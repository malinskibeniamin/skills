---
name: development-lifecycle
description: "Use when frontend/React/TypeScript/UI work. Guides understand -> plan -> grill -> TDD -> /go (4b->5). Alias: /work."
---

# Development Lifecycle

Auto-detect phase, guide process.

If the user says "plow ahead", "do not stop", "use your best judgment", "keep going until done", or similar, use `/plow-ahead` as the autonomy contract: make reversible assumptions, continue through routine ambiguity, and stop only for true blockers.

## Ponytail default

Ponytail before implementation: run `/deslop full` (write mode) during planning and keep it active through `/go`: delete, stdlib, native, installed dependency, one-line before custom code.

## Phases

### 0. Worktree (automatic, silent if already isolated)

Feature branch? Skip. On main/master/develop? Spawn worktree before code. [ETHOS: Worktree Isolation]

    scripts/mux-worktree.sh <type>/<branch-name>

Claude invoke silent when phase 1 start on default branch. User never run.

### 1. Understand

- Explore | clarify one-at-a-time | new->2-3 approaches+tradeoffs | bug->failing test->root cause
- Claude-hosted: background agents may explore alternatives, prior art, and edge cases in parallel.
- Native Codex: explore inline unless the user explicitly requests agents or invokes `/swarm`; skill activation alone is not consent.
- Mixed patterns area? Refactor to single pattern FIRST before add features
- **GATE: no impl code until approach approved.**

### 2. Plan

- Every step: exact file paths, exact code, expected output. No placeholders.
- Non-trivial feature -> `/resilience-review` for edge cases/error handling/polish or skip reason.
- Bite-sized tasks (2-5 min each)
- UI work: use `/prototype` for 2-3 runnable UI variations, review with user, pick best. See [REFERENCE.md](REFERENCE.md).
- 5+ tasks -> stacked PRs (one per logical group)

### 2b. Grill

**GATE: no impl until plan survive grilling.**

- Auto-invoke `/grilling` | grill until every branch resolved | update CONTEXT.md + ADRs inline
- Update plan with changes | get explicit user confirmation
- Skip only if: trivial bug fix AND <3 tasks AND no architectural decisions

### 3. Implement (TDD)

- **Thinker/executor split (Claude-hosted default)**: the plan that survived grill is the spec. Fable-5/Opus-4.8 stays orchestrator; execution may go to Sonnet or `/codex` GPT-5.6 Sol. The orchestrator reviews the diff; below the bar -> rerun smarter.
- **Native Codex**: implement the approved plan inline. Do not recursively invoke `/codex` or auto-route to `/swarm`; use native agents only after explicit user consent.
- After plan survives grill, Claude may use `/swarm` when independent lanes safely accelerate work. In Codex, `/swarm` runs only when the user invokes it or explicitly asks for parallel agents.
- RED: failing test first | GREEN: minimal code to pass | defensive gaps -> RED tests
- Code is liability: reuse-first (standard library, native platform, already-installed dependency, one-line), then keep only product value, defense, or test confidence.
- **Test deletion guard**: verify test+assertion count not decrease after GREEN. AI may weaken tests -> reject and redo.
- REFACTOR while green | no `setTimeout` hacks | run `--detectAsyncLeaks`

### 4-6. Ship -- `/go`

Impl done -> run `/go` to ship. Handle all:

- **4. Verify** -- types + lint + tests + browser smoke
- **4b. Review / Refine** -- self-reviewer + adversarial-reviewer; ensure Resilience Review evidence for risky features
- **5. Ship** -- `/simplify` -> `/deslop` -> `/commit-push-pr` -> code-reviewer agent
- **5b. Iterate** -- monitor CI -> `/resolve-pr-feedback` -> AI self-review: up to 3 rounds, early-exit on clean; human review: address ALL (hook-enforced)
- **6. Compound** -- codify lessons as `.claude/rules/`

See `/go` skill full details. See [REFERENCE.md](REFERENCE.md) phase-specific checklists.

## Phase Selection

Full flowchart [REFERENCE.md#phase-flowchart](REFERENCE.md#phase-flowchart).

| User says | Phases |
|---|---|
| "Build a new feature" | 1->2->**2b**->3->**`/go`** |
| "Fix this bug" | 1(reproduce)->3(TDD)->**`/go`** |
| "Refactor this module" | 1->2->**2b**->3->**`/go`** |
| "Write tests for X" | 3 only |
| "Ship it" / "Create a PR" | **`/go`** only |
| "Quick question" | Just answer |
