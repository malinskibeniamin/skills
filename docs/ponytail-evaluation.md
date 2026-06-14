# Ponytail Evaluation

**Date:** 2026-06-14
**Status:** Vendor skills, do not vendor runtime hooks
**Repository:** https://github.com/DietrichGebert/ponytail
**Revision analyzed:** 687c1b339872289d70f65c5eaabce850b1663867

## What is Ponytail?

Ponytail is a compact agent rule set and plugin that forces a reuse-first, minimal-code reflex. Before writing code, it asks whether the work should be deleted or skipped, then whether the standard library, native platform, an installed dependency, or one-line code already solves it.

## What maps well to this harness

- **Reuse-first ladder** -- stronger and more operational than our existing generic "minimal" wording.
- **Review vocabulary** -- delete, stdlib, native, YAGNI, shrink are useful labels for simplification findings.
- **Portability pattern** -- one core rule copied into multiple agent surfaces with drift checks.
- **Evidence loop** -- Ponytail ships hook tests and rule-copy tests; this matches our eval-first harness style.

## What we should not adopt

- **Always-on mode switching** -- our harness already routes by skill, hook, and lifecycle phase; a persistent persona mode would fight task-specific skills.
- **Separate plugin runtime** -- more hooks, statusline state, and mode files would add ownership cost without unique enforcement power.
- **Tiny-test exception as written** -- our ETHOS keeps failing tests first for production code. We can keep "smallest useful test," not "skip tests by default."
- **Benchmark claims as policy** -- useful signal, but our adoption should depend on local evals, not external benchmark numbers.

## Harness scan

Scanned the pre-vendor surface: 75 skills and 108 hook scripts. Final surface is 79 skills. Useful integration points are review orchestration, `/deslop`, `/improve`, `/diagnose`, `/work` and `/development-lifecycle`, `/tdd` GREEN, `/swarm` worker packets, `/prototype`, ship cleanup, commit preflight review evidence, self/code reviewers, and prompt-time implementation nudges. No Ponytail runtime hook is needed.

## Adopted changes

1. Vendor `/ponytail`, `/ponytail-audit`, `/ponytail-debt`, and `/ponytail-review` with MIT provenance; ignore the upstream help skill.
2. Add the reuse-first ladder to `/deslop`, `/work`/lifecycle, TDD GREEN guidance, `/swarm`, `/prototype`, and `/write-a-skill`; add audit/debt to `/deslop` and `/improve`.
3. Inject `[REUSE-FIRST]` in the existing intent hook so consumer repos get the less-code nudge before implementation.
4. Make `/review` run a `ponytail-review-hat`; make `/deslop` compose `/ponytail-review` before the liability gate.
5. Add evals so the four vendor skills and review/deslop/improve/diagnose integration cannot drift.

## Decision

Ponytail has high skill fit and low runtime fit. Vendor the skills and review lane; do not vendor mode-tracker/statusline hooks.
