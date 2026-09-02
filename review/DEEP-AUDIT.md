# Deep-mode review reference (release audit)

Adapted from Cursor's Thermos correctness and maintainability review postures for a
single-owner, evidence-driven frontend harness audit.

## Posture

Cold review means the reviewer ignores implementation confidence, PR prose, and author self-report until verified. Skip generated files unless the generator, schema, or manual edit is part of the change; generated files are evidence, not review targets. Prefer structural simplification over local polish: delete complexity, collapse branches, move logic to its canonical owner, and make the direct path obvious.

For structural findings, read [the curated Poteto engineering rules](../shared/POTETO-ENGINEERING.md).
Apply reader-load, structural-enforcement, and first-principles rules only when they produce
a concrete diff correction or executable safety proof.

## Structural quality axis

Block or escalate when the PR:
- Misses a concrete Code-judo restructuring that preserves behavior while deleting branches,
  helpers, modes, or layers; require a verifiable alternative, not a preference.
- Pushes a file across 1,000 lines without a strong decomposition reason.
- Adds spaghetti or special-case branching into unrelated flows.
- Spreads feature checks across shared code instead of adding a clear ownership boundary.
- Adds wrappers, helpers, or generic mechanisms that do not reduce concepts.
- Uses casts, `unknown`, unnecessary optionality, or silent fallbacks where a typed boundary would be clearer.
- Serializes independent work or performs non-atomic updates when a simpler structure is obvious.

## Frontend harness axis

Check the project rules before commenting:
- React Compiler: functional components only; do not add `useMemo`, `useCallback`, or `React.memo` for routine memoization.
- UI: interactive controls from `@/components/ui`; all buttons use `<Button>` with `onClick`, `asChild`, `type="submit"`, or `disabled`.
- Accessibility: semantic HTML, icon-button `aria-label`, focus-visible ring, dialog labels, keyboard path, no clickable div/span without role, tabIndex, and handlers.
- Tailwind: design tokens, utility classes, `100dvh`, `width:100%`, no one-off specificity hacks.
- Routing/data: TanStack Router for routes; connect-query for server data; route `errorComponent`; query loading/error/empty states.
- State/env: zustand `create<T>()()` and `useShallow` for multi-selectors; env through `@/env`.
- Forms: `handleSubmit(onSubmit, onError)`, URL inputs `type="url"`, `aria-invalid`, all errors visible, branch values cleared on oneof/union switches.
- Tests: failing test first, `userEvent.setup()`, `getByRole`, `waitFor`, behavior over implementation, warning-free output.
- Harness integrity: `skill-manifest.json` is source of truth; check generated config drift, executable hooks, `_hook-lib.sh`, and quality scripts before blaming agents.

## Release behavior axis

- **Developer experience**: trace changes to secret sources, environment variable names,
  ports/networking, and required setup or build scripts; distinguish new alternatives from
  new mandatory steps.
- **Feature exposure**: trace feature flags and internal-only checks through every public
  surface; report unintended exposure or bypass, not merely distributed conditions.
- **Intended breakage**: distinguish a well-scoped requested change from unintended blast radius;
  omit the requested effect as a defect, but report unacknowledged consequences or unsafe scope.

## Finding evidence schema

Record checked inputs and artifacts before findings. Minimum finding:

```json
{
  "checked": ["diff", "spec", "standards", "runtime evidence"],
  "artifacts": ["test command", "screenshot path", "trace path"],
  "priority": "blocker | major | minor | nit | follow-up for other PR",
  "severity": "P0 | P1 | P2 | P3",
  "axis": "structural | standards | spec | frontend | devex | feature-exposure | resilience | visual | security | tests | perf | steelman",
  "file": "path",
  "line": 1,
  "evidence": "specific proof",
  "impact": "production/user/maintainer consequence",
  "required_change": "concrete requested change",
  "one_shot_prompt": "copy-pasteable fix prompt or null with reason",
  "pr_comment": "GitHub-ready concise comment"
}
```

## Severity

| Severity | Meaning | Merge rule |
|---|---|---|
| P0 | Security hole, data loss, corrupt state, outage, crash, impossible core flow | Block |
| P1 | Normal user failure, fake success, broken required behavior, major a11y miss, unhandled high-risk edge | Block unless owner override |
| P2 | Maintainability, credible edge, measured perf, observability, or test gap with contained impact | Fix or track |
| P3 | Minor cleanup or polish | Advisory |

If unsure, prove lower severity with evidence; otherwise bias upward for important reviews.

## Required artifacts

- Base SHA/branch and diff summary.
- Spec and standards sources; any post-audit PR feedback required by the rule below.
- Applicable-surface statuses and evidence-based skip reasons.
- Exact test/type/lint commands and results.
- UI/customer-facing changes: rendered evidence matrix, screenshots or terminal artifacts, environment fingerprint.
- Credible high-impact failure surfaces: failure-path evidence and the smallest RED contract test.
- Security/dependency changes: scan or explicit skip reason.
- Performance-sensitive changes: bundle/profile/trace evidence or explicit skip reason.

## PR feedback

With P0-P2 candidates and an associated PR, complete the independent audit before reading PR discussion.
Then validate, attribute, and deduplicate relevant automated or human feedback; never
substitute it for direct evidence.

## PR comments

Inspect every applicable surface, but comment only distinct findings. Inline PR comments are
for P0/P1 or high-confidence, actionable P2 issues with a tight file/line, evidence,
impact, and concrete correction. Put evidence gaps, skipped surfaces, speculative concerns,
and duplicate root causes in the top-level summary. Do not post style nits unless they
hide a P2+ risk.

## Approval bar

Approve only when no unresolved P0/P1 remains, spec and standards are accounted for, structural complexity did not regress without justification, required visual/resilience evidence exists or is explicitly skipped, and the PR body can prove what was checked.
