# Quantify impact reference

## Evidence contract

Before implementation, record:

```md
Thesis: <why the product or codebase should improve>
Primary metric: <direct outcome>
Guardrail: <other value lane that must not regress>
Scenario: <fixture, route, action, data volume, build mode>
Minimum worthwhile delta: <threshold beyond normal noise>
Base: <commit SHA>
Candidate: <commit SHA or working tree>
```

Prefer a direct outcome over a convenient proxy. Use a proxy only when its causal link is explicit. Coverage, lines changed, Lighthouse score, and synthetic timing are not proof by themselves.

## Metric map

| Change | Product lane | Codebase lane |
|---|---|---|
| UI bug | Reproduction rate, task success, errors, steps | Branches/workarounds removed, regression coverage |
| UI performance | Commit/render count, interaction latency, network requests/bytes | Bundle size, dependency or observer count |
| Dependency upgrade | User-visible behavior, vulnerabilities, requests/renders when causally affected | Deprecation warnings, code/polyfills removed, bundle/build cost |
| AI feature | Task success, TTFT (time to first token), completion latency, token/cost per task | Open async handles, heap growth, retries, test duration |
| Leak fix | Crash/repro rate, long-session responsiveness | Memory leak slope, retained objects, open async handles |
| Refactor | Behavior invariant plus developer task time when observable | Complexity, duplication, dependency count, maintenance surface |

Good exact evidence includes `bug reproduction 5/5 -> 0/5`, `network requests 12 -> 4`, `open async handles 100 -> 0`, `warnings 18 -> 0`, or `bundle 248 kB -> 221 kB`. Do not claim faster renders because an upgraded API merely looks simpler.

## Base and candidate

1. Prefer a pre-edit baseline.
2. If edits already exist, resolve the repository's default branch, set `BASE=$(git merge-base origin/<default> HEAD)`, and reconstruct that tree in an isolated checkout or build artifact.
3. Record both SHAs and dirty state.
4. Install each tree from its own lockfile. Use the same runtime/browser version, machine, power mode, fixture, data size, build mode, cache state, and command.
5. Compare production builds for user performance unless the claim explicitly concerns development.
6. Store raw commands and outputs under `.context/impact/<change>/` after confirming `.context/` is gitignored; otherwise use `$TMPDIR/quantify-impact-<change>/`. Commit a harness only when it becomes useful regression protection.

## Rigor tiers

### Exact or deterministic

Run the smallest repeatable scenario. Counts such as requests, errors, warnings, handles, bytes, or reproductions need no statistical ceremony when deterministic. Repeat enough to prove the setup itself is stable.

### Runtime or noisy

1. Run three warm-ups per candidate.
2. Start with 5 paired before/after runs, alternating order when feasible.
3. Stop when the delta clearly exceeds run-to-run variance and the pre-registered threshold.
4. Extend to 10-30 pairs only for ambiguous, noisy, or high-stakes results.
5. Report median, absolute delta, percentage delta, and spread. Report p95 only when the sample count supports it; never disguise the maximum of five runs as a stable p95.
6. If the delta is at or below noise, report `inconclusive`, not `faster`.

Use paired inputs and the same scenario. Separate cold-start and warm-cache claims. For networked dependencies, prefer a controlled local fixture; otherwise record service region, response variability, and limitations.

## Interpretation

- Primary clears minimum worthwhile delta and guardrail holds: **Value proven**.
- Primary improves but below threshold or within noise: **Value not proven -- inconclusive**.
- Primary unchanged: **Value not proven**.
- Guardrail materially regresses: **Value not proven -- regression**.

Do not select a replacement metric after seeing results. A new metric requires a new thesis and baseline. One evidence-driven revision is reasonable; after another miss, recommend scrap or close the PR. Negative research is useful; preserve the method and result in the PR/issue instead of forcing a merge.

## Reproducible PR evidence

Put the result first:

```md
## Proven impact

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| Open async handles | 100 | 0 | -100 (-100%) |

**Value proven:** async work now settles without leaking handles.

Method: `bun test inspector.test.ts --detectAsyncLeaks`; 5 identical fixtures; macOS 16, Bun 1.3.14; base `<sha>`, candidate `<sha>`.
```

Link or summarize the exact command, environment, fixture, raw artifact path, run count, and limitations. Keep detailed logs out of the repository unless they are intentional test fixtures.
