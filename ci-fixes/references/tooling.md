# Testing evolution: points 19-21

Use the [measurement protocol](measurement.md). Investigate current capabilities
without turning novelty, version assertions, or broad matrices into new CI overhead.
Re-check primary sources at execution time; these links are discovery pointers,
not a permanent claim that an API exists in the target's installed version.

## 19. Maintain current testing frameworks

**Inspect:** inventory the direct runner, assertion/mocking libraries, coverage provider,
browser binaries/container image, component/browser adapters, plugins, runtime, compiler,
and package-manager versions. Compare the installed lockfile with official latest stable
releases and supported engine/peer ranges. Package version, browser revision, and runner
image are separate compatibility axes. Default documentation may already describe a newer
major than the installed package.

**Experiment:** target latest stable, reading intervening migration guides and release notes.
Upgrade a coherent compatibility set and adapt every affected use: config options, removed
APIs, timer/mock semantics, isolation/pools, test collection, reporters, screenshots, and
coverage behavior. Reinstall the matching browser binaries or container image instead of
restoring an incompatible old cache. Playwright documents its
[package-to-browser version coupling](https://playwright.dev/docs/browsers); Vitest has a
[major migration guide](https://vitest.dev/guide/migration/). Use exact reviewed versions
and the lockfile, not floating installs that change between runs.

**Accept only if:** the new toolchain executes the actual suite and selected negative
controls, reports failures correctly, and preserves the source denominator/coverage contracts.
Benchmark startup, collection, body, teardown, memory, and artifacts when performance is a
claimed reason to upgrade. A changed coverage provider or browser font can alter metrics
without changing product quality: inspect those changes rather than lowering thresholds or
blanket-accepting snapshots. New defaults do not excuse lost assertions or isolation.

Latest stable is the maintenance target, not a promise that incompatible upgrades are safe.
For a genuine blocker, record installed/latest versions, exact incompatibility, impacted
consumer, owner, and the next enabling change. Do not silently relabel an old version as
current. Use existing repository dependency-update tooling for ongoing freshness when that
configuration is in scope; introduce no unrequested service, scheduled agent, credentials,
or automatic merge policy. Keep a reversible dependency/config/lockfile unit.

## 20. Benchmark new paradigms

**Inspect:** scan the latest few stable releases, including a relevant recent major, for
capabilities that address this suite's measured bottleneck or missing contract. Consult
[Playwright release notes](https://playwright.dev/docs/release-notes), installed CLI/types,
and version-matched runner docs. Confirm browser/flag/stability prerequisites; a feature
listed in current docs may not exist locally. Experimental capabilities remain experiments.

Use a contract-equivalence screen before measuring:

| Candidate | Legitimate experiment | Protection that cannot be silently replaced |
| --- | --- | --- |
| Cookie/request-context helpers | Reduce repeated auth setup when login is not the tested contract; check session restoration/expiry at its owner | Login UI, browser cookie policy, redirect, SameSite/partition behavior |
| WebMCP or direct app tools | Exercise a real exposed tool contract, or speed unrelated setup | Click/focus/navigation/accessibility and user-visible UI wiring |
| Browser component mode | Replace a genuinely inadequate emulator boundary for browser interaction | Full route/app integration when the component harness omits it |
| New pools/isolation or dependency recording | Reduce setup/selection cost on representative cases | Cleanup/order independence and non-import/global input invalidation |
| New collection/profiling/reporting | Reduce measured discovery/diagnostic overhead | Dynamic test discovery, complete failure reporting, retained evidence |

**Experiment:** automate a bounded A/B run through the existing command/benchmark mechanism.
Record exact versions/flags, scenario/fixture IDs, selected contracts, run order, cache and
runner conditions, raw metrics, first-attempt failures, and negative-control outcomes. Run
sequentially on the same reserved resources, with repeated samples; do not pit baseline and
candidate against each other for CPU/RAM. Prefer a small representative suite over adding
an expensive permanent benchmark to every PR. If experiments recur, make the comparison
deterministic and replayable; scheduling it is a separate authorization decision.

**Accept only if:** a worthwhile latency, compute, reliability, or new-contract benefit is
observed and the candidate catches the same intended failure controls. A faster direct API
call is not an equivalent browser journey merely because both end with the same data. Name
remaining integration risks and keep the original owner proof where they differ. Reject or
defer unsupported APIs, unstable experiments, savings within noise, extra infrastructure
cost, or narrower failure detection. Save the result so novelty does not restart the same
failed experiment next audit. Adopt one reversible slice; add new tests only for newly
distinct contracts, not to celebrate a framework capability.

## 21. Risk-based nightly browsers

**Inspect:** start with supported users/platforms, observed engine-specific bugs, and the
actual browser APIs/layout the app uses. Default Chrome/Chromium remains the focused PR
lane. A different product name alone does not justify rerunning everything. Distinguish
Chromium, Gecko, WebKit, branded channels, OS behavior, and physical devices; read
[Playwright's browser/channel limits](https://playwright.dev/docs/browsers).

**Experiment:** map a named contract to plausible divergence and the smallest useful lane:

- Layout/typography, scrolling, keyboard/focus, native input, or media behavior -> select
  the affected browser/OS contracts; codec availability may require the branded channel.
- Storage partitioning, cookies, permissions, or engine APIs -> exercise the actual browser
  policy with the same annotated backend fixtures, not only direct request-context methods.
- Mobile browser/safe-area/touch behavior -> use emulation for the cases it can represent;
  retain a real platform/device lane only where hardware/OS/browser integration is material.
- A concrete past engine regression -> keep a targeted reproducible contract. Promote it to
  PR selection for related changes when nightly detection would be unsafe.

**Accept only if:** every added lane has a supported audience or explicit compatibility
requirement, a credible divergent failure, and proof it exercises that behavior rather than
rerunning a Node unit or an API-only mock. Measure incremental queue/install/runtime cost;
reuse contract scenarios instead of multiplying fixtures across engines. Keep network mocked
in browser lanes and fail unexpected traffic just as on PRs. Do not describe Linux WebKit
or a device preset as exhaustive Safari/real-device proof.

Choose full nightly matrices only when the full surface warrants them; otherwise tag a
small risk-based set. Nightly cadence, freshness, failure ownership, manual replay, and PR
promotion rules follow [point 1](jobs.md#1-nightly-routing). Reassess lanes when APIs,
supported platforms, or bug evidence change, and retire ones that no longer protect a
distinct risk. A flaky extra-browser lane must be diagnosed, not tolerated as nightly noise.
