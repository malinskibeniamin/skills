# Development Lifecycle Reference

## Phase 1: Understand

### New Feature
1. Read relevant code, docs, recent git history
2. Ask clarifying questions — one at a time, not a list
3. Propose 2-3 approaches with trade-offs
4. For UI work: generate HTML mockup → `agent-browser screenshot --annotate` → iterate
5. Challenge the chosen approach (edge cases, failure modes)
6. Get user approval before proceeding

### Bug Fix (4-Phase Root Cause Analysis)

**Iron law: no fixes without root cause investigation first.**

1. **Reproduce** — read the FULL error message, write a failing test
2. **Analyze** — find working examples in the codebase, trace data flow upstream to where invalid data ORIGINATES
3. **Hypothesize** — "I think X is the root cause because Y." Test ONE hypothesis at a time.
4. **Fix at source** — fix where the data originates, not where it crashes. Add defense-in-depth validation at entry point, business logic, environment guards, and debug instrumentation.

## Phase 2: Plan

- [ ] Every task: exact file paths, exact code, expected output
- [ ] No TBD, no "similar to Task N", no "add error handling"
- [ ] Bite-sized (2-5 minutes per task)
- [ ] Test step alongside every implementation step
- [ ] Self-review: spec coverage, placeholder scan, type consistency

## Phase 2b: Grill

**Mandatory gate between planning and implementation.**

After the plan is written, automatically initiate `/grill-me` on it:

1. Present the plan summary to the user
2. Grill the plan — challenge assumptions, surface trade-offs, find gaps
3. Resolve every decision branch before proceeding
4. Update the plan with any decisions that changed during grilling
5. Get explicit user confirmation: "Plan is solid, proceed"

### Why This Phase Exists

Code is the byproduct of understanding. If the user can't defend every decision in the plan under pressure, the resulting code becomes cognitive debt — technically correct but owned by nobody. The grill phase ensures the human builds the mental model *before* the LLM writes the code, so the team can extend, debug, and evolve the system long after it ships.

### Skip Conditions

Grill is mandatory unless ALL of these are true:
- [ ] Bug fix with a single, already-identified root cause
- [ ] Plan has fewer than 3 tasks
- [ ] No architectural decisions involved

If skipping, note in the plan: "Grill skipped — trivial bug fix, no architectural decisions."

## Phase 3: Implement (TDD)

### Iron Law
**No production code without a failing test first.**

### Cycle
1. RED — write one minimal failing test, verify it fails correctly
2. GREEN — write minimal code to make it pass
3. REFACTOR — clean up while staying green

### Test Quality
- `userEvent.setup()` not `fireEvent`
- `getByRole` for accessibility assertions
- No `setTimeout`/`waitForTimeout` — use `await waitFor(() => expect(...))`
- Run `--detectAsyncLeaks` after

### Classification
| Suffix | Purpose |
|---|---|
| `.test.ts` | Unit — pure logic, no DOM |
| `.test.tsx` | Integration — renders components |
| `e2e/*.spec.ts` | E2E — Playwright browser |

## Phase 4: Review

Dispatch `code-reviewer` agent for fresh-eyes review. Two stages:

### Stage 1: Spec Compliance
- [ ] All requirements from the issue/PRD addressed
- [ ] No scope creep (nothing beyond what was asked)
- [ ] Breaking changes documented
- [ ] Edge cases handled

### Stage 2: Code Quality (priority order)
1. **Security** — no eval, no innerHTML, no hardcoded secrets
2. **Type safety** — no `as any`, no `@ts-ignore`
3. **Error handling** — async operations have error paths
4. **Accessibility** — keyboard nav, aria-labels, semantic HTML
5. **Testing** — tests verify behavior, edge cases covered
6. **DRY** — no duplicated logic
7. **Performance** — no unnecessary re-renders, heavy deps lazy-loaded

### Review Status Codes
- **APPROVED** — all checks pass, ready to merge
- **CONCERNS** — minor issues, address then proceed
- **NEEDS_CHANGES** — significant issues, fix and re-review

### Cross-Model Review (Optional)
```
/codex:adversarial-review
```
Requires: `npm install -g @openai/codex` and OpenAI API key.
Install plugin: `/plugin marketplace add openai/codex-plugin-cc` → `/plugin install codex@openai-codex` → `/codex:setup`

### Ship
```bash
gh pr create --title "type(scope): description" --body "..."
gh pr comment <URL> --body "@claude review"
```

## Hard Rules

- Never ask the user to test manually. Use agent-browser, playwright, or test runner.
- Never skip Phase 1. Understand before building.
- Never write production code without a failing test first.

## Commit Discipline

**Commit when green.** One concern per commit. `type(scope): what changed` format.
Reference issues: `Closes #42` or `Fixes PROJ-123` in body.

## Phase 6: Compound

After non-trivial tasks, codify lessons as path-scoped rules:

```markdown
<!-- .claude/rules/protobuf-v2-timestamp.md -->
---
paths:
  - "**/*_pb*"
  - "**/gen/**"
---
Protobuf v2 Timestamp fields: use timestampFromDate() from @bufbuild/protobuf/wkt.
Never construct as { seconds, nanos } — causes JSON serialization failure.
```

Rules auto-load ONLY when Claude works on matching files. CLAUDE.md stays clean.

**When to compound:**
- Bug fix that revealed a non-obvious pattern
- Migration gotcha that will recur
- API contract or convention the team agreed on

**When NOT to compound:**
- One-off fix unlikely to recur
- Pattern already covered by a hook
- Generic knowledge Claude already has

## Cross-Model Review

If `/codex:rescue` available: auto-dispatch plan for second opinion. For bug triage: use GitHub issue comments as communication channel between models.

## Subagents

| Agent | Role | When dispatched |
|---|---|---|
| `code-reviewer` | Fresh-eyes spec compliance + quality review | Phase 5 (Review) |
| `verifier` | Run tests + visual verification via browser | Phase 4 (Verify) |

## Parallelization Guide

| Task | Parallelize? | How | Sweet spot |
|---|---|---|---|
| Codebase-wide migration | Yes | `/batch` (built-in) | 5-30 agents, one per file/module |
| Security scan | Yes | `/batch` or Sandcastle | 3-5 agents, each scans a directory |
| Multiple UI design options | Yes | Spawn 3 agents with different constraints | 3 agents max |
| Independent feature tasks | Yes | Sandcastle (AFK) | 3-5 agents, one per issue |
| Test generation across modules | Yes | Sandcastle or `/batch` | One agent per module |
| Bug fix | No | Sequential reasoning needed | 1 agent |
| Code review | 2 agents | spec + quality (our code-reviewer) + Codex | 2-3 reviewers |

Use `/batch` for codebase-wide migration, Sandcastle for AFK work, 3 agents for design competition.

| Task complexity | Model |
|---|---|
| Simple (rename, move) | `claude-haiku-4-5` |
| Standard (feature) | `claude-sonnet-4-6` |
| Complex (architecture) | `claude-opus-4-6` |

Don't parallelize: bug fixes, hypothesis testing. Don't use >5 agents on overlapping files.
