# Job execution: points 1-11

Use the [measurement protocol](measurement.md); record a decision for every point in
the [audit index](../REFERENCE.md). Apply the target repository's package manager,
installed runner APIs, trust boundaries, and required-check policy.

## 1. Nightly routing

**Inspect:** map each check to the defect it detects, changes that can cause it, existing
PR proof, last useful catches, runtime, and consequence of discovering failure after
merge. Distinguish long exhaustive exploration from a slow but uniquely critical check.
Security, authorization, migration, packaging, and compatibility checks are not optional
just because they run slowly; preserve their relevant PR contracts.

**Experiment:** partition by detection budget: always-on critical checks, graph-selected
PR checks, and broader nightly/manual/release checks. Keep changed-risk coverage on PRs
even when the broader sweep moves. Estimate compute using run frequency as well as job
duration; one nightly full run can replace many redundant PR matrices, but it adds a
larger attribution window and delayed feedback. Record who owns a nightly failure.

**Accept only if:** PRs retain adequate proof and required-check consumers still resolve
correctly. A changed trigger must not strand a required status or make omitted checks
look executed. Prove actual selection and manual recovery. Nightly work needs a visible
freshness/failure signal; a missing run is not a passing run. GitHub schedules can be
delayed or dropped and run from the default branch, so they are not an exact-time SLA.
Check schedule timezone and inactivity behavior in the current
[event documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule).
Never relocate a broken/flaky test merely to remove its PR failure.

## 2. Job runtime

**Inspect:** break execution into checkout/install, transform/import, global setup,
environment creation, test bodies, teardown, coverage, and artifacts. Rank both the slowest
tests and the phases paid once per file/worker/shard. A thousand tiny tests can be dominated
by a large setup import; deleting assertions then barely changes runtime.

