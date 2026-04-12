# Development Lifecycle Reference

## Phase 1: Understand

### New Feature
1. Read relevant code, docs, recent git history
2. Ask clarifying questions — one at a time, not list
3. Propose 2-3 approaches with trade-offs
4. For UI work: generate HTML mockup → `agent-browser screenshot --annotate` → iterate
5. Challenge chosen approach (edge cases, failure modes)
6. Get user approval before proceeding

### Parallel Research Agents

While discussing approach with user, spawn background agents to:
- Investigate alternative libraries or patterns for problem domain
- Scan codebase for prior art and existing conventions
- Surface edge cases and failure modes from similar implementations
- Check for open issues or known gotchas in relevant dependencies

Runs concurrently with user discussion — results feed back into approach selection.

### Monitor Tool for Background Observation

Use **Monitor** tool when need to observe long-running process without blocking. Monitor streams output real-time, lets you react immediately instead of sleeping and checking later.

**When to use Monitor:**
- **CI checks**: `Monitor: gh pr checks <number> --watch` — continue working while CI runs
- **Dev server startup**: `Monitor: bun run dev` — watch for "ready" or error messages, then proceed to verification
- **Test runner in watch mode**: `Monitor: bun test --watch` — react to red/green transitions during TDD
- **Container logs**: `Monitor: docker logs -f <container>` — observe runtime behavior while debugging
- **Build processes**: `Monitor: bun run build` — catch build errors as they stream

**Pattern**: start Monitor, continue with other productive work, react when Monitor reports something actionable. Never block waiting for process when you can Monitor it.

### Refactor-First Gate

Before adding features to area with mixed patterns, check:
- [ ] Area use more than one pattern for same concern? (e.g., two state management approaches, mixed CSS strategies)
- [ ] Incomplete migration? (e.g., some files use old API, some use new)
- [ ] Would AI agent need conflicting instructions to work here?

If any true: refactor to single pattern first, separate PR. Then build feature on clean foundation. Mixed codebases produce lower-quality AI output and confuse future maintainers.

### Bug Fix (4-Phase Root Cause Analysis)

**Iron law: no fixes without root cause investigation first.**

1. **Reproduce** — read FULL error message, write failing test
2. **Analyze** — find working examples in codebase, trace data flow upstream to where invalid data ORIGINATES
3. **Hypothesize** — "I think X is root cause because Y." Test ONE hypothesis at a time.
4. **Fix at source** — fix where data originates, not where it crashes. Add defense-in-depth validation at entry point, business logic, environment guards, and debug instrumentation.

## Phase 2: Plan

- [ ] Every task: exact file paths, exact code, expected output
- [ ] No TBD, no "similar to Task N", no "add error handling"
- [ ] Bite-sized (2-5 minutes per task)
- [ ] Test step alongside every implementation step
- [ ] Self-review: spec coverage, placeholder scan, type consistency

### Rapid Prototyping (UI/Interactive Work)

For features with visual or interactive component, replace upfront spec writing with competitive prototyping:

1. Define 2-3 constraint sets (e.g., "minimal DOM, CSS-only animations" vs "component library, framer-motion" vs "canvas-based")
2. Spawn one agent per constraint set in parallel (use `claude-sonnet-4-6`)
3. Each agent produces working prototype — not spec, not mockup
4. Review all prototypes with user: `agent-browser screenshot` each one
5. Select winner and write detailed plan from chosen prototype

**When to use**: any feature where right approach unclear until you see it running. Skip for pure logic, API, or data-layer work.

### Stacked PRs for Large Features

For plans with 5+ tasks, break into stacked PRs:

1. Group tasks by logical boundary (e.g., data layer → business logic → UI → tests)
2. Each group becomes one PR in stack
3. First PR targets base branch; subsequent PRs target previous PR's branch
4. Review and merge bottom-up

**Why**: smaller PRs get reviewed 2-3x faster with higher-quality feedback. 500-line PR gets thorough review; 2000-line PR gets skimmed.

## Phase 2b: Grill

**Mandatory gate between planning and implementation.**

After plan written, auto-initiate `/grill-me` on it:

1. Present plan summary to user
2. Grill plan — challenge assumptions, surface trade-offs, find gaps
3. Resolve every decision branch before proceeding
4. Update plan with any decisions changed during grilling
5. Get explicit user confirmation: "Plan is solid, proceed"

### Why This Phase Exists

Code is byproduct of understanding. If user can't defend every decision in plan under pressure, resulting code becomes cognitive debt — technically correct but owned by nobody. Grill phase ensures human builds mental model *before* LLM writes code, so team can extend, debug, and evolve system long after it ships.

### Skip Conditions

Grill mandatory unless ALL true:
- [ ] Bug fix with single, already-identified root cause
- [ ] Plan has fewer than 3 tasks
- [ ] No architectural decisions involved

If skipping, note in plan: "Grill skipped — trivial bug fix, no architectural decisions."

## Phase 3: Implement (TDD)

### Iron Law
**No production code without failing test first.**

