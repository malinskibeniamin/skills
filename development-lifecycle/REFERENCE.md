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

## Skill Mapping

This lifecycle skill incorporates patterns from:
- `brainstorming` (Phase 1 design mode)
- `writing-plans` (Phase 2)
- `test-driven-development` (Phase 3)
- `systematic-debugging` (Phase 1 bug fix mode)
- `requesting-code-review` (Phase 4)

You don't need to invoke those skills separately. This skill covers the full flow.
