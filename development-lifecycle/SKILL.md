---
name: development-lifecycle
description: "Run frontend work from understanding through TDD and shipping. Use for React, TypeScript, or UI implementation."
---

# Development Lifecycle

Auto-detect phase, guide process.

If the user says "plow ahead", "do not stop", "use your best judgment", "keep going until done", or similar, use `/plow-ahead` as the autonomy contract: make reversible assumptions, continue through routine ambiguity, and stop only for true blockers.

## Phases

### 0. Worktree (automatic, silent if already isolated)

Feature branch? Skip. On main/master/develop? Spawn worktree before code. [ETHOS: Worktree Isolation]

    scripts/mux-worktree.sh <type>/<branch-name>

Claude invoke silent when phase 1 start on default branch. User never run.

### 1. Understand

- Start with the **blind spot**: what are we assuming, what has not been observed, and
  which unknown could invalidate the approach?
- Resolve facts from code, tests, logs, docs, and rich references. Prefer executable
  examples, fixtures, rubrics, prototypes, and neighboring implementations over another
  prose summary.
- Classify each remaining unknown as lookup, prototype, reversible assumption, or pause
  trigger. Ask the user only for a decision that materially changes the result.
- New decision -> 2-3 approaches + tradeoffs. Bug -> failing test -> root cause.
- A well-scoped build/fix/implement request approves execution. State the approach, then continue immediately; do not manufacture an approval stop.
- One primary model is the single owner. Do not spawn agents, background research, or a recursive model call unless the user explicitly requests delegation or invokes `/swarm`.
- Mixed patterns area? Reuse the pattern required by this task; report broader convergence separately.
- Stay inside the requested acceptance criteria. Report adjacent cleanup separately unless it blocks the requested behavior.

### 2. Plan

- Plan the most **volatile** or falsifiable slice first; stable mechanical work follows.
- Give exact paths, behavior, evidence, and acceptance checks where they reduce
  ambiguity. Do not predict every line of code before discovery.
- Start with the smallest obvious design. Name what can be deleted, reused, or left unbuilt.
- Use current requirements and demonstrated scale. Do not add machinery for hypothetical growth.
- Run `/quantify-impact` when a direct, decision-useful metric exists; lock the base, metric, guardrail, scenario, and worthwhile delta before coding.
- Run `/resilience-review` only when credible failure could cause data loss, security/privacy harm, irreversible action, broken contracts, or a likely user dead end.
- When `/grilling` applies, let its evidence select quick, standard, or deep-risk
  review. Deep-risk includes the resilience pass above; standard keeps the smaller
  engineering Murphy pass.
- Bite-sized tasks (2-5 min each)
- UI work: prototype alternatives only when the user requests exploration or a material
  visual direction is unresolved.
- Large PR/ship scope may propose stacked PRs; never create extra PRs without approval.
- For long or high-unknown work, create gitignored
  `.context/implementation-notes.md` with: current hypothesis, observed evidence,
  deviations, reversible assumptions, and pause triggers. Short work stays in context.

### 2b. Grill

- Invoke `/grilling` when the user requests planning/grilling or an unresolved architectural, product, or UX decision would materially change the result.
- Ordinary build/fix/implement work skips this stop gate and continues immediately after its concise plan.
- When invoked: gather one evidence packet | select the tier | run required axes inline |
  settle architecture-changing decisions | classify remaining unknowns | update
  CONTEXT.md + ADRs only when durable domain knowledge crystallizes
- Update plan with changes | get explicit user confirmation

### 3. Implement

- **Single owner**: the primary model implements the approved or well-scoped plan inline.
- Do not auto-route to `/swarm`, background agents, paired implementation, or recursive `/codex`. Explicit user delegation is required.
- Bugs and meaningful behavior: RED public-contract test -> smallest GREEN implementation -> REFACTOR.
- Trivial types, wiring, static copy/styles, and behavior-preserving deletion need focused verification, not manufactured tests.
- Before adding code: delete, reuse existing code, use the language/platform, then write the smallest clear local expression.
- Every branch, helper, file, option, and dependency must carry required behavior, clarify the domain, or address a credible risk.
- Never weaken an existing behavior test merely to make GREEN.
- REFACTOR while green | no `setTimeout` hacks | run `--detectAsyncLeaks`
- After a material runnable increment is green and clean, run `/dogfood` before relying
  on it; observed defects re-enter RED, then repair and replay.
- When evidence contradicts the plan, record the deviation (for long work), revisit the
  nearest affected decision, and re-plan that slice. Do not obey a stale plan.

### 4-6. Ship when requested -- `/go`

Run only for a PR/ship endpoint. Local build/fix/implement stops after focused verification.

- **4. Verify** -- types + lint + tests + final `/dogfood`
- **4b. Review / Refine** -- inline self/adversarial review plus one awaited cross-model review for non-trivial PR/ship work
- **5. Ship** -- `/commit-push-pr` -> one bounded foreground review
- **5b. Iterate** -- monitor CI -> `/resolve-pr-feedback` -> AI self-review: up to 2 rounds, early-exit on clean; human review: address ALL (hook-enforced)
- **6. Compound** -- codify lessons as `.claude/rules/`

See `/go` skill full details. See [REFERENCE.md](REFERENCE.md) phase-specific checklists.

## Phase selection

Questions return answers. Local implementation ends after verification. PR requests run
verify -> `/commit-push-pr` -> one CI snapshot; `/go` owns the full delivery loop.
Full flowchart: [REFERENCE.md#phase-flowchart](REFERENCE.md#phase-flowchart).
