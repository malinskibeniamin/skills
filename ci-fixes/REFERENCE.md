# The 21-check CI audit

Use these checks with the baseline and proof loop in [SKILL.md](SKILL.md). The numbers
identify independent decisions, not a mandate to apply every optimization. Mark a check
not applicable only with a reason; insufficient evidence means defer with a named experiment.

## Job execution

### 1. Move suitable work to nightly

Keep fast, change-relevant correctness and critical user journeys on PRs. Consider exhaustive
matrices, long soaks, expensive live integrations, and broad compatibility sweeps for nightly
only when their delayed detection risk is understood and PRs retain adequate protection.
Keep the minimum independent backend/protocol contracts needed for relevant changes.
Inspect required-check consumers before changing triggers: avoid permanently pending gates
or successful no-op substitutes. Include a manual rerun path and a visible failure owner.
Changing a workflow schedule requires implementation scope; creating external scheduled
automation requires explicit authorization. Check current provider scheduling semantics.

### 2. Make the job itself faster

Profile setup, transforms/imports, compilation, environment creation, tests, teardown, and
uploads separately. Remove duplicate installs/builds, unnecessary service startup, repeated
heavy fixtures, fixed sleeps, and unconditional successful-run video/trace uploads where
measured useful. Keep actionable failure evidence. Prefer native runner profiling over
guessing from test-file size. Optimize the longest dependency chain first.

### 3. Cache reusable work

Compare restore/save/compression cost against recomputation for dependencies, build outputs,
transforms, browser binaries, and task results. Key by all relevant inputs: OS/architecture,
toolchain/runtime, lockfiles, configuration, source, and task/environment inputs as applicable.
Validate restored outputs; broad fallback keys must not accept stale artifacts or test results.
Check cold misses, warm hits, and invalidation after a meaningful input change. Separate
reusable caches from per-run artifacts; avoid competing writers. Keep secrets out and prevent
untrusted PR data from becoming trusted executable artifacts. A cache hit is not proof that
changed tests ran. See [GitHub caching](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching).

### 4. Upgrade GitHub Actions

Inventory action and reusable-workflow references, including composite internals. Resolve
the latest stable upstream release now, verify its release commit, and pin a full SHA with
a readable version comment. Read breaking changes, action runtime and runner requirements,
input/output changes, and artifact/cache compatibility. Do not use a floating `latest` tag
or assume that incrementing a major version is safe. Record blocked upgrades and why.

### 5. Benchmark more workers

Measure several worker/shard counts against the same workload. Account for nested process
pools, browser processes, memory per worker, CPU quotas, service capacity, and startup cost;
avoid oversubscription. Select the fastest stable configuration within the authorized cost
budget, not the largest count. Isolation and unique accounts, ports, files, and databases
must hold at peak concurrency. More workers can be slower; retain the measured winner.

### 6. Balance shard load

