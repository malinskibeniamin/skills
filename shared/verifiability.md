# Verifiability over readability

Use when designing, reviewing, refactoring or assessing code health. Judge a module
by how reliably its behavior can be verified, not how quickly its implementation
can be read. Agents should gather executable evidence: run focused tests, probe the
public interface and inspect observed results instead of relying on source fluency.

## Proportionate verification

Choose the cheapest check that can catch a credible failure in the changed contract.
Reuse existing tests and current results; add one focused regression only for an uncovered
risk. A routine edit may need only existing checks or a direct inspection/probe. Escalate
for shared contracts, security, money, data loss or difficult recovery, not by test quotas.

Test our decisions, transformations and integration assumptions, not a dependency's
documented behavior (for example date-fns formatting or lodash/ramda helpers). Avoid
self-comparisons, duplicate layers and wrappers/seams added only to make tests possible.
When a new test is warranted, show it fails for the intended regression before the fix.

Inspect changed UI; retain a focused screenshot/comparison only when it resolves a visual
question or helps review. Video, annotations, diagrams, reports and replay files are
conditional tools, not automatic deliverables. Reuse captures across checks; keep output
in temporary/ignored scratch and summarize commands, results and material limits inline.
Persist only requested artifacts, existing required outputs or a reusable maintenance asset.
Stop when the requested behavior and credible risks are covered; preserve project gates.

## Dead code and duplication

For unused/unreachable code, dead stores, duplicate functions/branches or feature
retirement, diagnose before deleting, merging or applying an unsafe autofix:

- Trace the surrounding control/data flow. Classify the report as intentional,
  leftover, suspected bug or uncertain. Check whether a computed/resolved value should
  replace the original still used downstream; deleting its initializer can hide that bug.
- Fix an evidenced in-scope bug with a focused regression, explicitly naming the behavior
  change. Minimal diff means the smallest correct fix, not preserving known wrong behavior.
  Under an explicit behavior-preserving-only scope, report the suspected bug and location;
  leave its diagnostic visible rather than silently deleting the clue. Uncertain intent
  needs evidence, not a speculative rewrite.
- Remove dispensable bindings. Use the project's unused-name convention for required
  signature positions or deliberate omission (such as object-rest exclusion), not to hide
  dead locals. Preserve necessary calls, getter effects and memory-release assignments;
  a documented side-effect expression is valid, a dummy read/`void` or suppression solely
  to silence lint is not. Check actual lint/compiler settings; `_` is not portable.
- Before writing another copy, look for an existing domain helper. Before sharing copies,
  compare their intended contracts: identical branches may need different results, and
  independent domains may intentionally look alike. Merge shared knowledge, not syntax;
  verify each affected case, including differences the copied code may have lost.
- Treat unused-export/file reports as candidates. Check whole-program references,
  package entry points/public API, dynamic lookup, registration and import side effects.
  Absence of incoming graph edges or local references alone does not justify deletion; incomplete
  coverage stays unknown. Use existing whole-program tooling when available, not a new
  dependency or broad cleanup by default.
- For confirmed retired features, remove obsolete implementation and flag paths within
  scope after checking consumers and mixed-version rollout needs. A disabled flag or
  unobserved execution alone does not prove retirement; reachable code can still be obsolete.

In the existing PR/handoff, state why deletion/retention/sharing is correct, the behavioral
check and any suspected bug left unresolved. A clean lint run proves diagnostic clearance,
not correctness; inspect autofix diffs for hidden renames/deletions too.

Source: [Ultracite's dead-code research](https://www.ultracite.ai/research/dead-code).

## Keep humans connected

Use the human's domain language in interfaces, types, tests and diagnostics; follow
`GLOSSARY.md` and settled ADRs. Keep the contract, state owner, important invariants
and verification entrypoint discoverable so a human can jump in for observability,
incident diagnosis or consequential PR spot-checks. Optimize for that intervention,
not making every implementation small or immediately familiar.

## Design independently verifiable modules

- Test behavior through the same stable interface callers use. A focused command
  and representative fixture should exercise a module without booting unrelated
  application layers or reaching into private implementation details.
- Control relevant dependencies, state, time and randomness at existing seams.
  Keep setup/reset repeatable; expose outcomes and actionable failure diagnostics.
  Test doubles isolate the module; integration checks still verify real dependency
  contracts. Add a seam for a concrete verification need, not hypothetical testing.
- Use an independent oracle: specified outcomes, worked examples, production-shaped
  fixtures, or a trusted reference implementation. Prove a plausible wrong behavior
  fails; test credible failure/recovery paths, not just the happy path.
- Keep the smallest rerunnable proof and name what it misses. Even 100% line or
  branch coverage cannot establish assertion quality, correct requirements or real
  integration behavior; passing tests do not replace source, security or impact review.

## Trade-offs need evidence

Function/file size, nesting depth and cyclomatic complexity are not standalone
quality scores, refactor triggers or review findings. Split by independently
verifiable responsibilities and state ownership, not arbitrary thresholds. Simplify
when it improves verification, removes a concrete failure mode or lowers change
coordination; a smaller diff or more helpers is not proof of improvement.

Keep a less readable implementation when a representative benchmark proves a
worthwhile performance gain and contract tests preserve behavior. Retain the
invariant, trade-off and rerunnable benchmark for human inspection. A large optimized
module with strong independent checks need not be split; a short elegant module
whose behavior cannot be exercised needs a better verification seam. Unmeasured
cleverness earns no performance exemption.
