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

| Change | Measure when | Primary benefit | Guardrail |
|---|---|---|---|
| UI bug | Reproducible behavior changes | Reproduction rate, task success, errors | Complexity/workarounds, regression coverage |
| UX/UI flow | Interaction sequence changes | Task success, completion time, clicks, abandonment | Errors, requests, accessibility |
| Accessibility | Semantics or input paths change | Keyboard completion, accessibility violations, contrast/focus failures | Task completion, interaction latency |
| UI performance | Subscriptions, state, rendering, or fetching change | Commit/render count, INP, interaction latency, network requests/bytes | Bundle, memory, errors |
| API/data | Fetching, queries, caching, or payloads change | p50/p95 latency, request/query count, payload bytes, cache-hit rate | Errors, retries, consistency |
| Dependency upgrade | Package API or runtime mechanism changes | Warnings, reachable vulnerabilities, workarounds removed | Bundle/build cost; runtime only when causal |
| AI execution | Prompt, model, tools, or context change | Task success, TTFT, completion latency, token/cost per task | Retries, invalid schemas, open handles |
| AI inspector | Observability or tracing changes | Trace completeness, diagnosis time, dropped spans | TTFT, memory, and trace cost as overhead guardrails |
| Leak/reliability | Async lifecycle or long sessions change | Memory-leak slope, retained objects, open async handles, crash rate | Long-session responsiveness |
| Refactor | Behavior stays invariant while structure changes | Complexity, duplication, dependency count, maintenance surface | Product behavior, build/test time |
| Infrastructure | Runtime or deployment architecture changes | CPU, memory, cold start, throughput, cost/request | Error rate, tail latency |
| Delivery tooling | CI, test, or review workflow changes | CI duration, flaky-run rate, first-pass success, review turnaround | Correctness and coverage invariant |
| Security/privacy | Trust boundaries or dependency exposure change | Reachable vulnerabilities, permissions/scopes, exposed fields, attack paths | UX, latency, operational burden |
| Production outcome | Post-release telemetry is available | Adoption, conversion, retention, support tickets, failure rate | Operational cost and error rate |

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