Compare shard elapsed time and test duration distributions, not just test counts. Report
slowest/median shard time and identify long files, serial groups, setup, or queue outliers.
Use duration-aware assignment where supported; otherwise split oversized independent groups
or use the runner's finer-grained distribution. Playwright's `fullyParallel` changes
[sharding granularity](https://playwright.dev/docs/test-sharding); count balancing does not
guarantee equal elapsed time. Prove independence before enabling it. Merge reports/coverage
once, with unique artifact names; missing or failed shards must fail the aggregate gate.

### 7. Enable useful parallelism and concurrency

Inspect independent jobs, unnecessary `needs` edges, matrix `max-parallel`, runner worker
settings, serial test groups, runner availability, and organization limits. Separate these
from [GitHub concurrency groups](https://docs.github.com/en/actions/concepts/workflows-and-actions/concurrency),
which constrain overlapping runs rather than enable test parallelism. Cancel superseded
PR runs with safely scoped groups; preserve deployment/publication serialization and cleanup.
Verify jobs overlap in actual timestamps and do not contend for shared resources.

### 8. Run affected tests, Bazel-style

Reuse the existing build/test graph before proposing a Bazel migration. Select from the PR's
correct comparison base through changed targets and their transitive reverse dependents.
Include non-import inputs: fixtures, schemas, generated inputs, dynamic imports, runtime
assets, shared setup, environment/configuration, and toolchain/lockfile changes. Handle
renames, deletions, and merge-queue events. Package path filters alone are not a dependency
graph. Missing base/history, unknown inputs, or incomplete graph coverage must broaden to
the safe full suite, not silently select nothing.

Validate representative leaf, shared dependency, config, fixture, rename/deletion, and
unknown-input changes against the full suite; demonstrate a related regression is still
detected. Keep a full-suite reference lane to detect selector drift. A genuine empty
selection must be explainable. Content-addressed result caching also needs complete inputs
and hermetic execution. Read [Bazel dependency management](https://bazel.build/basics/dependencies)
when evaluating that trade-off; install no new build system without a justified scope.

### 9. Match the machine to the workload

Verify actual vCPU, RAM, architecture, storage, image, and container quotas; runner labels
are not permanent hardware specifications. Distinguish CPU saturation, memory pressure,
disk/network bottlenecks, and queue delays. Compare suitable authorized runner sizes and
worker counts using wall time and total cost. A larger runner cannot repair serialized
work or network waits. Confirm public/private-repository differences in the current
[runner reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).
Paid capacity or trust-sensitive self-hosted changes remain owner decisions.

### 10. Shorten prerequisites and the final tail

Map checkout, tool setup, install, codegen, build, service readiness, test execution, and
report aggregation as a DAG. Remove redundant edges/work; parallelize independent steps;
reuse compatible outputs across jobs only when transfer is cheaper and trust is preserved.
Install only needed browser engines/dependencies. Measure end-to-end: moving setup to a
shared job can add a new serial barrier. Rebalance real work to reduce the last-finishing
outlier; do not optimize job symmetry at the expense of faster overall completion.

### 11. Check remaining legitimate wins

Look for duplicate push/PR runs, needless full-history checkout, repeated coverage
instrumentation, heavyweight global setup/import barrels, excessive artifacts, stale-run
waste, and overly broad matrices. Keep full history where selection/versioning requires it.
Use immutable dependency installs and condition-based readiness. Fail fast where it saves
work without hiding needed diagnosis; bound hangs with timeouts. Try isolation/pool changes
only with order/leak verification, not as blanket flags. Consult the installed version's
[Vitest performance guidance](https://vitest.dev/guide/improving-performance) when applicable.

## Test signal

### 12. Diagnose flakes from evidence

Inspect first-attempt reports, traces, logs, seeds, order, worker/shard IDs, and rerun history.
Reproduce isolated, repeated, reordered, and concurrent execution. Distinguish product races
from fixture leaks, shared accounts, network/clock dependence, resource exhaustion, and
infrastructure failures. Repair the actual owner; await observable conditions, isolate state,
control time/randomness, and retain a reproducible regression. A few green reruns do not
establish that the cause is fixed.

### 13. Reduce the test portfolio aggressively, not blindly

Map each feature's contracts and credible failures to one primary owner at the cheapest
adequate level. Prefer pure units for domain logic and browser tests for browser behavior;
retain integration/contract coverage for distinct transport, storage, lifecycle, or security
risks. Six layers replaying the same happy path are not six independent protections.
Record each removal's unique signal or remaining stronger proof. Consolidate redundant
scenarios and delete obsolete test-only seams. Seek large savings where evidence supports
them, not a deletion quota. Compare unchanged line/branch coverage and targeted mutations;
equal line coverage alone cannot establish equal protection.

### 14. Flaky tests have no place in the retained suite

Make them deterministic or replace their unique contract with reliable proof before deleting
them. Do not normalize flakiness through retries, skips, quarantine, loose timeouts, or moving
failures to nightly. Target zero retries in the required suite; if a framework classifies a
retry-pass as flaky, make that classification visible and failing where supported. If the
cause remains unresolved, report incomplete work rather than manufacturing green.

### 15. Tests must be able to go red

Name the credible regression, inject it at the production/public boundary in a disposable
workspace, and observe the intended assertion fail. Restore and verify green. An unavailable
dependency or unrelated exception is not a valid negative control. Remove or repair
assertion-free probes, unawaited assertions, unreachable expectations, and mocks that supply
their own success. Never leave a deliberate mutation in the delivered patch.

### 16. Remove tautologies

Delete self-comparisons, implementation-derived expected values, fixture echoes, version
checks that merely restate the installed version, and duplicated implementation snapshots.
Keep independent compatibility or protocol requirements that exercise real behavior; do not
confuse those with a version-string assertion. Source-text greps are not runtime evidence.

### 17. Minimize happy-dom and jsdom

Move pure computations/validation out of DOM emulation into cheap unit tests. Put focus,
layout, navigation, rendering, and real browser API contracts in a small real-browser suite.
Keep an emulated-DOM test only with a distinct behavioral contract and a measured advantage
over those owners. Do not mechanically convert every emulated test into a slower browser
test, or replace interaction coverage with direct calls to event handlers.

### 18. Mock backend network in PR browser tests

Run the real frontend against intercepted, explicitly annotated request/response fixtures;
PR browser runs must not depend on a live backend or third-party services. Install routes
before navigation and fail unexpected backend/external requests instead of falling through.
Allow the local app's legitimate document/assets. Cover required success, empty, validation,
error, and race cases at their unique owners. Validate fixtures against independent protocol
contracts and redact captured secrets; mocks must not fabricate the behavior under test.
Account for service workers and WebSockets where used. See
[network interception](https://playwright.dev/docs/network) and [mock APIs](https://playwright.dev/docs/mock).
Mocked browser tests do not prove real backend compatibility: retain the appropriate cheap
contract checks and explicitly scoped live integration lane outside PR browser execution.

## Keep the tools current

### 19. Keep testing frameworks on the latest stable release

Compare installed and current upstream stable versions during each audit, including runner,
browser engine/image, coverage provider, adapters, and plugins. Use official release notes
and migration guides; upgrade compatible pieces together and update the lockfile. Verify
API changes and rerun regressions/performance comparisons. Compatibility/security blockers
need a named reason and follow-up, not an indefinite stale pin. Do not adopt prereleases or
floating versions just to claim latest; repository test dependencies are not version tests.

### 20. Benchmark newly useful paradigms

Read the latest few stable release notes, such as [Playwright releases](https://playwright.dev/docs/release-notes),
for changes relevant to this suite. Cookie/request-context helpers, WebMCP tooling, browser
mode, improved pools, or new profiling tools are candidates only if actually supported by
the selected version and workload. Never present an example as a verified installed API.
Automate a bounded, reproducible A/B comparison with the existing runner: same representative
contracts, negative controls, cache conditions, hardware, and repeated samples. Measure runtime,
CPU/memory, flakes, coverage, and failure detection. A direct API/tool call may not replace
UI interaction proof. Adopt only with measured benefit and preserved signal; keep the old
path or an easy revert until validated. No permanent experiment service/schedule is implied.

### 21. Add nightly browsers only for credible divergence

Keep the default Chrome/Chromium PR lane focused. Add Firefox, WebKit, branded browsers, or
platform/device lanes only for supported users and plausible differences: layout, input/focus,
storage/cookies, media, permissions, or engine APIs. Select the affected contracts, not a full
matrix by habit. Retain change-relevant engine regressions on PRs when delayed detection is
unsafe. Record the risk each extra lane protects and its cost; emulation is not proof of
another engine or a physical device.
