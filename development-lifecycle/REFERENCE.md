# Development Lifecycle Reference

## Phase 1: Understand

### New Feature
1. Read relevant code, docs, recent git history
2. Ask clarifying questions — one at a time, not a list
3. Propose 2-3 approaches with trade-offs
4. For UI work: generate HTML mockup → `agent-browser screenshot --annotate` → iterate
5. Challenge the chosen approach (edge cases, failure modes)
6. Get user approval before proceeding

### Parallel Research Agents

While discussing the approach with the user, spawn background agents to:
- Investigate alternative libraries or patterns for the problem domain
- Scan the codebase for prior art and existing conventions
- Surface edge cases and failure modes from similar implementations
- Check for open issues or known gotchas in relevant dependencies

This runs concurrently with user discussion — results feed back into approach selection.

### Refactor-First Gate

Before adding features to an area with mixed patterns, check:
- [ ] Does the area use more than one pattern for the same concern? (e.g., two state management approaches, mixed CSS strategies)
- [ ] Is there an incomplete migration? (e.g., some files use old API, some use new)
- [ ] Would an AI agent need conflicting instructions to work here?

If any are true: refactor to a single pattern first, as a separate PR. Then build the feature on a clean foundation. Mixed codebases produce lower-quality AI output and confuse future maintainers.

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

### Rapid Prototyping (UI/Interactive Work)

For features with a visual or interactive component, replace upfront spec writing with competitive prototyping:

1. Define 2-3 constraint sets (e.g., "minimal DOM, CSS-only animations" vs "component library, framer-motion" vs "canvas-based")
2. Spawn one agent per constraint set in parallel (use `claude-sonnet-4-6`)
3. Each agent produces a working prototype — not a spec, not a mockup
4. Review all prototypes with the user: `agent-browser screenshot` each one
5. Select the winner and write the detailed plan from the chosen prototype

**When to use**: any feature where the right approach is unclear until you see it running. Skip for pure logic, API, or data-layer work.

### Stacked PRs for Large Features

For plans with 5+ tasks, break into stacked PRs:

1. Group tasks by logical boundary (e.g., data layer → business logic → UI → tests)
2. Each group becomes one PR in the stack
3. First PR targets the base branch; subsequent PRs target the previous PR's branch
4. Review and merge bottom-up

**Why**: smaller PRs get reviewed 2-3x faster with higher-quality feedback. A 500-line PR gets thorough review; a 2000-line PR gets skimmed.

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
3. **TEST INTEGRITY CHECK** — verify test count and assertion count haven't decreased from the RED step. If they dropped, the agent deleted or weakened tests to pass — reject and redo from RED.
4. REFACTOR — clean up while staying green

### Test Quality
- `userEvent.setup()` not `fireEvent`
- `getByRole` for accessibility assertions
- No `setTimeout`/`waitForTimeout` — use `await waitFor(() => expect(...))`
- Run `--detectAsyncLeaks` after

### Test Deletion Guard

AI agents sometimes delete or simplify tests to make them pass — Kent Beck calls this the "unpredictable genie" effect. Defenses:

1. **Count check**: before GREEN, note the number of `it()`/`test()` blocks and `expect()` calls. After GREEN, verify counts are equal or higher.
2. **Diff review**: if any test file has deletions in the GREEN step, flag for manual review.
3. **Pre-commit hook** (optional): reject commits that reduce assertion count in test files without an explicit `// intentional: [reason]` comment.

### Classification
| Suffix | Purpose |
|---|---|
| `.test.ts` | Unit — pure logic, no DOM |
| `.test.tsx` | Integration — renders components |
| `e2e/*.spec.ts` | E2E — Playwright browser |

## Phase 3b: Edge-Case Hardening (Optional)

After verification passes, optionally dispatch an agent to generate additional tests:

1. Identify functions/components changed in this PR
2. Generate tests for: boundary values, empty/null inputs, concurrent access, error paths, large inputs
3. Run the generated tests — keep those that pass, investigate those that fail (they may reveal real bugs)
4. Add passing edge-case tests to the committed test suite

**When to use**: new public APIs, security-sensitive code, functions with complex branching logic. Skip for trivial changes.

## Phase 4: Review

### Security Gate

**Hard gate: run before PR creation.** AI-generated code is statistically more likely to contain security issues.

Run SAST/SCA tooling on changed files:
- [ ] No new critical or high findings from static analysis
- [ ] No dependencies with known CVEs introduced
- [ ] No `eval()`, `innerHTML`, `dangerouslySetInnerHTML` without sanitization
- [ ] No hardcoded secrets, tokens, or API keys
- [ ] No SQL/command injection vectors in new code

**Tooling options** (use what the project has; add one if it has none):
- `eslint-plugin-security` — catches common JS/TS security anti-patterns
- `semgrep` — fast, rule-based SAST for multiple languages
- `npm audit` / `pnpm audit` — dependency vulnerability scan
- `trivy fs .` — filesystem-level vulnerability and secret scanning

**Block PR creation** if new critical/high findings appear. Fix first, then proceed to code review.

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

### Regression Evals for AI-Caused Bugs

When a bug is traced to AI-generated code, go beyond fixing it:

1. **Classify the failure**: what category? (e.g., wrong null handling, missed edge case, incorrect API usage, security gap)
2. **Create a regression test**: add a test that catches this exact failure class — not just the specific instance
3. **Add to CI**: ensure it runs on every commit so the same class of error is caught early
4. **Track patterns**: if the same failure class recurs 3+ times, create a `.claude/rules/` entry to prevent the AI from generating it in the first place

This builds a project-specific quality signal that improves over time. Generic linting catches generic issues; regression evals catch *your project's* specific AI failure modes.

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
