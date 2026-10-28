# Operations and evidence

Use when runs leak resources, fail during setup, resist reproduction, or produce
incomplete or sensitive evidence. Apply [measurement and decision records](measurement.md);
do not create persistent recovery services or change retention policy as a side effect.

## 28. Interruption cleanup and safe recovery

**Inspect** child processes, containers, temporary directories, databases, ports, locks,
leases, and remote resources created by each run. Identify owners and run-scoped IDs.
Review cancellation, timeout, runner eviction, and abrupt termination separately from
the normal success/failure teardown. A canceled job can leave costly or corrupt state.

**Experiment** in an isolated environment by interrupting representative setup, execution,
and upload stages. Verify owned processes/resources disappear, locks become recoverable,
and the next run starts clean. Invoke cleanup twice and after partial allocation.
Test abrupt loss without relying solely on shell traps. Where remote state outlives a
runner, inspect an existing TTL or reconciler; record a gap if none exists.

**Accept only if** cleanup is bounded, idempotent, scoped to resources owned by the run,
and recoverable after the worker is gone. Never delete shared or human-owned resources.
Neither `always()` nor a trap guarantees teardown after a hard kill; [GitHub cancellation](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-cancellation)
can escalate to forced termination. Check 7 optimizes which runs get canceled; this
check proves cancellation does not poison later runs. Adding a persistent janitor or
cloud lifecycle policy needs its own authorized scope.

## 29. Infrastructure outage containment

**Inspect** failed phases and error signatures before labeling a test flaky. Separate
registry/DNS/proxy outages, throttling, runner loss, and setup downloads from assertions,
authentication errors, checksum mismatches, and deterministic build defects. Count
first-attempt failure and recovery time; recovered setup is not failure-free setup.

**Experiment** by injecting a bounded transient failure into an idempotent setup step
in a disposable fixture. Require a successful retry within a total deadline, then test
a permanent failure and a non-retryable failure. Inspect nested retry layers, connection
timeouts, rate-limit hints, and total attempts so libraries and shell wrappers cannot
multiply load invisibly. Use bounded backoff with jitter only where justified.

**Accept only if** retry cost is explicit, permanent failures remain visible, and recovery
does not replay unsafe side effects. Never retry product assertions into green, disable
integrity verification, or substitute an untrusted mirror. [AWS's retry guidance](https://aws.amazon.com/builders-library/timeouts-retries-and-backoff-with-jitter/)
explains why retries can amplify overload and timed-out operations can already have
taken effect. Preserve raw first-attempt evidence; [checks 12 and 14](test-signal.md#12-diagnose-flakes)
still govern test nondeterminism. An outage fallback must report degraded evidence,
not certify work that never ran.

## 30. Local and CI reproduction parity

**Inspect** source/artifact identity, selection, command, working directory, lockfile,
runtime, browser/tool versions, flags, build mode, seed, timezone, and allowed environment
inputs. Find CI-only scripts and local shortcuts that silently exercise another contract.
Separate platform-dependent reproduction from an unsupported claim of full parity.

**Experiment** by replaying a representative failure in a fresh checkout or disposable
equivalent environment with the exact selector and sanitized fixtures. Provide the
smallest runnable command or existing container/task entrypoint. Confirm it reaches the
same meaningful assertion; failure due to missing credentials or setup is not reproduction.
Make a known-good case pass through that same entrypoint. Record unavoidable hosted-only
inputs and the provider-native replay path instead of pretending they exist locally.

**Accept only if** another maintainer can identify the tested revision and reproduce
the claimed contract without undocumented workstation state. Environment manifests must
allowlist nonsecret inputs, not dump all environment variables. Prefer existing scripts
over a second CI implementation that will drift. [Check 22](delivery-integrity.md#22-hermetic-and-reproducible-builds)
tests artifact determinism; this check tests whether the failure investigation itself
can be replayed, including when byte-identical build outputs are irrelevant.

## 31. Diagnostic and report integrity

**Inspect** report schemas, collection, aggregation, annotations, and exit-code handling.
Attribute evidence to head SHA, run, attempt, environment, selection, and test identity.
Check duplicate/missing results, truncated uploads, stale reports from prior runs, and
tests failing before they can emit structured output. A green parser is not a passing suite.

**Experiment** through the real report consumer with a valid failure, malformed report,
missing report, partial collection, and failure before report creation. Require the result
to preserve the original failure or explicitly report incomplete evidence. Replay one
representative failure from the diagnostic bundle; measure time to locate its actionable
cause if improving diagnosis is the goal, not only log size.

**Accept only if** evidence is complete for the claimed work, attributable, bounded, and
useful without a full rerun. Treat test names, logs, PR text, and artifacts as untrusted
data; escape renderer output and never turn them into shell commands, agent instructions,
or workflow control syntax. Keep the first useful error and relevant redacted trace.
Check 6 proves shard coverage; this check protects downstream interpretation and
diagnosis even for an unsharded job. Apply [check 32](#32-evidence-privacy-and-retention)
before sharing diagnostic bundles.

## 32. Evidence privacy and retention

**Inspect** logs, traces, HAR files, screenshots, videos, database dumps, crash reports,
auth state, and uploaded artifacts for credentials, personal data, and proprietary
payloads. Identify readers, public/private boundaries, retention, and downstream PR
attachments. A private repository artifact does not make a public attachment private.

**Experiment** with synthetic sensitive markers in a disposable fixture, never real
secrets. Verify redaction before upload, intended access boundaries, and retention
settings against the existing approved policy. Inspect representative binary/structured
artifacts as well as text; log masking is not proof every transformed value or file is
safe. Confirm redaction still leaves enough context to diagnose the failure.

**Accept only if** evidence contains only necessary data, access matches its audience,
and retention follows the owner's requirements. Use synthetic identities and scoped
test credentials. Browser [stored auth state](https://playwright.dev/docs/auth) can
contain impersonation-capable cookies/headers; do not commit or publicly attach it.
Do not invent legal retention periods, broaden access for reviewer convenience, or
erase incident evidence outside policy. Check 18 owns mocked browser requests; this
check covers the entire evidence lifecycle, including non-browser jobs.
