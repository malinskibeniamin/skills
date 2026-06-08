---
name: review
description: Reviews diff since fixed point across Standards and Spec, then routes UI/resilience/release risks. Use for branch, PR, WIP, or "review since X".
---

# Review

Diff review from fixed point to `HEAD`. Keep axes separate.

## Inputs

If fixed point missing, ask: "Review against what -- branch, commit, or `main`?"

Use:

- Diff: `git diff <fixed>...HEAD`
- Commits: `git log <fixed>..HEAD --oneline`

## Gather

Spec source, first found wins:

1. issue refs in commits, fetched via `docs/agents/issue-tracker.md`
2. user-provided path
3. PRD/spec under `docs/`, `specs/`, `.scratch/`
4. none -> Spec axis reports "no spec available"

Standards sources:

- `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`
- `CONTEXT.md`, `CONTEXT-MAP.md`, scoped `CONTEXT.md`
- `docs/adr/`
- style docs and config files (`biome`, `eslint`, `tsconfig`, `prettier`, `.editorconfig`)

## Parallel review hats

Spawn all review hats in one message before producing findings, matching `/grill-me` fan-out. Use `general-purpose` subagents. Main agent orchestrates only: gather sources, fan out, merge, dedupe, and write the final report.

Required hats:

- **`regular-review-hat`**: always runs the regular `/review` pass. Review Standards and Spec against the diff. Keep Standards and Spec separate. If no spec exists, return `Spec: no spec available`.
- **`visual-review-hat`**: always checks the visual gate. Run `/visual-review` when the diff touches UI, copy, forms, routes, reports, CLI/TUI output, or visual behavior; otherwise return `skipped` with concrete reason.
- **`resilience-review-hat`**: always checks the resilience gate. Run `/resilience-review` when the diff touches forms, validation, async/data, mutations, cache, state machines, config, destructive actions, or loading/error/empty states; otherwise return `skipped` with concrete reason.
- **`security-privacy-triage-hat`**: always checks whether the diff touches auth, authorization, tenant boundaries, secrets, unsafe HTML, injection, SSRF, redirects, dependency execution, logging, analytics, PII, or data export/import. If none, return `SKIPPED` with reason. If yes, report only exploitable or privacy-impacting issues introduced by the diff.
- **`adversarial-review-hat`**: always runs a lightweight adversarial pass. Ask: "What could still be wrong if tests pass and the implementation matches the spec?" Report only diff-introduced risks with concrete evidence. Do not repeat Standards, Spec, Visual, Resilience, or Security findings. Max 3 findings. If no credible risk, return `APPROVED`.
- **`test-perf-review-hat`**: always checks test and performance gates. Review TDD evidence, coverage gaps, flaky/missing tests, slow paths, render/network/bundle risk, and warning-free commands; otherwise return `skipped` with concrete reason.
- **`thermo-nuclear-review-hat`**: always checks the nuclear gate. Run `/thermo-nuclear-code-quality-review` for release candidates, large PRs, risky refactors, security/privacy/perf/test concerns, or explicit nuclear/cold-audit asks; otherwise return `skipped` with concrete reason.

Subagent prompt contract:

- Include fixed point, changed files, diff command, commits command, exact review type, and sources to read.
- Tell each hat to stay in its lane and not review other hats.
- Require evidence: file/range, rule or spec reference, observed diff behavior, severity, and required change.
- Cap each reviewer at 400 words unless the local review skill defines a stricter format.
- Tell `thermo-nuclear-review-hat`: Do not recursively invoke /review; use `regular-review-hat` output for Standards and Spec coverage.
- Findings must be diff-introduced, user-impacting, and actionable. No speculative "consider" notes unless tied to a plausible failure mode and file/range evidence.

Each hat emits:

```json
{ "reviewer": "<name>", "hat": "<regular|visual|resilience|security-privacy|adversarial|test-perf|thermo-nuclear>", "status": "APPROVED|FINDINGS|BLOCKED|SKIPPED", "findings": [], "must_answer": [] }
```

Merge contract:

- Wait for all hats before verdict.
- Dedupe within each hat by file/range + reference + normalized issue.
- Dedupe across hats by root cause, not wording. Prefer the most specific hat's finding: auth bypass belongs to Security; retry race belongs to Resilience; wrong requirement belongs to Spec.
- Preserve Standards and Spec as separate axes. Cross-link duplicates instead of merging axes.
- Security and adversarial findings may duplicate other hats only when they change severity, exploitability, or release verdict.
- If hats disagree, keep the highest severity and note the disagreement.
- If subagents are unavailable, stop and say the review is blocked unless the user explicitly accepts a degraded solo review.

### Standards

Read standards + diff. Report documented violations only. Cite file + rule. Separate hard violations from judgment calls. Skip what tooling enforces. Max 400 words.

### Spec

Read spec + diff. Report missing/partial requirements, scope creep, wrong behavior. Quote spec line for each finding. Max 400 words. Skip if no spec.

## Local review routing

Each review hat checks its gate:

- UI, copy, forms, routes, reports, CLI/TUI output, visual behavior -> run `/visual-review` or require explicit skip reason.
- forms, validation, async/data, mutations, cache, state machines, config, destructive actions, error/loading/empty states -> run `/resilience-review` or require explicit skip reason.
- auth, permissions, tenant data, secrets, HTML, parsing, network/file access, dependencies, logging, privacy -> security/privacy triage findings or explicit skip reason.
- assumptions, abuse cases, bypasses, rollback, surprising user behavior, spec holes -> adversarial review findings.
- behavior changes, tests, perf-sensitive paths, bundle/runtime/render/network risk -> test/perf review findings or explicit skip reason.
- release candidate, large PR, risky refactor, security/privacy/perf/test concerns, or user asks for nuclear/cold audit -> run `/thermo-nuclear-code-quality-review`.

Do not recursively invoke /review from a local gate already running inside `/review`. Do not duplicate local gate reports. Link or summarize their verdicts.

## Output

```md
## Review
Fixed point: <fixed>
Diff: `git diff <fixed>...HEAD`
Subagents: regular-review-hat: <status> | visual-review-hat: <status/skipped: reason> | resilience-review-hat: <status/skipped: reason> | security-privacy-triage-hat: <status/skipped: reason> | adversarial-review-hat: <status> | test-perf-review-hat: <status/skipped: reason> | thermo-nuclear-review-hat: <status/skipped: reason>

## Standards
<findings or pass>

## Spec
<findings, pass, or no spec available>

## Local review gates
- Visual review: pass | findings | skipped: <reason>
- Resilience review: pass | findings | skipped: <reason>
- Security review: pass | findings | skipped: <reason>
- Adversarial review: pass | findings
- Test/perf review: pass | findings | skipped: <reason>
- Thermo nuclear review: pass | findings | skipped: <reason>

Summary: <standards count>, <spec count>, worst issue: <one line or none>
```

Rules: keep Standards and Spec separate. Findings need evidence. No vague praise.