**Experiment:** profile one representative run, then remove the dominant repeated cost.
Examples: initialize a heavy fixture at its real ownership boundary; avoid booting a server
for pure units; replace polling sleeps with a readiness condition; stop importing an entire
application through a barrel in each unit. Measure process startup and collection separately
before consolidating tiny files or changing pools. Reuse expensive immutable data, not mutable
state shared between tests. Consult version-matched
[Vitest profiling/performance guidance](https://vitest.dev/guide/improving-performance).

**Accept only if:** the same selected contracts execute, setup/cleanup semantics remain
correct, and teardown has no leaked handles or work left running after success. Split a
new environment only when saved per-file work outweighs another project/worker startup.
Keep traces/logs sufficient to diagnose failures; distinguish reducing successful-run
capture from removing failure observability. Report execution savings separately from
commit-to-green savings.

## 3. Cache economics and correctness

**Inspect:** distinguish package-download stores, installed dependencies/native binaries,
compiler/transform caches, generated/build outputs, and test-result caches. Their valid
keys and trust requirements differ. Package stores still need an immutable install;
restoring a dependency folder is not automatically ABI/architecture safe. Live-network,
time-sensitive, or secret-dependent test results are not automatically hermetic.

**Experiment:** compare recomputation with download/decompression/validation and save/upload.
For complete paths, estimate `expected cost = hit rate * hit cost + miss rate * miss cost`;
include cache-save work and setup that remains on both paths. Measure eviction/key churn
and stampedes across shards. Choose one writer or compatible immutable writes; do not
duplicate an identical huge upload from every shard.

**Accept only if:** keys cover relevant OS/architecture, runtime/tool versions, lockfiles,
source, configuration, task arguments, and output-affecting environment inputs. Test a
miss, an exact hit, and a changed input; verify stale output cannot pass. Broad restore
fallbacks may seed reusable downloads, not certify stale build/test results. Preserve
cache/artifact provenance across forks and privileged workflows; store no secrets.
Use safe input identifiers/hashing rather than putting credentials or exposed low-entropy
secret digests into keys/logs. If a relevant dependency cannot be modeled safely, do not
cache that result.
Read [cache matching and trust restrictions](https://docs.github.com/en/actions/reference/workflows-and-actions/dependency-caching)
and [environment hashing](https://turborepo.dev/docs/crafting-your-repository/using-environment-variables).
For Playwright, browser-cache restore may rival download time and Linux OS dependencies
still need installation: [benchmark rather than assume a win](https://playwright.dev/docs/ci#caching-browsers).

## 4. GitHub Actions upgrades

**Inspect:** inventory every `uses` reference in jobs, local composite actions, nested
reusable workflows, and setup wrappers. Record pinned release/SHA, upstream stable release,
runtime requirement, runner/GHES compatibility, inputs/outputs, permissions, and consumers.
Do not confuse `runs-on: ...-latest` with upgrading an action or its embedded runtime.

**Experiment:** resolve the official release tag to a full commit and verify the commit
belongs to that upstream release. Read all skipped major migrations, not just the newest
changelog. Adapt changed artifact names/digests, cache behavior, checkout/auth defaults,
input/output types, and deprecations. Update tightly coupled upload/download or setup/runtime
pairs coherently. Reusable workflow changes require checking callers, not just the callee.

**Accept only if:** the latest stable compatible release is SHA-pinned with a readable
version comment, syntax and real invocation succeed, and required outputs/failure exits
remain intact. Preserve minimum permissions and untrusted-input boundaries; an upgrade
is not permission to grant broader token access. Keep the previous pin and necessary
config adaptation as a reversible unit. A blocked latest release needs the exact runner,
security, or compatibility reason and a concrete follow-up, not a guessed major bump.
Use [action pinning/security](https://docs.github.com/en/actions/reference/security/secure-use)
and [reusable-workflow semantics](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows).

## 5. Worker capacity

**Inspect:** count job slots, workers inside each job, test-level concurrency, browser
processes per worker, nested compiler/mutation pools, and external service capacity.
Record actual CPU quotas and memory headroom, not just logical processors. Each shard
usually has its own runner: `shards * workers` describes total demand, not one machine's
safe local worker count. Memory exhaustion can manifest as timeouts or browser crashes.

**Experiment:** sweep a small justified grid, such as 1/2/4 workers within the machine's
limits; test shard count separately before combining winners. Track wall time, setup
duplication, CPU utilization, peak memory, throttling, queueing, and first-attempt failures.
Use the same inputs and fresh isolated state. Size a starting memory ceiling from available
RAM using `(available RAM - app/services/OS reserve) / incremental worker memory`; treat
that as a bound to verify, not an exact process-cost prediction.

**Accept only if:** repeated runs at the chosen concurrency remain independent and faster
within cost limits. Verify worker-unique accounts, namespaces, ports, temporary files, and
cleanup after worker restart. Prefer fewer workers when gains are within noise; do not
raise timeouts or retries to conceal oversubscription. Playwright's
[worker/process model](https://playwright.dev/docs/test-parallel) is not interchangeable
with a unit runner's threads or concurrent assertions.

## 6. Shard balance

**Inspect:** collect per-test/file duration and each shard's setup, queue, body, and teardown
time. Compare slowest shard to median and useful work to allocated slot time. Equal test
counts can hide one serial 8-minute file alongside many millisecond cases. A shard starting
late because of queue limits is not necessarily misassigned test work.

**Experiment:** where supported, assign expensive independent groups first to the lightest
shard using historical durations; retain deterministic assignments and a safe default weight
for new tests. Otherwise split oversized files/serial groups by real independence or use
finer native granularity. Repeated setup can erase the gain from splitting. Playwright's
[`fullyParallel` changes the unit of sharding](https://playwright.dev/docs/test-sharding),
but test-count balance is not duration balance.

**Accept only if:** the slowest completion improves without introducing shared-state races.
Enumerate expected identities including the project, then verify shard union/completeness;
each selected identity should appear once unless repetition is explicit. Different browser
projects are different identities. Include new/renamed tests and exclude retries from useful-work counts.
Reports/artifacts need unique shard
identities, compatible versions, and one complete aggregate. Fail the aggregate when a
shard is missing, canceled, or failed; uploaded partial reports must not manufacture green.
Remeasure after major suite churn rather than trusting stale weights indefinitely.

## 7. Parallelism and concurrency

**Inspect:** distinguish independent jobs, matrix `max-parallel`, worker pools, file/test
serialization, organization quotas, and workflow overlap. Build a reason for every `needs`
edge: real artifact/data dependency, intentional resource lock, or accidental serialization.
A shared staging account or database is a real bottleneck until isolated, not a reason to
toggle all concurrency flags.

**Experiment:** remove one unnecessary dependency or raise one measured cap; verify overlap
in timestamps. Separately cancel obsolete PR runs using keys that distinguish workflow,
PR/ref, and any genuinely independent matrix axes. A common group across all matrix jobs
can serialize or cancel the shards that should run together. Preserve publication/deployment
ordering, cleanup, and any non-interruptible critical sections.
Use only contexts available at that scope: matrix-specific groups belong at job level,
not in a workflow-level key that cannot access the matrix.

**Accept only if:** total final-check latency improves and concurrent jobs cannot corrupt
shared state. Simulate a superseding commit and cancellation during setup/body/teardown;
confirm the current head still receives a complete result. GitHub's `concurrency` controls
overlapping runs; it does not turn on test workers. Default pending-run replacement and
optional queueing have distinct semantics: inspect the current
[concurrency documentation](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency)
rather than assuming FIFO ordering or adding a global lock.

## 8. Affected-only execution

**Inspect:** keep three decisions separate: selecting affected tasks, caching their results,
and distributing selected tasks. None proves the others correct. First reuse the installed
graph/runner: [Nx affected](https://nx.dev/docs/features/ci-features/affected),
[Bazel queries](https://bazel.build/query/language), or
[Vitest related](https://vitest.dev/guide/cli#vitest-related), as appropriate. Selection
limited to static module relationships cannot prove variable dynamic imports or data-file
dependencies. A new build system needs benefits that exceed graph/config maintenance.

**Experiment:** establish the event's actual base/head and tested revision, including PR
merge refs and merge queues. The comparison must cover unvalidated changes; comparing only
the latest push can omit earlier PR work or failures since the last successful main run.
Map changed files to owning targets and transitive reverse dependents. Model schemas,
generated inputs, fixtures, shared setup, runtime assets, environment/configuration,
lockfiles, and toolchains; add explicit global invalidators. For deletions/renames, consider
the previous graph as well as the new one so vanished edges do not hide former consumers.

**Accept only if:** shadow runs compare selection with full-suite results on representative
leaf, shared, config, fixture, rename/delete, and unknown-input changes. Inject a related
regression and prove it is selected and caught. Missing history/base, incomplete graph,
unmapped inputs, or uncertain prior success must broaden to the safe full suite. A truly
empty selection needs a published reason, not a missing required check. Log why each target
was selected; keep a full-suite reference lane to catch drift. Task-result caching additionally
needs complete content/environment inputs and hermetic outputs, not a successful old job
keyed only by branch name.

## 9. Runner fit

**Inspect:** confirm OS/image, architecture, effective CPU quota, RAM, storage, process limits,
and service/container overhead inside the job. Public/private runner specifications can
differ; hardware behind labels changes. Read actual logs and the current
[runner reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).
Classify CPU saturation, swapping/OOM, disk contention, network wait, and scarce-capacity
queueing separately before proposing a larger machine.

**Experiment:** compare authorized runner sizes with appropriately retuned workers. Hold
architecture constant first; architecture changes can affect native modules, emulation,
binary availability, and correctness. Measure useful throughput and cost for the full job,
including provisioning and downloads. CPU capacity unused during network waits will not
become a speedup merely by doubling cores; low RAM may matter more than vCPU count.

**Accept only if:** the chosen machine reduces the relevant latency or compute cost without
new compatibility or isolation risk. Keep OS-specific proof where the product needs it;
do not replace macOS/Windows coverage with Linux solely for cheaper minutes. Paid capacity,
self-hosted runners, credentials, persistent disks, and untrusted PR execution need their
existing owner/trust controls. Self-hosting is not a free default optimization. Record
the measured size/worker pairing and its fallback when capacity is unavailable.

## 10. Prerequisites and tail latency

**Inspect:** draw checkout -> setup -> install -> codegen -> build/service readiness ->
tests -> report/result dependencies, including hidden setup in composite actions. Find
the longest path and slack, not just the visually longest test job. A heavy aggregate
upload or coverage merge can be the last gate even after all tests finish.

**Experiment:** eliminate duplicate prerequisites; overlap independent build/analysis;
install only needed browser engines/system packages; use condition-based service readiness.
Compare a shared setup/build artifact with repeated local preparation. For example, a
3-minute shared build plus 1-minute transfer adds 4 minutes before fan-out; that is worse
than overlapping 2-minute local builds despite reducing repeated compute. Include cache
availability and artifact trust/version compatibility in the comparison.

**Accept only if:** actual final-check completion improves under the expected fan-out and
capacity. Moving code into a reusable workflow improves maintenance, not automatically
runtime sharing. Consumers must retrieve the exact compatible output they need, and a
failed producer must not leave consumers passing on stale files. Recheck aggregate-job
status handling for success, failure, cancellation, and legitimate empty selection using
the provider's [dependency results](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#needs-context).
Do not hold fast jobs open to make finish times appear uniform.

## 11. Additional wins and truthful green

**Inspect:** hunt waste across events and wrappers: duplicate push/PR runs, successful-run
videos, oversized artifact retention, repeated coverage, full-history checkout with no
history consumer, unbounded teardown, and heavyweight collection/import setup. Count tests
actually executed versus merely discovered. Inspect test globs and CI routing after moves;
a fast suite accidentally running zero tests is not an improvement.

**Experiment:** compare coverage-on/off cost without lowering the authoritative coverage
lane; retain the lane needed for PR protection. Record compact reports and failure-only
diagnostics where adequate. Keep full history where affected selection/versioning requires
it. Benchmark isolation/pool changes with reordered/leak tests; fewer process boundaries
can create order-dependent false success. Verify version support before using a new
profiler or configuration doctor.

**Accept only if:** a deliberate failing test makes the public CI command and final check
fail. Verify wrappers await children, preserve exit status through pipes/background tasks,
and collect diagnostics without converting failure to success. Detect accidental focused
or skipped tests where supported; distinguish authorized empty affected selection from a
broken test glob. Use fail-fast to save work only when losing other failures is acceptable;
do not benchmark canceled suites as completed suites. Keep explicit timeouts and meaningful
failure artifacts. Neither `continue-on-error` nor an unconditional green aggregate is a
performance fix.
