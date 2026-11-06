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
2. If edits already exist, resolve the current PR layer with
   `BASE_REF=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`, set
   `BASE=$(git merge-base "$BASE_REF" HEAD)`, and reconstruct that tree in an isolated
   checkout or build artifact. Set `PR_BASE_REF` to the trunk only when the thesis measures
   the whole stack rather than one layer.
3. Record both SHAs and dirty state.
4. Install each tree from its own lockfile. Use the same runtime/browser version, machine, power mode, fixture, data size, build mode, cache state, and command.
5. Compare production builds for user performance unless the claim explicitly concerns development.
6. Store raw commands and outputs under `.context/impact/<change>/` after confirming `.context/` is gitignored; otherwise use `$TMPDIR/quantify-impact-<change>/`. Commit a harness only when it becomes useful regression protection.

## Rigor tiers

### Exact or deterministic

Run the smallest repeatable scenario. Counts such as requests, errors, warnings, handles, bytes, or reproductions need no statistical ceremony when deterministic. Repeat enough to prove the setup itself is stable.

### Runtime or noisy

Use the selected measurement tool's current documented protocol when available; otherwise
use these defaults. Declare the run count/stopping rule before sampling; early stopping
requires a valid sequential protocol, not a favorable interim result.

1. Run three warm-ups per candidate only for a warm-state claim; reset cold-state trials.
2. Choose a fixed budget before comparing: 5 paired before/after runs for a stable setup;
   10-30 pairs when prior noise or stakes justify them.
3. Alternate base/candidate order when feasible; evaluate at the declared stopping point.
4. If exploratory runs or adaptive sample counts selected a winner, confirm it with a
   separate fixed batch before keeping it.
5. Report median, absolute delta, percentage delta, and spread. Report p95 only when the sample count supports it; never disguise the maximum of five runs as a stable p95.
6. If the delta is at or below noise, report `inconclusive`, not `faster`.

Use paired inputs and the same scenario. Separate cold-start and warm-cache claims. For networked dependencies, prefer a controlled local fixture; otherwise record service region, response variability, and limitations.

For optimization, define [feature-fidelity assertions](../shared/verification-replay.md)
before measuring; dropping intended behavior is a regression, not a faster equivalent.
For repeated attempts, use the experiment loop below and retain compact
[progress evidence](../shared/progress-evidence.md), not a second mandatory artifact.

## Optimization experiments

Use for measured page, service/runtime startup, interaction, throughput, resource or
compiler-cost optimization. Use the target's existing build, tests and measurement tools;
read their current help/manual instead of copying a tool-specific recipe into the task.

1. **Freeze the comparison.** Before edits, save the original build/revision, workload,
   environment and output/behavior assertions. Declare primary metric(s), worthwhile delta,
   noise rule, protected metrics and run/stopping rule. For deferral, protect affected
   first-use/end-to-end latency with bounds declared before edits; only the user can accept
   a tradeoff that relaxes them. Keep this original reference for cumulative results.
   A latest-accepted reference may advance after a verified win, but never replaces the
   original. Changed fixtures, throttling or measurement boundaries need a fresh baseline
   before further edits; disclose the break rather than compare incompatible runs.
2. **Track leads, not just wins.** Source warnings, cold bytes, import graphs and profiles
   suggest experiments; they do not prove a speedup. Keep one compact checklist of applicable
   signals/leads: `OPEN`, `clear` or `UNKNOWN`, bound to the measured revision/scenario.
   Check gating bottlenecks before downstream tuning. One empty profiler does not clear
   other signals; a faster baseline does not itself close a lead.
3. **Change one cause.** State a falsifiable hypothesis and make the smallest reversible
   intervention. Rebuild and run relevant tests, then repeat comparable paired measurements.
   Require every sample to contain all declared primary metrics; missing values are invalid,
   not zero. Retain attempted-trial counts and missing-value reasons. Outcome-dependent
   failures/timeouts cannot be discarded into a win: resolve them or mark it inconclusive.
   Test deferred work at first use as well as startup: moving cost is not deletion.
4. **Keep or revert.** At least one declared primary metric must improve beyond noise
   and the worthwhile delta against the latest accepted reference. No primary metric may
   regress beyond noise against either the original or accepted reference. Protected metrics
   and behavior must also hold against both. Revert a losing or inconclusive experiment's owned
   edits, preserving unrelated work and earlier verified wins. Advance
   the accepted reference only after these checks; preserve results against both references.
5. **Verify equivalence.** Compare final output against the original and replay affected
   interactions with [fidelity assertions](../shared/verification-replay.md). A faster broken
   result is invalid. Static rendered-output parity does not cover login, clicks or live
   data. Only the user can accept an intended difference or authorize a comparison mask;
   repair mismatches rather than self-approving, masking or replacing the original to pass.
