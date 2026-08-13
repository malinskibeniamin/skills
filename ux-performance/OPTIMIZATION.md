# UX performance optimization

## Contents

- [Use the intervention ladder](#use-the-intervention-ladder)
- [Make large tables scale](#make-large-tables-scale)
- [Reduce React and main-thread work](#reduce-react-and-main-thread-work)
- [Shorten loading and route transitions](#shorten-loading-and-route-transitions)
- [Design data and caches deliberately](#design-data-and-caches-deliberately)
- [Offload background work](#offload-background-work)
- [Follow delay into the service](#follow-delay-into-the-service)
- [Treat architecture changes as experiments](#treat-architecture-changes-as-experiments)

## Use the intervention ladder

Apply the first rung that removes the proven bottleneck:

1. **Delete** work, requests, bytes, renders, DOM, effects, abstractions, and third parties.
2. **Bound** work with pagination, virtualization, caps, cancellation, and backpressure.
3. **Remove serial dependencies** by starting independent work together or discovering
   critical resources earlier.
4. **Move work earlier or later** with safe precomputation, intent prefetch, lazy loading,
   yielding, or background refresh.
5. **Reuse** valid work with HTTP, CDN, application, query, or computed-result caching.
6. **Offload** proven CPU work from the main thread.
7. **Accelerate** the remaining hot algorithm, query, component, or runtime.

Estimate the ceiling before editing: removing a 20 ms off-path task cannot produce a 100 ms
journey win. Count new dependency, operational, invalidation, memory, and accessibility cost.

## Make large tables scale

A million-record table is a data-system workload, not a million-node render benchmark.

- Keep filter, sort, search, aggregation, and cursor/keyset pagination server-side unless
  profiling proves a bounded client dataset is better. Return only visible columns and
  metadata required for the interaction; cancel superseded requests.
- Render the viewport plus measured overscan with row virtualization; virtualize columns
  when width also scales. Keep mounted row/cell and DOM counts bounded as total records
  grow. Stable row identity must preserve selection and editing across window changes.
- Estimate row sizes accurately and measure dynamic sizes only when required. Validate
  scroll anchoring, jump-to-row, keyboard navigation, focus, screen-reader semantics,
  selection, expanded rows, and variable-height content.
- Keep table state subscriptions narrow. Avoid rebuilding column definitions, row models,
  or every cell for unrelated state. Measure filter/sort/search-to-paint, React commits,
  scripting/layout, dropped frames, memory plateau, and network payload at 10, 10,000, and
  1,000,000 records.
- If using TanStack packages, run **TanStack Intent** first and load the installed,
  version-matched Table, Virtual, Query, or Router guidance. Then apply local
  `/tanstack-table` policy. Do not copy remembered API syntax.

## Reduce React and main-thread work

- Use React Performance tracks or the Profiler to identify the update, components, effects,
  and cascading work that consume the interaction. Use React Doctor and React Scan to find
  static and runtime candidates; verify both in a browser trace.
- Localize state and subscribe to the smallest changing slice. Split context only when a
  profile shows broad invalidation; wrapping a tree in context is not itself an
  optimization. Remove redundant derived state, effect chains, and duplicate data owners.
- Let **React Compiler** own normal memoization when enabled. Confirm components compile,
  follow current React guidance, and profile before adding manual `memo`, `useMemo`, or
  `useCallback`. Existing manual memoization needs careful behavioral and performance tests
  before removal.
- Use transitions or deferred values for non-urgent updates when they improve perceived
  responsiveness; they schedule work rather than making expensive work disappear. Yield
  long interruptible work and cancel stale async results.
- Reduce DOM depth and expensive style/layout invalidation. Batch reads before writes. Use
  compositor-friendly transform/opacity animation only when visual evidence supports it;
  avoid permanent layer promotion without memory evidence.
- Replace quadratic scans, repeated parsing/formatting, and per-row allocation in the hot
  path with indexed, incremental, or precomputed work. Validate the whole interaction.

## Shorten loading and route transitions

- Ship less JavaScript. Remove unused code, prefer direct imports, split by route or feature,
  and lazy-load heavy noncritical UI. Inspect the chunk graph: many sequential microchunks
  or a late giant dynamic import can be worse.
- Make critical CSS, fonts, and LCP media discoverable early. Use priority hints, preload,
  or preconnect only for measured critical resources. Size responsive images, reserve media
  dimensions, subset fonts, and defer below-fold or optional assets.
- Start independent route data concurrently. Avoid component-created fetch waterfalls.
  Match loader, prefetch-on-intent, stale-time, and pending UI to the route's freshness and
  abandonment behavior. Keep skeleton geometry stable.
- Separate first content, useful content, and fully hydrated/interactive milestones. A
  spinner with fast FCP is not useful content. Stream or progressively reveal independent
  regions rather than gate the whole route on the slowest request.
- Preserve browser HTTP caching and back/forward cache eligibility. For SPA soft navigation,
  measure custom intent-to-content timings because document Core Web Vitals do not reset.
- Control third-party scripts by business value: delay, sandbox, facade, self-host where
  licensing permits, or remove. Track their main-thread, network, privacy, and failure cost.

## Design data and caches deliberately

Cache at the deepest layer that can state freshness and invalidation correctly:

- prefer CDN/HTTP validators and shared response caching for reusable transport results;
- use the application's query cache for deduplication, stale/fresh policy, background
  refresh, cancellation, retries, and optimistic state;
- use memoized computation only for proven repeated CPU work with bounded keys;
- use a service worker only when offline/repeat-visit policy justifies another cache layer.

Track hit rate, miss penalty, entry count/bytes, eviction, staleness, duplicate requests,
and invalidation correctness. Partition user- or tenant-scoped data and clear it on logout.
Never trade consistency, authorization, or privacy for a latency number.

`localStorage` and `sessionStorage` are synchronous. Reserve them for small, non-secret,
schema-versioned values whose startup read is measured; handle quota, corruption, migration,
and multi-tab behavior. Prefer memory for ephemeral state and IndexedDB/Cache Storage for
larger async data. Caching an unbounded million-row response is not a scalability plan.

## Offload background work

Use a Web Worker for measured, separable CPU work such as parsing, compression, search,
aggregation, or transformation that blocks the main thread. Workers cannot update the DOM.
Benchmark end to end: startup, message queueing, serialization/structured-clone or transfer
cost, copied bytes, cancellation, worker memory, and time until the next paint. Prefer
transferable objects or bounded batches when the data shape permits. A worker that finishes
later but keeps input responsive can be a UX win; state that trade explicitly.

Use idle/background scheduling only for deferrable work with cancellation and a deadline.
Do not let analytics, prefetch, cache warming, or speculative computation contend with the
critical route or exhaust device/network resources.

## Follow delay into the service

When TTFB or an API span dominates, correlate browser, `Server-Timing`, and distributed
traces. Decompose redirects, DNS/TLS, CDN/edge, queue, application, database, cache,
downstream, serialization, payload, and download.

- Fix query/index/N+1 and payload shape before adding capacity blindly.
- Bound concurrency, queues, retries, fan-out, and response sizes. Parallelize only
  independent work and preserve backpressure.
- Measure cache hit/miss separately; warm-cache-only benchmarks hide cold-start failures.
- Move cacheable work closer through CDN/edge only with correct keys, invalidation, privacy,
  and observability.
- Under representative safe load, inspect p50, p95, and p99 latency with throughput, error
  rate, saturation, queue depth, CPU/memory, connection pools, database limits, and cache hit
  rate. Verify the load generator is not the bottleneck.
- Consider load balancers, autoscaling, health checks, failover, and regional placement only
  when capacity or resilience evidence points there. Infrastructure complexity is not a
  default frontend optimization.

## Treat architecture changes as experiments

- **Framework/library upgrade**: identify a specific bottleneck the release claims to fix,
  read its current migration/performance docs, benchmark a prototype, and count bundle,
  compatibility, build, and operational cost.
- **SSR, streaming, or prerendering**: default remains the existing SPA. Prototype server
  rendering only when initial useful content, discovery, SEO, or weak-device execution is a
  measured constraint. Guard TTFB, hydration work, server cost, caching, and soft-navigation
  performance.
- **New wrapper/context/abstraction**: require the profiler to show the invalidation or
  orchestration seam it fixes. Prefer one compositional source of truth over synchronized
  cache, loader, and component copies.

## Primary sources

- [React Compiler introduction](https://react.dev/learn/react-compiler/introduction)
- [TanStack Virtual API](https://tanstack.com/virtual/latest/docs/api/virtualizer)
- [Optimizing INP](https://web.dev/articles/optimize-inp)
- [Script evaluation and dynamic imports](https://web.dev/articles/script-evaluation-and-long-tasks)
- [Off-main-thread work](https://web.dev/articles/off-main-thread)
- [Service-worker and HTTP caching](https://web.dev/articles/service-worker-caching-and-http-caching)
- [Optimizing LCP](https://web.dev/articles/optimize-lcp)
- [Optimizing TTFB](https://web.dev/articles/optimize-ttfb)
- [React Doctor CLI](https://react.doctor/docs/reference/cli-reference)
- [React Scan](https://github.com/aidenybai/react-scan)
