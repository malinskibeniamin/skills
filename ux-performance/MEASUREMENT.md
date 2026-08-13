# UX performance measurement

## Contents

- [Choose representative journeys](#choose-representative-journeys)
- [Use a metric stack](#use-a-metric-stack)
- [Read the waterfall](#read-the-waterfall)
- [Select tools by question](#select-tools-by-question)
- [Compare without fooling yourself](#compare-without-fooling-yourself)
- [Diagnose memory over time](#diagnose-memory-over-time)
- [Evidence record](#evidence-record)

## Choose representative journeys

Measure the user path, not an isolated function unless the function is already proven to
dominate it. Cover only relevant states:

- cold document navigation on a constrained mobile-class device and network;
- warm repeat visit, browser cache, application cache, and back/forward return separately;
- SPA soft navigation from intent through useful route content;
- the most important click, keyboard, input, drag, scroll, and filter interactions;
- ordinary, high-percentile, empty, error, and worst credible data volumes;
- a long-lived round trip for suspected degradation or leaks.

Record authentication, geography, feature flags, viewport, browser/runtime versions,
CPU/network settings, service-worker state, dataset seed, and whether caches are primed.
Do not average cold and warm paths into one number.

## Use a metric stack

Start with the milestone the user cares about, then use supporting metrics to explain it.

| Question | Direct metric | Diagnostic metrics |
|---|---|---|
| Is useful content visible? | LCP or an Element/User Timing mark | TTFB, FCP, resource discovery/download, render delay |
| Is an interaction responsive? | INP in real-user monitoring; custom intent-to-paint duration in lab | input delay, handler duration, long animation frames, React commit, layout/paint |
| Is the UI stable? | CLS | shift sources, missing dimensions, font swaps, injected content |
| Is an SPA transition fast? | intent-to-useful-content custom measure | loader/fetch waterfall, cache lookup, parse, render, paint |
| Is a table fluid? | filter/sort/search-to-paint, scroll frame time, task completion | mounted rows/cells, render count, commit time, DOM/layout, memory |
| Does it stay fast? | journey duration and memory slope over repeated round trips | heap, retained DOM, listeners, timers, subscriptions, workers, cache size |

The stable Core Web Vitals are **LCP, INP, and CLS**. Judge field distributions at the
75th percentile (p75), segmented at least by mobile and desktop. Current “good” reference
thresholds are LCP <= 2.5 s, INP <= 200 ms, and CLS <= 0.1; a product may need tighter
budgets. FCP and TTFB explain loading; TBT is a lab proxy for main-thread blocking and
cannot replace field INP. Core Web Vitals do not reset for ordinary SPA route changes, so
instrument the route milestone explicitly.

## Read the waterfall

Draw one timeline from user intent to the next useful paint. Rank by *critical-path cost*:
long work off the critical path may have zero effect on the milestone.

### Document load

1. redirect and service-worker startup;
2. DNS, connection, TLS, request queueing, server work, and TTFB;
3. HTML streaming/parsing and critical-resource discovery;
4. CSS, fonts, LCP media, JavaScript, data, and third-party fetches;
5. script parse/compile/evaluate, application bootstrap, and data dependencies;
6. React render/commit or hydration, style, layout, raster, and paint.

For LCP, split TTFB, resource-load delay, resource-load duration, and element-render delay.
For every request, inspect its initiator, priority, connection reuse, cache outcome,
transfer/decoded bytes, wait/TTFB, and whether another request unnecessarily gates it.
Use `Server-Timing` or correlated backend traces to split server, database, cache, and
downstream time instead of guessing from TTFB.

### Interaction or soft navigation

1. input queue delay;
2. event handler and synchronous state work;
3. loader, cache, and network dependency chain;
4. parse/normalize/filter/sort/format work;
5. framework scheduling and component render/commit;
6. style recalculation, layout, paint, and presentation.

Capture the slow interaction, not merely page startup. Mark the intent and completion with
User Timing. Inspect long tasks or long animation frames that overlap the interval. A fast
handler followed by a large render or layout is still a slow interaction.

## Select tools by question

Use installed tools first; verify current CLI/API syntax from first-party docs.

| Question | Best first evidence |
|---|---|
| What is slow for real users? | own RUM with `web-vitals` plus custom journey timings; CrUX/PageSpeed Insights for public origin context |
| Which network dependency blocks? | Chrome Network/Performance waterfall, HAR or WebPageTest, Resource/Navigation Timing |
| What blocks the main thread? | Chrome Performance panel, Long Animation Frames/Long Tasks, bottom-up and call-tree views |
| Which React update is costly? | React Performance tracks, React DevTools Profiler, targeted `<Profiler>`, then React Scan for unnecessary renders |
| Is shipped code excessive? | production bundle analyzer/source map explorer, Coverage, chunk graph, parsed/evaluated JS time |
| Is static React code suspicious? | React Doctor performance category; treat findings as hypotheses, not runtime proof |
| Is memory retained? | repeated journey counters, DevTools heap snapshots/allocation timeline and retaining paths |
| Is the service slow under demand? | distributed trace/query plan followed by a safe protocol load test |

Profile instrumentation adds overhead. Use it to attribute cost, then verify the outcome in
the ordinary production build. Lighthouse is a broad lab diagnostic: inspect numeric audits
and traces. Its aggregate score is neither a user journey nor proof of a change, and
Lighthouse cannot measure field INP without real interaction.

## Compare without fooling yourself

1. Freeze the thesis, primary metric, minimum worthwhile delta, scenario, and guardrails.
2. Prefer an untouched pre-edit baseline. Otherwise rebuild the merge-base in an isolated
   checkout using its lockfile.
3. Pin browser, runner, power mode, production build, flags, viewport, CPU/network, fixture,
   auth, and service dependencies. Compare like cache states.
4. Validate the sensor with a positive control when possible: intentionally add delay or
   retention and confirm the metric moves.
5. For noisy runtime measurements, run three warm-ups where warm-up is part of the claim,
   then start with five paired base/candidate runs. Alternate order. Extend to 10-30 pairs
   when variance or stakes demand it.
6. Report raw samples, median, absolute and relative delta, and spread. Use p95/p99 only
   with enough samples. A maximum from five runs is not a stable p95.
7. Inspect trace shape as well as the total. A faster median that worsens tail latency,
   errors, layout stability, memory, or accessibility is not a clean win.

## Diagnose memory over time

Warm through lazy initialization and bounded caches, then repeat one SPA round trip in the
same browser context. Sample at three or more later checkpoints after forced/requested GC.
Look for a sustained slope and failure to plateau in heap, retained DOM nodes, listeners,
timers, subscriptions, workers, and application caches. Confirm the detector with a small
intentional leak. Localize a proven leak by comparing heap snapshots and retaining paths.
Use the repository's [SPA soak-testing guidance](../e2e-testing/SOAK-TESTING.md) when
Playwright is available.

## Evidence record

Keep raw JSON, HAR, trace, profiler export, screenshots, commands, and environment metadata
under `.context/ux-performance/<journey>/`. Summarize:

```md
Journey: <start -> useful outcome>
Primary: <metric and minimum worthwhile delta>
Base / candidate: <SHAs and dirty state>
Method: <build, command, fixture, cache, device/network, run count>
Waterfall: <ranked critical-path segments>
Result: <samples, median, spread, absolute and relative delta>
Guardrails: <correctness, accessibility, errors, memory, bundle>
Limits: <what this setup cannot represent>
```

## Primary sources

- [Web Vitals and field/lab measurement](https://web.dev/articles/vitals)
- [User-centric and custom metrics](https://web.dev/articles/user-centric-performance-metrics)
- [Chrome DevTools Performance reference](https://developer.chrome.com/docs/devtools/performance/reference)
- [React Performance tracks](https://react.dev/reference/dev-tools/react-performance-tracks)
- [React Profiler](https://react.dev/reference/react/Profiler)
- [Chrome memory diagnosis](https://developer.chrome.com/docs/devtools/memory-problems)
- [Resource Timing specification](https://www.w3.org/TR/resource-timing/)
- [Server Timing specification](https://www.w3.org/TR/server-timing/)
