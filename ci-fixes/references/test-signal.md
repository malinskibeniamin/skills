# Test signal: points 12-18

Use the [measurement protocol](measurement.md) and
[test-audit ownership/deletion evidence](../../test-audit/SKILL.md). Optimize the
cost of independent regression protection, not the number of green test names.

## 12. Diagnose flakes

**Inspect:** classify a failure before calling it flaky. An assertion that fails consistently
on the same code is a regression; a runner outage is infrastructure; a result that changes
with uncontrolled order/time/state is a nondeterminism investigation. A retried success
is evidence to inspect, not proof the original failure was harmless. Capture the original
commit, command, first-attempt trace/logs, worker/shard identity, seed/order, resource use,
locale/timezone, fixtures, requests, and previous test's cleanup.

**Experiment:** choose a cause-driven reproduction matrix, not arbitrary repetition:

| Failure signature | Discriminating experiment | Likely repair boundary |
| --- | --- | --- |
| Passes alone, fails after another test | Replay the order, then reverse it | Global/module state, mocks, storage, teardown |
| Fails only with more workers | Compare a worker grid and isolate account/port/file identities | Shared resource or resource exhaustion |
| Timeout without assertion progress | Inspect traces, readiness, CPU/RAM, child exits, open handles | Real race, missing readiness, deadlock, overloaded host |
| Locale/date-dependent mismatch | Reproduce the recorded locale/zone/clock boundary | Clock/input contract or locale-sensitive fixture |
| Sporadic data/network mismatch | Replay captured response/ordering with deterministic fixtures | Live dependency, stale response, test data ownership |
| Randomized sequence finds a defect | Replay its exact seed and actions | Product invariant; retain a deterministic regression |