### Cycle
1. RED — write one minimal failing test, verify it fails correctly
2. GREEN — write minimal code to make it pass
3. **TEST INTEGRITY CHECK** — verify test count and assertion count haven't decreased from RED step. If dropped, agent deleted or weakened tests to pass — reject and redo from RED.
4. REFACTOR — clean up while staying green

### Test Quality
- `userEvent.setup()` not `fireEvent`
- `getByRole` for accessibility assertions
- No `setTimeout`/`waitForTimeout` — use `await waitFor(() => expect(...))`
- Run `--detectAsyncLeaks` after

### Test Deletion Guard

AI agents sometimes delete or simplify tests to make them pass — Kent Beck calls this "unpredictable genie" effect. Defenses:

1. **Count check**: before GREEN, note number of `it()`/`test()` blocks and `expect()` calls. After GREEN, verify counts equal or higher.
2. **Diff review**: if any test file has deletions in GREEN step, flag for manual review.
3. **Pre-commit hook** (optional): reject commits that reduce assertion count in test files without explicit `// intentional: [reason]` comment.

### Classification
| Suffix | Purpose |
|---|---|
| `.test.ts` | Unit — pure logic, no DOM |
| `.test.tsx` | Integration — renders components |
| `e2e/*.spec.ts` | E2E — Playwright browser |

## Phase 3b: Edge-Case Hardening (Optional)

After verification passes, optionally dispatch agent to generate additional tests:

1. Identify functions/components changed in this PR
2. Generate tests for: boundary values, empty/null inputs, concurrent access, error paths, large inputs
3. Run generated tests — keep those that pass, investigate those that fail (may reveal real bugs)
4. Add passing edge-case tests to committed test suite

**When to use**: new public APIs, security-sensitive code, functions with complex branching logic. Skip for trivial changes.

## Phase 4b: Refine (Self-Review Loop)

**Goal**: catch quality gaps, missing tests, and simplification opportunities while context is fresh — before external review.

### When to Run

- **Always** for features and bug fixes (unless skip conditions met)
- **Skip if**: trivial change (<10 lines, no logic), pure test-only change, documentation-only change

### Process

1. **Dispatch self-reviewer**: `self-reviewer` agent on session diff
2. **Conditional adversarial review**: if diff >50 lines OR touches auth/security paths, also dispatch `adversarial-reviewer` in parallel
3. **Collect findings**: SubagentStop hook validates JSON output, writes to session dir
4. **Process by priority**:

| Priority | Action |
|----------|--------|
| P0 (blocks merge) | Fix immediately, re-run tests |
| P1 (should fix) | Fix, re-run tests |
| P2 `safe_auto` | Apply automatically (missing imports, typos) |
| P2 `gated_auto` | Show to user, apply on confirmation |
| P2 `manual` | Report, let user decide |
| P3 / `advisory` | Skip — log for Phase 6 (Compound) |

5. **After fixes**: commit with `refactor(scope): self-review fixes`, re-verify (tests + types + lint)
6. **Max 2 refinement rounds** — if P0/P1 findings persist after 2 rounds, proceed to Review anyway and flag them

### Structured Findings Format

All reviewers output JSON per `agents/findings-schema.md`. Key fields:
- `severity`: P0–P3
- `autofix_class`: `safe_auto | gated_auto | manual | advisory`
- `pre_existing`: `true` if issue was in dirty baseline (never blocks merge)
- `confidence`: 0.0–1.0 (low confidence = advisory only)

### SubagentStart Context

The SubagentStart hook automatically injects into all subagents:
- Session-touched files (what this session modified)
- Dirty baseline (pre-existing changes to filter)
- Branch and PR context
- Pointer to findings-schema.md for reviewer agents

### SubagentStop Validation

The SubagentStop hook (matcher: `self-reviewer|code-reviewer|adversarial-reviewer`):
- Validates output contains valid JSON matching findings schema
- Blocks and forces retry if output is malformed
- Writes valid findings to `/tmp/hook-session-$SESSION_ID/review-findings.json`
- Logs summary to `review-summary.log`

### Agents

| Agent | Focus | When |
|-------|-------|------|
| `self-reviewer` | Testing gaps, simplification, CI readiness, maintainability | Always in 4b |
| `adversarial-reviewer` | Failure scenarios, boundary conditions, race conditions | Diff >50 lines or auth/security |
| `code-reviewer` | Spec compliance, code quality (fresh-eyes) | Phase 5 (Review) |

## Phase 4: Review

### Security Gate

**Hard gate: run before PR creation.** AI-generated code statistically more likely to contain security issues.

Run SAST/SCA tooling on changed files:
- [ ] No new critical or high findings from static analysis
- [ ] No dependencies with known CVEs introduced
- [ ] No `eval()`, `innerHTML`, `dangerouslySetInnerHTML` without sanitization
- [ ] No hardcoded secrets, tokens, or API keys
- [ ] No SQL/command injection vectors in new code

