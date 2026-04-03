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

Common excuse: "Quick fix is fine" → No. Fix the root cause. Quick fixes become permanent.

## Phase 2: Plan

Write for "an enthusiastic junior engineer with poor taste":
- [ ] Every task: exact file paths, exact code, expected output
- [ ] No TBD, no "similar to Task N", no "add error handling"
- [ ] Bite-sized (2-5 minutes per task)
- [ ] Test step alongside every implementation step

### Plan Self-Review
- [ ] **Spec coverage**: point to a task for each requirement
- [ ] **Placeholder scan**: search for TBD, TODO, "similar to", "add later"
- [ ] **Type consistency**: method names and signatures match across tasks

Common excuse: "They'll figure it out" → Show the exact code. Don't assume context.

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

## Common Agent Excuses

| Excuse | Counter |
|---|---|
| "Let me just code this real quick" | Phase 1 first. Understand before building. |
| "The plan is in my head" | Write it down. Phase 2 prevents mistakes. |
| "I'll add tests later" | No. RED phase first. Always. |
| "This is too simple to plan" | Simple things become complex. Plan it. |
| "Review slows me down" | Review catches bugs that slow you down 10x more. |
| "Please test this manually" | NO. Verify it yourself with agent-browser, playwright, or tests. Never delegate verification to the user. |
| "Restart your dev server and check" | Open the page yourself with browser tools. Confirm it works before reporting. |
| "I can't access the browser" | You have agent-browser (headless) and claude-in-chrome MCP. Use them. |

## Commit Discipline

**Commit when green.** Every passing state deserves a snapshot in git history.

### When to commit
- Tests pass after implementing a feature → commit
- Bug fix verified → commit
- Refactor step complete (tests still green) → commit
- GitHub issue closed / Jira ticket resolved → commit

### Commit quality
- **One concern per commit.** Don't mix a bug fix with a refactor.
- **Subject line**: `type(scope): what changed` (conventional format, enforced by hook)
- **Body**: why the change was made, not what files changed. Future readers should understand the motivation.
- **Reference issues**: `Closes #42` or `Fixes PROJ-123` in the body.

### Anti-patterns
- Accumulating 500 lines across 3 features in one commit → split into 3
- "WIP" or "misc fixes" commit messages → be specific
- Committing broken state (tests failing) → get green first

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

## Cross-Model Adversarial Planning

When `/codex:rescue` is available (Codex plugin installed), automatically cross-check plans with a different model for a stronger result.

### Automatic (Phase 2)

After writing a plan, dispatch to Codex:
```
/codex:rescue "Review the plan I just wrote. Add concerns, edge cases I missed, and alternative approaches. Write your review as ## Codex Review at the end of the plan file."
```

Claude Code then reads Codex's review and synthesizes the final plan.

### Via GitHub Issue (Bug Triage)

For bug investigation, use the issue as a communication channel:
```bash
# Claude Code posts hypothesis
gh issue comment 123 --body "## Claude Analysis\n[hypothesis + evidence]"

# Codex reviews
# /codex:rescue "Read issue #123 and comment with your analysis"

# Claude Code reads both, synthesizes fix approach
```

### Parallel Worktrees (Large Plans)

For plans with independent tasks, parallelize with git worktrees:
```
Each subagent works in isolation: worktree → no conflicts
Use: Agent tool with isolation: "worktree"
```

## Subagents

| Agent | Role | When dispatched |
|---|---|---|
| `code-reviewer` | Fresh-eyes spec compliance + quality review | Phase 5 (Review) |
| `verifier` | Run tests + visual verification via browser | Phase 4 (Verify) |

## What's Inline vs Separate

| Phase | Content | Where |
|---|---|---|
| Phase 1 (design) | `/brainstorming` skill | Separate skill (advanced) |
| Phase 1 (bug fix) | 4-phase root cause analysis | Inline above |
| Phase 2 (plan) | "Junior engineer" detail + self-review | Inline above |
| Phase 3 (TDD) | `/test-driven-development` skill | Separate skill (auto-loads on test files) |
| Phase 4 (verify) | `verifier` agent | Inline + agent file |
| Phase 5 (review) | `code-reviewer` agent + status codes | Inline above |

Users only need to know `/development-lifecycle`. Everything else is referenced or auto-loaded.
