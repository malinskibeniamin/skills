# SPA Soak Testing

Use a soak test when a SPA, Electron renderer, or long-lived web view should return to
the same resource state after a repeatable user journey. This is a resource-lifetime
contract, not a general performance budget.

## Define the contract

1. Pick a **round trip**: open then close, mount then unmount, filter then clear, or
   navigate away then back without a document reload.
2. Name what should plateau: DOM nodes, event listeners, reachable heap, timers,
   subscriptions, workers, or application-owned caches.
3. Exclude journeys meant to retain history, such as an append-only feed, unless the
   contract includes pruning it.
4. For a reported leak, capture RED with the exact journey before fixing it. For a new
   preventive test, prove the detector with a small synthetic positive control that
   intentionally retains the suspected resource; a passing clean flow alone does not
   prove the sensor works.

## Measure sustained growth

Run warmup and measurement in one context. Warm up through lazy imports, initial data,
and bounded caches; choose the count from observed stabilization rather than copying a
magic number. Force collection and sample at three or more checkpoints after warmup,
for example loops 5, 25, 50, 100, and 200.

```ts
import type { CDPSession, Page } from "@playwright/test";

type PageMetrics = {
  loop: number;
  heapBytes: number;
  nodes: number;
  listeners: number;
};

async function readMetrics(
  page: Page,
  client: CDPSession,
  loop: number,
): Promise<PageMetrics> {
  // Playwright documents that collection is requested, not guaranteed. Repeated
  // checkpoints and runs carry the confidence; a second request only reduces jitter.
  await page.requestGC();
  await page.requestGC();
  const { metrics } = await client.send("Performance.getMetrics");
  const values = new Map(metrics.map(({ name, value }) => [name, value]));
  const heapBytes = values.get("JSHeapUsedSize");
  const nodes = values.get("Nodes");
  const listeners = values.get("JSEventListeners");
  if (heapBytes === undefined || nodes === undefined || listeners === undefined) {
    throw new Error("Chromium did not return required page metrics");
  }
  return { loop, heapBytes, nodes, listeners };
}

async function soak(
  page: Page,
  runRoundTrip: () => Promise<void>,
  checkpoints = [5, 25, 50, 100, 200],
): Promise<PageMetrics[]> {
  const client = await page.context().newCDPSession(page);
  await client.send("Performance.enable");
  const samples: PageMetrics[] = [];
  const orderedCheckpoints = [...new Set(checkpoints)].sort((a, b) => a - b);
  if (orderedCheckpoints.length < 3) throw new Error("Provide at least three checkpoints");
  const finalCheckpoint = orderedCheckpoints.at(-1);
  if (finalCheckpoint === undefined) throw new Error("Soak checkpoints missing");
  for (let loop = 1; loop <= finalCheckpoint; loop += 1) {
    await runRoundTrip();
    if (orderedCheckpoints.includes(loop)) samples.push(await readMetrics(page, client, loop));
  }
  return samples;
}

function medianSlope(samples: PageMetrics[], metric: keyof Omit<PageMetrics, "loop">) {
  const slopes = samples.flatMap((left, leftIndex) =>
    samples.slice(leftIndex + 1).map(
      (right) => (right[metric] - left[metric]) / (right.loop - left.loop),
    ),
  );
  const median = slopes.sort((a, b) => a - b)[Math.floor(slopes.length / 2)];
  if (median === undefined) throw new Error("Provide at least two samples");
  return median;
}
```

Use a robust slope plus a fixed end-to-baseline allowance. Derive both from repeated
clean runs on pinned browser and runner versions, then commit fixed budgets in their
native units; percentages hide small leaks on large pages. Save every sample as a JSON
failure artifact. Start noisy or expensive cases in a nightly job, and promote stable,
fast journeys to pull requests.

```ts
const samples = await soak(page, () => openAndCloseDrawer(page));
const first = samples[0];
const last = samples.at(-1);
if (first === undefined || last === undefined) throw new Error("Soak samples missing");
const nodeAllowance = projectMemoryBudgets.dashboardDrawerNodes;

expect(medianSlope(samples, "listeners"), JSON.stringify(samples)).toBeLessThanOrEqual(0);
expect(last.nodes - first.nodes, JSON.stringify(samples)).toBeLessThanOrEqual(nodeAllowance);
```

`projectMemoryBudgets` is an application-owned fixture. Calibrate each fixed allowance
from repeated clean runs; do not copy another flow's number.

## Cover blind spots deliberately

- `Nodes` catches retained DOM after garbage collection. `JSEventListeners` counts
  event listeners; it does not count timers, subscriptions, workers, or arbitrary
  retained objects.
- A timer-only or heap-only leak can leave both counters flat. Add a calibrated heap
  slope or a targeted `WeakRef` plus `page.requestGC()` when that is the risk. Heap is
  noisier, so repeat independent contexts and require a clear positive control.
- CDP counters are Chromium-only. `page.requestGC()` also supports other current
  Playwright engines, so targeted `WeakRef` lifetime tests can be cross-browser.
- The counters do not prove absence of leaks in workers, GPU/native allocations, WASM,
  or browser/driver processes. Use the owning profiler for those resources.

## Compress time without racing work

Install `page.clock` before navigation. After startup, pause it and advance it inside
each loop. Fake time does not accelerate network I/O: register the response promise
before advancing time, fulfill a production-shaped response with `page.route()` or HAR,
and await the response and rendered state before the next tick. Apply the same ordering
to `page.routeWebSocket()` messages. Otherwise requests overlap across checkpoints and
the test measures unfinished work instead of retention.

Disable trace, video, and screenshot recording during the measurement pass; diagnostic
recorders can retain large test artifacts. Keep one fresh browser context per independent
run, but never recreate it inside the round-trip loop.

## Localize after detection

Counters say that a leak exists, not what retains it. After a reproducible failure, take
baseline, target, and final heap snapshots and compare them in Chrome DevTools. Filter
for detached nodes and inspect retaining paths. Use MemLab when automated snapshot
diffing and clustered retainer traces justify the additional dependency.