**Tooling options** (use what project has; add one if none):
- `eslint-plugin-security` — catches common JS/TS security anti-patterns
- `semgrep` — fast, rule-based SAST for multiple languages
- `bun audit` — dependency vulnerability scan
- `trivy fs .` — filesystem-level vulnerability and secret scanning

**Block PR creation** if new critical/high findings appear. Fix first, then proceed to code review.

Dispatch `code-reviewer` agent for fresh-eyes review. Two stages:

### Stage 1: Spec Compliance
- [ ] All requirements from issue/PRD addressed
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
Requires: `bun install -g @openai/codex` and OpenAI API key.
Install plugin: `/plugin marketplace add openai/codex-plugin-cc` → `/plugin install codex@openai-codex` → `/codex:setup`

### Ship
```bash
gh pr create --title "type(scope): description" --body "..."
gh pr comment <URL> --body "@claude review"
```

## Phase 5b: Iterate

### Monitor CI Instead of Blocking

Use **Monitor** tool to watch CI in background instead of blocking on `gh pr checks --watch`. Lets you continue working (fixing lint, writing docs, addressing other feedback) while CI runs, react immediately when it fails or passes.

```
Monitor: gh pr checks <pr-number> --watch
```

When Monitor reports CI failure, diagnose and fix immediately. When reports success, proceed to next step. Same after every `git push` — start Monitor and continue working.

**Round 1 — Initial review:**

1. Push and start monitoring CI: `Monitor: gh pr checks <pr-number> --watch`. Continue with other work while CI runs.
2. When CI green, dispatch `code-reviewer` agent for first review.
3. Run `/resolve-pr-feedback` to triage findings, fix, reply on threads, and push.
4. Monitor CI again after push.

**Round 2 — Verification review:**

1. Dispatch `code-reviewer` agent for second review (verifies Round 1 fixes correct and didn't introduce new issues).
2. Run `/resolve-pr-feedback` to address remaining findings.
3. If new issues found: fix, push, monitor CI. Do NOT trigger third review round.

**Hand off to human:**

After Round 2 completes:

1. Post final PR comment summarizing: what changed, what both reviews found, how addressed, and test coverage.
2. Request review from appropriate team member: `gh pr edit <number> --add-reviewer <username>`
3. **Stop.** Do not poll for human approval.

**If human requests changes later** (new session):

1. Run `/resolve-pr-feedback` — fetches comments, triages, fixes, replies, and pushes
2. Monitor CI after push
3. Run one more code-reviewer round + `/resolve-pr-feedback` for any new findings
4. Re-request human review, then stop

**Exit conditions:**
- **Normal exit**: CI green + 2 automated review rounds complete + human reviewer requested → stop
- **Re-entry**: human requests changes → new session, one review round, then stop
- **Never**: poll waiting for human approval or run more than 2 review rounds per session

### Deploy Pipeline Monitoring (Post-Merge)

After PR merged, use **Monitor** tool to watch deploy pipeline:

```
Monitor: gh run watch
```

Lets Claude detect deploy failures immediately after merge instead of requiring user to check manually. If deploy fails, diagnose issue and open follow-up PR with fix.

## Hard Rules

- Never ask user to test manually. Use agent-browser, playwright, or test runner.
- Never skip Phase 1. Understand before building.
- Never write production code without failing test first.

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
- Bug fix that revealed non-obvious pattern
- Migration gotcha that will recur
- API contract or convention team agreed on

**When NOT to compound:**
- One-off fix unlikely to recur
- Pattern already covered by hook
- Generic knowledge Claude already has

### Regression Evals for AI-Caused Bugs

When bug traced to AI-generated code, go beyond fixing:

1. **Classify failure**: what category? (e.g., wrong null handling, missed edge case, incorrect API usage, security gap)
2. **Create regression test**: add test that catches this exact failure class — not specific instance
3. **Add to CI**: ensure runs on every commit so same class of error caught early
4. **Track patterns**: if same failure class recurs 3+ times, create `.claude/rules/` entry to prevent AI from generating it

Builds project-specific quality signal that improves over time. Generic linting catches generic issues; regression evals catch *your project's* specific AI failure modes.

## Cross-Model Review

If `/codex:rescue` available: auto-dispatch plan for second opinion. For bug triage: use GitHub issue comments as communication channel between models.

## Subagents

| Agent | Role | When dispatched |
|---|---|---|
| `self-reviewer` | Testing gaps, simplification, CI readiness, maintainability | Phase 4b (Refine) |
| `adversarial-reviewer` | Failure scenarios, boundary conditions, race conditions | Phase 4b (Refine, conditional) |
| `code-reviewer` | Fresh-eyes spec compliance + quality review | Phase 5 (Review) |
| `verifier` | Run tests + visual verification via browser | Phase 4 (Verify) |

## Parallelization Guide

| Task | Parallelize? | How | Sweet spot |
|---|---|---|---|
| Codebase-wide migration | Yes | `/batch` (built-in) | 5-30 agents, one per file/module |
| Security scan | Yes | `/batch` or Sandcastle | 3-5 agents, each scans directory |
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