6. **Close honestly.** Refresh applicable signals on the final candidate. Every remaining
   `OPEN` lead needs measured evidence or a concrete constraint and next action. Missing,
   stale or unsupported signals remain `UNKNOWN`, never clear. Distinguish verified gains,
   completed investigation and constrained/partial coverage; claim no unqualified completion
   with unexplained leads or unknowns. Stay within the requested scope and endpoint.

Report original-to-final numbers with method/noise, each tried change (kept and reverted)
with its delta and verdict, and the file/reason each kept change is safe. Use a compact
diagnostic attempt record; identify its comparison reference and label within-noise values
as inconclusive, not gains. Include final fidelity status and unresolved leads/limits.
Keep raw traces and samples in ignored or temporary storage; lab deltas support only the
tested machine/scenario, not a real-user or production claim.

## Interpretation

- Primary clears minimum worthwhile delta and guardrail holds: **Value proven**.
- Primary improves but below threshold or within noise: **Value not proven -- inconclusive**.
- Primary unchanged: **Value not proven**.
- Guardrail materially regresses: **Value not proven -- regression**.

Do not select a replacement metric after seeing results. A new metric requires a new thesis
and baseline. One evidence-driven revision is reasonable; after another miss, scrap that
hypothesis. In scoped multi-lead optimization, proceed to a distinct supported lead rather
than stop at the first failed experiment. Narrow or close the PR when no feasible useful
lead remains. Negative research is useful; preserve its method and `Value not proven`
conclusion in the PR/issue, while keeping suppressed raw measurements in local evidence.

## Output filter

Measurement and publication are separate decisions. A metric belongs in quantified impact output only when its delta:

1. measures a direct or explicitly justified proxy outcome;
2. clears the minimum worthwhile delta registered before measurement; and
3. exceeds normal variance when the measurement is noisy.

There is no universal percentage cutoff. The scenario and decision determine what is worthwhile. Exact counts are noise-free, but still need to be large enough to matter.

- Suppress every below-threshold or within-noise metric, even when another metric qualifies.
- Suppress negligible guardrail movement entirely. Do not show its raw values or emit a `Guardrail held` line solely because it was measured.
- Keep suppressed raw output in `.context/impact/<change>/` when it helps reproduce or audit the work; do not promote it into PR impact claims.
- If no metric qualifies and the change makes an explicit performance claim, state **Value not proven** without listing the negligible deltas.
- If no metric qualifies and there is no explicit performance claim, omit the quantified impact section and use a normal value summary.

Do not round a negligible delta into apparent significance, combine several immaterial metrics into a value claim, or publish a metric merely because the tooling produced it.

This filter governs claimed impact, not the diagnostic experiment record above or an
explicitly requested attempt report. Those retain failed/within-noise deltas with their
verdicts so rejected experiments remain visible without becoming improvement claims.

## Existing CI regression budgets

Inspect a standing benchmark's fixture, measurement boundary, assertions, and publisher,
not just its green comment. Distinguish infrastructure already present from changes made
by this PR, and a budget pass from an improvement. Bytes, decoded payload, message counts,
latency, and UI responsiveness answer different questions; preserve functional assertions
so dropping content cannot win. Mark timing-sensitive diagnostics separately from gates.

Bind results to source run/head, baseline SHA, scenario/schema, units, and ceilings. Disclose
a fallback baseline or changed fixture/budget; omit invalid comparisons. A missing artifact
or stale result is missing evidence, not zero. Keep diagnostic detail in linked artifacts;
the output filter above still excludes negligible movement from claimed impact.

When changing a privileged publisher, load [CI maintenance](../t3code-skills/ci-maintenance/SKILL.md).
Read bounded, validated result data from PR artifacts using trusted publisher code, never
execute PR code with publishing credentials. Recheck head before publishing, update one
identified report, and test stale/missing/malformed inputs. These checks do not certify
artifact integrity or every workflow trust boundary by themselves.

## Reproducible PR evidence

Put only decision-useful results first:

```md
## Proven impact

| Metric | Before | After | Delta |
|---|---:|---:|---:|
| Open async handles | 100 | 0 | -100 (-100%) |

**Value proven:** async work now settles without leaking handles.

Method: `bun test inspector.test.ts --detectAsyncLeaks`; 5 identical fixtures; macOS 16, Bun 1.3.14; base `<sha>`, candidate `<sha>`.
```

Link or summarize the exact command, environment, fixture, raw artifact path, run count, and limitations. Keep detailed logs out of the repository unless they are intentional test fixtures.
