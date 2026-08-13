# UX performance regression gates

## Contents

- [Build a layered system](#build-a-layered-system)
- [Choose enforceable budgets](#choose-enforceable-budgets)
- [Keep pull requests fast](#keep-pull-requests-fast)
- [Run deep suites on schedule](#run-deep-suites-on-schedule)
- [Close the loop with real-user monitoring](#close-the-loop-with-real-user-monitoring)
- [Use hooks sparingly](#use-hooks-sparingly)
- [Load test only the evidenced service path](#load-test-only-the-evidenced-service-path)

## Build a layered system

Performance assurance should resemble service testing: cheap contract checks close to the
change, controlled journey tests before release, sustained tests off the critical path, and
production signals after deploy.

| Lane | Purpose | Candidate evidence |
|---|---|---|
| local | explain a suspected bottleneck quickly | browser trace, profiler, React Doctor/React Scan, bundle analysis |
| pull request | stop stable attributable regressions | asset/chunk bytes, request/DOM/render counts, one or two custom journey budgets |
| nightly/pre-release | exercise variance and scale | repeated Lighthouse/browser matrix, million-record scenario, memory soak, load/stress test |
| post-deploy | protect actual users | RUM p75 Core Web Vitals, route/action p75/p95, errors, release and device/network segments |

Do not copy every tool into every lane. One tool may diagnose locally while a smaller direct
contract prevents the proven failure in CI.

## Choose enforceable budgets

For each budget record owner, journey, fixture, environment, metric, absolute UX target,
allowed regression, run count, noise band, artifact, and expiration/recalibration rule.
Prefer direct numeric metrics over a composite Lighthouse score:

- route-level JS/CSS/media/third-party transfer and parsed bytes;
- request count, critical chain length, cache-hit outcome, and payload bytes;
- intent-to-useful-paint, custom User Timing, TBT, long-task count/duration;
- React commit/render and bounded mounted-row/DOM counts where deterministic;
- memory/retained-resource slope for repeated SPA round trips;
- service latency percentile, throughput, error rate, and saturation under named load.

Use an absolute product target plus a relative regression check when both are stable. Calibrate
from repeated clean main-branch runs; never ratchet a transient best result into the budget.
Version the fixture and update the budget only with evidence and owner review.

Lighthouse CI can assert individual numeric audits, user timings, resource counts/bytes, and
multiple routes over repeated runs. Keep the Lighthouse performance score informational: its
weighting and lab variance obscure which user outcome changed. Lighthouse also substitutes
TBT for real field INP.

## Keep pull requests fast

A PR gate must be deterministic enough to trust, fast enough to keep, attributable to the
diff, and emit an actionable trace/report on failure.

- Build the production artifact once and feed it to bundle, route, and browser checks.
- Select affected routes/journeys from changed ownership or an explicit small smoke matrix.
- Compare candidate and merge-base on the same pinned runner/browser when timings are noisy.
- Use deterministic data and stub only dependencies not owned by the claim. Keep realistic
  payload sizes, response ordering, cache headers, and delays.
- Repeat runtime checks, report samples and spread, and warn before blocking while calibrating.
- Attach HAR/trace/Lighthouse JSON/bundle diff on failure. Fail on the metric and budget, not
  on a generic "performance dropped" message.
- Run React Doctor's performance category on changed scope if the repository already uses it.
  Static warnings generate work items; they do not prove runtime latency.

Do not assert render milliseconds in jsdom, use unpinned public endpoints, or make every PR
run a long soak. Promote a check to blocking only after it demonstrates low false-positive
rate and catches a positive control or known regression.

## Run deep suites on schedule

Nightly or pre-release jobs may include:

- five or more Lighthouse/browser runs across representative mobile/desktop and cold/warm
  route states;
- SPA soft-navigation and interaction suites with User Timing and trace artifacts;
- worst credible table/data workloads, scroll and keyboard journeys, and bounded DOM checks;
- memory soak tests over repeated navigation, mount/unmount, filter/clear, and open/close;
- bundle/chunk/coverage trend reports and third-party cost audits;
- safe service average-load, stress, spike, and soak tests when backend latency is causal.

Quarantine unstable measurements from blocking CI, not from visibility. Assign an owner and
fix-by condition; a permanently advisory red dashboard is not a gate.

## Close the loop with real-user monitoring

Collect LCP, INP, and CLS plus product-specific SPA transition and interaction milestones.
Aggregate at p75 for Core Web Vitals and appropriate p75/p95 tails for journeys. Segment by
route, release, device class, browser, connection, geography, cache/navigation type, and
feature flag while protecting privacy and cardinality limits.

Alert on sustained regression or error-budget burn, not a single sparse bucket. Compare
canary with control, annotate deploys, and link slow samples to trace IDs where safe. Lab CI
prevents known regressions; RUM reveals devices, networks, content, and interactions the lab
did not model.

## Use hooks sparingly

Every hook must be stable, cheap, and actionable. Optional pre-commit/pre-push or agent hooks
should stay on changed scope, such as an existing bundle manifest guard, React Doctor
diff scan, or verification that a performance fixture was updated with its contract. Keep
profilers, Lighthouse, browser timing, React Scan, and load tests out of per-edit hooks.

Start new hooks advisory and log fire rate, latency, bypasses, false positives, and fixes.
Promote only after evidence. Prefer the repository's existing quality command and CI source
of truth; do not maintain a second manual list of performance commands in hook config.

## Load test only the evidenced service path

Run load tests against an approved non-production or isolated environment unless explicit
production permission and safeguards exist. Model real endpoints, payloads, authentication,
arrival rate/concurrency, dataset cardinality, think time, cache mix, and dependency limits.

1. Smoke the script and validate response correctness.
2. Establish ordinary load, then ramp to the expected peak.
3. Use stress/breakpoint to find saturation, spike to test sudden demand, and soak to reveal
   leaks or pool exhaustion only when those risks matter.
4. Report p50, p95, and p99 latency together with throughput and error rate. Correlate CPU,
   memory, queue depth, cache hit rate, connection pools, database/downstream time, retries,
   load-balancer distribution, health checks, and autoscaling events.
5. Check generator CPU/network headroom so the harness does not manufacture latency.
6. Stop on safety thresholds. Clean up test data and cost-bearing infrastructure.

Gate a service-level objective, not "handled N users." A faster response that returns errors,
drops work, overloads a dependency, or serves stale unauthorized data fails the contract.

## Primary sources

- [Lighthouse CI configuration and assertions](https://github.com/GoogleChrome/lighthouse-ci/blob/main/docs/configuration.md)
- [Lighthouse](https://developer.chrome.com/docs/lighthouse)
- [Web Vitals field guidance](https://web.dev/articles/vitals)
- [Grafana k6 metrics](https://grafana.com/docs/k6/latest/using-k6/metrics/)
- [Grafana k6 load-test types](https://grafana.com/docs/k6/latest/testing-guides/test-types/)
- [Playwright trace viewer](https://playwright.dev/docs/trace-viewer)