**Accept only if:** a concrete cause explains both failure and apparent success. Replace
sleeps with observed state or a controllable clock below the browser layer; isolate mutable
fixtures; clean up and await owned async work. Prove the original sequence fails before
the repair and passes afterward, then exercise adjacent order/concurrency. Tests sharing
one browser context need explicit state ownership; understand the runner's
[isolation model](https://playwright.dev/docs/test-isolation). If reproduction remains
unknown, retain the failing evidence and report unresolved work. More timeout budget
is justified only by a measured valid operation, not by hiding unexplained failures.

## 13. Reduce the portfolio without losing protection

**Inspect:** inventory declarations and their setup cost, protected contract, credible
failure, production owner, strongest remaining proof, and test-only seams. Read complete
assertions and relevant source/history; names and coverage percentages cannot establish
redundancy. Build a feature-to-failure map before editing. Group tests by independently
detectable failures, not by framework or extension.

**Experiment:** choose one primary adequate boundary per contract. For example:

| Contract | Primary proof | Additional layer needs a different reason |
| --- | --- | --- |
| Pure domain rule/validation | Fast units with independent examples/boundaries | A browser need not replay every input permutation |
| Request encoding, server authorization, storage transaction | Real owning API/transport/storage boundary with controlled dependencies | A UI mock cannot replace the owner's protection |
| Focus, layout, navigation, browser state | Small real-browser interaction journey | Calling a handler directly does not cover browser behavior |
| Build/package/protocol compatibility | Executable consumer or independent artifact contract | Source inventory/version echoes add no independent protection |

Move unique cases into the keeper, run it, and prove its negative controls before deleting
the duplicate layer. Consolidate table-driven cases only when they represent distinct risks;
hiding repeated iterations under one test name lowers the count, not runtime. Remove dead
test-only exports, wrappers, flags, reset seams, and fixtures whose only consumers disappeared.
Avoid a huge merged test file that destroys useful affected selection or parallelism.

**Accept only if:** each deleted contract has a named keeper, or evidence that it is obsolete
or never meaningful. Compare full retained-suite line/branch coverage with identical source
denominators, thresholds, instrumentation, and exclusions; inspect lost branches, not just
aggregate percentages. Mutation/negative controls must still detect the removed suite's
credible failures. Keep security/storage/transport distinctions even when happy paths look
similar. Large cuts are welcome when proven; no deletion quota or invented "quality unchanged"
guarantee. A static or slow test may remain the cheapest unique guard. Do not delete a baseline
product failure as cleanup. Use small coherent batches and rerun CI selection after moves.

## 14. Zero-tolerance retention policy

**Inspect:** separate diagnosis from retention. The desired end state is no flaky tests in
the retained suite, not a tolerated retry-pass percentage. Inventory retries, skips, expected
failures, quarantine lanes, and ignored reporter statuses that currently hide nondeterminism.
See how the framework [classifies retry-pass results](https://playwright.dev/docs/test-retries).

**Experiment:** make a per-test disposition:

- **Repair:** keep the contract and fix the race/state/fixture cause, with a deterministic
  reproducer and the original failure evidence.
- **Replace:** move unique protection to a reliable boundary, prove it catches the defect,
  then remove the flaky test and obsolete seam.
- **Delete:** only when no independent protection is lost, as established in point 13.
- **Unresolved:** keep the failure visible and report incomplete work; do not manufacture
  a passing result by relocation, quarantine, weaker assertions, or extra retries.

**Accept only if:** zero-retry execution is the retained target and any detected retry-pass
remains visible/failing where the installed framework supports it. Exercise the repaired
failure conditions, not only many easy repetitions. Zero failures in a finite sample cannot
prove "never flaky": under independent identical Bernoulli trials, zero failures in `n`
trials gives a one-sided 95% upper failure-probability bound `1 - 0.05^(1/n)`, about `3/n`.
CI runs often violate those independence assumptions. Use that limitation to avoid false
confidence, not to invent an acceptable flake budget. Cause, deterministic regression,
and representative stress evidence matter more than a lucky streak.

## 15. Prove tests can fail

**Inspect:** require an observable contract, independent oracle, and reachable assertion.
Look for unawaited promises, expectations in branches/callbacks that never run, swallowed
errors, assertions on a stub's own output, and fixtures that pre-populate the result the
owner should produce. Verify the actual CI command discovers and executes the test.

**Experiment:** in a disposable snapshot, inject a plausible production defect: invert a
boundary comparison, omit a persistence write, drop cancellation, or change a request field.
Run the intended keeper through its public command and inspect the precise failure. Restore
the source and verify green. For type contracts, demonstrate the intended compiler error;
do not substitute an unrelated runtime test. Pair a rejecting case with a valid control so
an unconditional rejection cannot masquerade as validation coverage.

**Accept only if:** the targeted defect causes the relevant assertion/contract failure,
not a missing import, crashed fixture, unrelated guard, or unreachable setup. Automated
mutation tools distinguish killed, survived, uncovered, timeout, and invalid outcomes;
inspect those categories rather than treating a single score as proof. A hang/timeout is
meaningful only when bounded completion is the contract and the mutation causes that defect,
not because the host was overloaded. See
[mutation outcome definitions](https://stryker-mutator.io/docs/mutation-testing-elements/mutant-states-and-metrics/).
Equivalent mutants can preserve behavior; do not add artificial tests to kill them. A
surviving meaningful mutation requires repair or better proof before its test is trusted.
Never leave deliberate mutations or temporary failing artifacts in the delivered patch.

## 16. Remove tautologies

**Inspect:** trace where the expected value comes from. A test has no independent oracle
when it compares a function with itself, copies its implementation into the assertion,
derives the expected result from the helper under test, or asks a mock to return exactly
what it then checks. For example, `expect(normalize(x)).toEqual(normalize(x))` proves
nothing about normalization. Literal expectations can also be empty proof if the mocked
collaborator, rather than production, performs all the asserted behavior.

**Experiment:** replace self-proof with a worked example/specification or exercise the
actual owner; apply point 15's negative control. Delete installed-version assertions that
merely compare a dependency's reported version with its own manifest, export inventories
duplicated from source, render-only probes, and snapshots that nobody can justify against
an independent requirement. Use static tooling for syntax/inventory rules, not source greps
posing as runtime behavior.

**Accept only if:** retained tests survive behavior-preserving refactoring and fail a
credible contract violation. Distinguish a version echo from a real compatibility contract:
an executable consumer that fails when an advertised API breaks is useful even if the
installed version is unchanged. Likewise, independent package/release/protocol requirements
can deserve proof; they must not merely restate the file they inspect. Removing a tautology
needs no replacement assertion unless there is an actual unowned contract.

## 17. Minimize DOM emulation

**Inspect:** classify what every happy-dom/jsdom suite actually needs: pure computation,
component interaction, framework lifecycle, or real browser behavior. Profile environment
construction and repeated setup separately from assertions. A fast test body does not make
an expensive emulated environment worthwhile. Inspect project defaults that boot a DOM for
units that never use it.

**Experiment:** move pure state transitions, validation, formatting, and domain logic to
the plain runtime without creating artificial production seams. Put focus/keyboard, layout,
navigation, native form behavior, browser storage, and platform APIs in a small real-browser
owner suite with mocked backend traffic. Real browser component mode can be a candidate for
isolated interaction contracts, not an instruction to migrate the whole suite. Evaluate its
actual supported capabilities in [Vitest Browser Mode](https://vitest.dev/guide/browser/).

**Accept only if:** emulator tests left behind have a distinct contract and measured advantage
over a cheap unit or browser owner. Do not replace every emulator assertion with a browser
journey; first remove duplicate contracts. A DOM emulator does not prove browser layout or
engine fidelity, and invoking handlers directly does not prove user interaction. Verify that
moved pure tests run in the plain environment, not an inherited DOM project; verify browser
tests still use the real frontend rather than mocked components implementing the feature.
Retain necessary lifecycle/integration proof at one adequate boundary.

## 18. Mock PR browser network

**Inspect:** map network across app startup, auth setup, pages/popups, API/RPC calls,
redirects, streams/WebSockets, service workers, and third parties. PR browser tests must
run the real frontend without live backend/third-party dependencies, including hidden
pre-test seeding helpers. Dependency installation is not browser traffic; legitimate local
documents/assets still need to load.

**Experiment:** install context-level routing before page creation/navigation when initial
or popup requests matter. Match method, endpoint, and relevant body/operation fields, not
an overly broad URL that fulfills every call with success. Maintain a fail-closed fixture
registry with protocol/schema source, scenario, owner, and expected request shape. Handle
unexpected backend/external requests by recording and aborting them; assert the recorded
list is empty at the owning teardown boundary. An abort alone may be hidden by a UI fallback.

Keep the fixture source independent of the consumer logic. Schema validation catches shape
drift, not every semantic incompatibility; retain cheap independent protocol/consumer checks.
Cover required success/empty/error/race contracts once at their owners, including stale
responses, cancellation, redirects, and protocol framing where relevant. Use controllable
response ordering, not sleeps. For RPC, preserve content types, status/error envelopes,
headers, and streaming semantics; returning arbitrary JSON is not a transport fixture.

**Accept only if:** removing a fixture or changing a meaningful response field fails the
intended journey; no unhandled call escapes to a real service. Preserve the app's actual
request creation, deserialization, and state transition. Seed cookies/storage only when
auth setup is not the behavior under test; do not pre-complete the flow being asserted.
Redact secrets in HARs/traces and validate replay fixtures. With native route interception,
account for service-worker interception and separately routed WebSockets; do not block an
MSW worker while relying on it for mocks. See
[routing/service-worker/WebSocket semantics](https://playwright.dev/docs/network) and
[mock responses/HARs](https://playwright.dev/docs/mock).
Keep any necessary live compatibility lane explicitly outside PR browser execution; mocked
frontend success must never be presented as proof of a real backend integration.
