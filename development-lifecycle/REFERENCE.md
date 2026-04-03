# Development Lifecycle Reference

## Phase 1: Understand

### New Feature
1. Read relevant code, docs, recent git history
2. Ask clarifying questions — one at a time, not a list
3. Propose 2-3 approaches with trade-offs
4. For UI work: generate HTML mockup → `agent-browser screenshot --annotate` → iterate
5. Challenge the chosen approach (edge cases, failure modes)
6. Get user approval before proceeding

### Bug Fix
1. Read the full error message carefully
2. Write a failing test that reproduces the bug
3. Trace data flow to find root cause (not just crash site)
4. Form hypothesis: "X is the root cause because Y"
5. Verify hypothesis before fixing

## Phase 2: Plan

Write for "an enthusiastic junior engineer with poor taste":
- [ ] Every task: exact file paths, exact code, expected output
- [ ] No TBD, no "similar to Task N", no "add error handling"
- [ ] Bite-sized (2-5 minutes per task)
- [ ] Test step alongside every implementation step

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

### Stage 1: Spec Compliance
- All requirements addressed?
- No scope creep?
- Edge cases from the spec handled?

### Stage 2: Code Quality
- Clean separation of concerns?
- Error handling covers failure modes?
- Type safety (no `as any`)?
- Tests verify behavior, not implementation?
- Accessible (keyboard nav, aria-labels)?

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

## Skill Mapping

This lifecycle skill incorporates patterns from:
- `brainstorming` (Phase 1 design mode)
- `writing-plans` (Phase 2)
- `test-driven-development` (Phase 3)
- `systematic-debugging` (Phase 1 bug fix mode)
- `requesting-code-review` (Phase 4)

You don't need to invoke those skills separately. This skill covers the full flow.
