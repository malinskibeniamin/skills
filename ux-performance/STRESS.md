# Browser performance stress and capacity

## Contents

- [Define a client capacity contract](#define-a-client-capacity-contract)
- [Build the capacity curve](#build-the-capacity-curve)
- [Exercise distinct load shapes](#exercise-distinct-load-shapes)
- [Observe saturation](#observe-saturation)
- [Preserve correctness under pressure](#preserve-correctness-under-pressure)
- [Separate browser and service load](#separate-browser-and-service-load)
- [Automate at the right cadence](#automate-at-the-right-cadence)
- [Report the breakpoint](#report-the-breakpoint)

Use this branch when the claim includes scale, bursts, repeated interactions, background
contention, weak devices, long-lived tabs, or degraded dependencies. The objective is not a
hero maximum. Find the **saturation knee** where more workload causes disproportionate user
delay, instability, resource growth, or errors, then keep the supported operating region
comfortably below it.

## Define a client capacity contract

Fix one user journey and vary one workload dimension at a time:

- records available and records mounted;
- update, event, request, or message arrival rate;
- input burst length and time between interactions;
- concurrent widgets, streams, workers, tabs, or in-flight requests;
- route round trips, open/close cycles, or tab lifetime;
- payload bytes, image dimensions, chunk count, and cache cardinality;
- device CPU/memory class, bandwidth, latency, and dependency delay.

Name the expected operating point, peak, worst credible point, and abort threshold. Keep
the same fixture, seed, production build, browser, viewport, machine/power state, cache
state, and authentication. Record correctness and accessibility invariants beside latency:
the test fails if it becomes fast by dropping updates, hiding content, losing focus, or
serving stale data.

## Build the capacity curve

Start below the expected workload, ramp through it, and continue only to an approved safety
limit. At each level, warm as specified, repeat the same journey, and collect raw samples.
Plot workload on the x-axis against:

- intent-to-useful-paint median and tail;
- input delay, handler time, React commit, layout, and paint;
- long animation frame (LoAF) and long-task count/duration, frame consistency, and missed
  visual deadlines;
- heap and DOM slope, listeners, timers, subscriptions, workers, cache entries/bytes, and
  in-flight work;
- request queueing, payload, throughput, cancellations, retries, and error rate;
- stale/dropped/out-of-order results and product task-completion rate.

The knee is the first sustained nonlinear rise or guardrail breach, not the single worst
sample. Confirm it by adding points around the suspected breakpoint and replaying the curve
in alternating order. Save traces at the healthy point, knee, and first failed point so the
shape can be attributed to network, JavaScript, React, layout/paint, memory, or service time.

## Exercise distinct load shapes

Do not collapse different risks into one "large dataset" run:

| Shape | What it reveals | Browser example |
|---|---|---|
| ramp | capacity knee and nonlinear scaling | increase mounted rows or updates/second in steps |
| spike | queue control and recovery | burst inputs, live updates, navigations, or invalidations |
| soak | leaks and degradation over time | repeat route/filter/open-close journeys in one tab |
| contention | competition for shared resources | background load, a competing tab, worker, animation, or download |
| degraded dependency | retry and partial-progress behavior | slow, reordered, failed, or offline API/chunk/media requests |
| cold pressure | startup sensitivity | empty caches, service-worker startup, cold connection, lazy chunks |

For a spike, measure both peak delay and recovery time after arrivals stop. For a soak,
remove lazy initialization and bounded-cache warm-up from the leak slope, then require a
plateau. Under contention, distinguish work owned by the page from system noise and use the
same controlled competitor for base and candidate.

## Observe saturation

Use a real browser and production artifact. Mark intent and useful completion with User
Timing. Capture a Chrome trace and network waterfall at selected curve points; use React
tracks or Profiler only when React work overlaps the interval. A `PerformanceObserver` can
record supported LoAF/long-task/resource entries for trends, while the trace remains the
attribution artifact.

Watch for queue growth and recovery, not only duration. Common client saturation signals:

- input arrives faster than handlers, renders, or paints complete;
- stale requests continue after newer intent and consume connection or CPU capacity;
- render/layout cost grows with total data although the viewport is fixed;
- workers trade main-thread responsiveness for unbounded queues, copies, or memory;
- a cache improves warm latency while miss storms, eviction, or invalidation dominate peaks;
- retries synchronize, multiply load, or block newer useful work;
- memory, DOM, listeners, or background work do not return to a stable plateau.

Validate the detector with a positive control: intentional delay, retained object, excess
mounted rows, or uncancelled request must move the expected signal.

## Preserve correctness under pressure

Assert the latest intent wins. Detect stale response overwrite, lost input, duplicate
submission, reordered live events, partial pagination gaps, selection drift, focus loss,
scroll jumps, inaccessible pending states, and error UI that never recovers. Verify abort
and unmount cancellation, bounded retry/backoff, idempotency where required, and cleanup of
workers, streams, observers, subscriptions, timers, and object URLs.

Make completion semantic: correct rows painted and usable, not "request resolved" or
"spinner disappeared." Track errors and dropped work explicitly. A latency percentile is
invalid if failed or abandoned journeys are silently excluded.

## Separate browser and service load

Use browser automation for a small number of high-fidelity user journeys, rendering traces,
memory, and correctness. Use a protocol load generator for service concurrency and
throughput. Thousands of full browsers usually measure runner saturation; one protocol
test cannot expose main-thread, React, DOM, or paint limits.

Correlate the two only when the service is on the browser waterfall. Hold service load at a
named level while sampling browser journeys, then hold the browser fixture steady while
locating backend saturation. Track generator headroom in both harnesses. Never infer that a
load balancer, autoscaler, cache, or worker helps the user until the end-to-end milestone
moves.

Define stop conditions before tests that touch shared infrastructure: error-rate ceiling,
queue or latency threshold, dependency saturation, cost cap, duration, and an immediate
abort path. Prefer isolated/non-production targets unless production load is explicitly
approved and guarded.

## Automate at the right cadence

- **Pull request:** deterministic bounds such as mounted DOM, payload/asset bytes, request
  count, and one calibrated journey near the expected operating point.
- **Nightly/pre-release:** ramp, spike, contention, degraded dependency, worst credible
  dataset, and short soak with traces at failures.
- **Periodic/manual:** long soak, breakpoint search, device matrix, and service stress.
- **Production:** field journey tails, Core Web Vitals, errors/abandonment, resource trends,
  release segments, and capacity/error-budget alerts.

Begin timing checks as advisory. Promote a stress budget only after clean-main calibration,
a positive control, acceptable false-positive rate, named ownership, and an actionable
artifact on failure.

## Report the breakpoint

```md
Supported region: <workload and environment>
Capacity knee: <first sustained nonlinear rise or guardrail breach>
Primary curve: <workload -> journey metric with samples/spread>
Failure mode: <network / JS / React / layout / memory / service / correctness>
Recovery: <time and state after spike or degradation ends>
Safety stops: <thresholds and whether any fired>
Artifacts: <curve data, healthy/knee/failure traces, screenshots, logs>
Recommendation: <bound, remove, reschedule, reuse, offload, or accelerate>
```

## Primary sources

- [Chrome Long Animation Frames API](https://developer.chrome.com/docs/web-platform/long-animation-frames)
- [Chrome DevTools Performance reference](https://developer.chrome.com/docs/devtools/performance/reference)
- [Playwright emulation](https://playwright.dev/docs/emulation)
- [Playwright Chrome DevTools Protocol sessions](https://playwright.dev/docs/api/class-cdpsession)
- [Grafana k6 load-test types](https://grafana.com/docs/k6/latest/testing-guides/test-types/)
