# SPA Soak Testing Evaluation

**Date:** 2026-07-31
**Status:** Adopt with corrections
**Source article:** [Your SPA Is Leaking Memory. Soak Test It](https://denodell.com/blog/your-spa-is-leaking-memory-soak-test-it)

## Verdict

The article's core technique works as a low-cost detector for accumulating DOM nodes
and event listeners: repeat a same-document round trip in one browser context, request
garbage collection, then compare Chromium page counters. It is not a general memory
leak test. Its published assertions miss timer-only and heap-only retention even though
timers motivate a large part of the article.

Adopt the technique inside the existing TDD and E2E guidance, not as a new skill or a
hook. Improve it with a positive control, multiple post-warmup checkpoints, a robust
growth slope, calibrated fixed allowances, explicit metric coverage, and heap-snapshot
escalation. Runtime retention cannot be proved by a static edit hook, and thresholds are
application-specific.

## What the article gets right

- **Long-lived context:** normal isolated E2E tests erase the accumulation signal. A
  same-document round trip in one context models the resource lifetime that matters.
- **Round-trip flow:** open/close or mount/unmount distinguishes retained resources from
  intentionally growing history.
- **Warmup:** lazy code, initial data, and bounded caches must settle before measurement.
  The count must be observed rather than universally fixed at five loops.
- **Forced collection:** comparing measurements after requested collection reduces
  ordinary allocation noise. Playwright warns that `page.requestGC()` does not guarantee
  collection of every unreachable object, so repetitions remain necessary.
  [Playwright `page.requestGC()`](https://playwright.dev/docs/api/class-page#page-request-gc)
- **Useful counters:** Chrome's performance monitor tracks total DOM nodes and JavaScript
  event listeners, and Chrome's memory guide recommends beginning and ending leak
  observations with forced collection. [Chrome Performance monitor](https://developer.chrome.com/docs/devtools/performance-monitor),
  [Chrome memory guide](https://developer.chrome.com/docs/devtools/memory-problems)
- **Compressed time:** Playwright Clock replaces timers, animation callbacks,
  `performance`, and `Date`; installing before navigation and advancing deterministically
  is the correct approach. Fake time does not settle real network I/O, so response
  promises and realistic network fixtures must be synchronized separately.
  [Playwright Clock](https://playwright.dev/docs/clock),
  [Playwright network mocking](https://playwright.dev/docs/mock)
- **Snapshot escalation:** counters detect growth but do not identify retainers. Chrome
  heap snapshots compare reachable objects and expose detached-node retaining paths.
  MemLab formalizes baseline, target, and final snapshots and can ingest snapshots from
  Playwright. [Chrome heap snapshots](https://developer.chrome.com/docs/devtools/memory-problems/heap-snapshots),
  [MemLab E2E integration](https://facebook.github.io/memlab/docs/guides/integrate-with-e2e-frameworks/),
  [how MemLab works](https://facebook.github.io/memlab/docs/how-memlab-works/)

The historical Gmail evidence is also sound. Google's JSWhiz paper reports hours-long
pre-release memory checks and a repeated Gmail scenario, then describes how static
analysis plus fixes helped reduce Gmail memory bloat. It does not establish that every
SPA needs the article's exact two-counter threshold.
[JSWhiz paper](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/40738.pdf)

## Where the article overreaches

### The 86% figure is potential, not confirmed leakage

The cited 500-repository study used a curated, non-random sample and AST patterns. Its
own caveats say that the scan has false positives and false negatives, impact precision
is moderate, recall is unknown, and the runtime benchmarks used synthetic Node.js
components rather than the scanned browser applications. Short timers, finite
observables, and app-lifetime singletons are explicit false-positive examples. The study
therefore supports prioritizing runtime checks, not the stronger claim that 86% of those
applications actually leak in production.
[500-repository study and caveats](https://stackinsight.dev/blog/memory-leak-empirical-study/#caveats-and-limitations)

### Two counters cover only two classes

`JSEventListeners` is not a timer or subscription count. A pending timer, store
subscription, global array, worker, WASM allocation, or native/GPU allocation can retain
memory while both article assertions stay green. Advancing fake time exercises timer
callbacks but does not make a timer-only leak appear in either counter. A calibrated
heap trend or targeted `WeakRef` contract is required for that risk.

### Two readings are weaker than a trend

A single baseline/end delta cannot distinguish sustained growth from a late one-time
allocation or garbage-collection jitter. Three or more checkpoints support a robust
median pairwise slope and preserve evidence on failure. The fixed `+100` node allowance
is directionally better than a percentage, but it is a value from one application, not
a reusable default.

### Chromium page metrics are not total process memory

Raw `Performance.getMetrics` requires a CDP session, and Playwright supports CDP sessions
only on Chromium-based browsers. The page target's heap and counters do not include every
worker, browser, driver, GPU, or OS allocation. Targeted `page.requestGC()` lifetime
checks can use current Playwright engines, but the article's counters cannot.
[Playwright `newCDPSession()`](https://playwright.dev/docs/api/class-browsercontext#browser-context-new-cdp-session)

### Nightly is a rollout choice, not a law

Noisy or expensive flows belong in nightly CI first. A stable, bounded smoke journey can
run on pull requests. Promote based on measured runtime and false-positive rate rather
than test category alone.

## Benchmark

### Setup

- macOS 26.5.2 on ARM64
- Bun 1.3.14, Playwright 1.61.1, headless Chromium 149.0.7827.55
- Three independent browser contexts per scenario
- Real accessible button clicks: open drawer, close drawer
- Clean, listener-only, detached-DOM-only, heap-only, and interval-only fixtures
- Clean/listener/DOM/heap: 200 loops with samples at 5, 50, 100, and 200
- Interval: 100 loops with 30 seconds of fake time per loop, simulating 50 minutes
- Two `page.requestGC()` calls before every sample; article verdict compares loop 5 with
  the final loop using zero listener growth and less than 100 additional nodes

The disposable benchmark and raw JSON are in `.context/spa-soak-benchmark/` and remain
gitignored. The benchmark tests the detector, not production prevalence.

### Results

| Scenario | Expected retained resource | Mean final delta | Median slope | Article assertion | Mean runtime |
|---|---|---:|---:|---:|---:|
| Clean | None | +132 KiB heap, +15 nodes, +0 listeners | +687 B heap/loop | PASS 3/3 | 8.59 s / 200 |
| Listener | 1 listener and 1,000-number payload/loop | +908 KiB heap, -15 nodes, +195 listeners | +1 listener/loop | FAIL 3/3 | 6.95 s / 200 |
| Detached DOM | 45 nodes/loop | +150 KiB heap, +8,775 nodes, +0 listeners | +45 nodes/loop | FAIL 3/3 | 6.90 s / 200 |
| Heap | 1,000-number payload/loop | +899 KiB heap, +0 nodes, +0 listeners | +4,718 B heap/loop | **PASS 3/3 false negative** | 6.79 s / 200 |
| Interval | 1 interval and payload/loop | +520 KiB heap, +0 nodes, +0 listeners | +5,692 B heap/loop | **PASS 3/3 false negative** | 24.34 s / 100 |

The clean fixture alternated between 23 and 68 nodes at its checkpoints: exactly half of
12 readings retained one 45-node drawer even after two collection requests. The
article's `+100` allowance kept the test green, but its claim that two collections make
node counts reliable did not reproduce on this browser. Multiple checkpoints exposed
the jitter; a zero-delta assertion would have failed a healthy run.

The clean heap also grew by about 687 bytes per loop under the automation workload.
Heap growth therefore needs a calibrated control. The heap-only and timer-only controls
still separated clearly at roughly 4.7-5.7 KiB per loop, showing that heap slope can
cover the article's blind spots when the signal exceeds the measured floor.

## Harness decision

Implemented:

1. `tdd/SKILL.md` now recognizes long-lived resource-lifetime contracts and routes them
   to the E2E soak guide.
2. `e2e-testing/SOAK-TESTING.md` adds the corrected workflow, typed Playwright template,
   positive-control requirement, multi-checkpoint median slope, calibrated fixed
   budgets, clock/network ordering, blind-spot matrix, and heap-snapshot escalation.
3. `e2e-testing/SKILL.md` exposes the new reference only for long-lived SPA risks.
4. TDD and E2E evals lock the routing and critical safeguards.

Deliberately not implemented:

- **No new skill:** soak testing is a branch of E2E resource testing; a new model-facing
  skill would add permanent context without an independent workflow.
- **No hook:** runtime leakage and application budgets are not mechanically inferable
  from an edited source file. A listener/timer grep would repeat the cited study's false
  positives and conflict with the harness's evidence-first rule.
- **No shared production helper yet:** the flow, checkpoints, and budgets are
  application-owned. Extract a helper after a second real adopter demonstrates stable
  duplication.

## Adoption checklist

1. Choose one high-frequency round trip from a long user session.
2. Inventory the resource class and its expected plateau.
3. Prove the detector with a synthetic positive control.
4. Calibrate warmup, slope, fixed allowance, runtime, and browser version over repeated
   clean contexts.
5. Mock time and network only when ordering and payload fidelity are explicit.
6. Save all samples on failure; use three heap snapshots or MemLab to localize.
7. Start nightly if noisy; promote to pull requests only after stable evidence.
