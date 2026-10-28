# The 21-check CI audit

Assess every original point; implement only evidence-backed improvements. Read
[measurement and decision records](references/measurement.md) once, then the deep
sections for the jobs/contracts under investigation. A whole-suite audit uses all
sections; a focused repair still marks the other checks with an evidenced decision.

| Point | Decision to resolve | Deep investigation |
| --- | --- | --- |
| 1. Nightly | Which delayed failures are acceptable, and what stays on PRs? | [Routing, detection latency, required-check safety](references/jobs.md#1-nightly-routing) |
| 2. Job speed | Which phase actually limits this job? | [Profiling and removal of repeated work](references/jobs.md#2-job-runtime) |
| 3. Caching | Is restoration cheaper and correct for every relevant input? | [Cache classes, break-even, invalidation, trust](references/jobs.md#3-cache-economics-and-correctness) |
| 4. Actions upgrades | Can every action safely move to its latest stable release? | [Nested inventory, SHA verification, migration](references/jobs.md#4-github-actions-upgrades) |
| 5. Workers | Where is the stable throughput optimum? | [Worker/shard experiments and resource ceilings](references/jobs.md#5-worker-capacity) |
| 6. Shards | Is the last shard doing disproportionately expensive work? | [Duration-aware balancing and complete collection](references/jobs.md#6-shard-balance) |
| 7. Concurrency | What serializes independent work or wastes overlapping runs? | [Jobs, matrices, processes, cancellation](references/jobs.md#7-parallelism-and-concurrency) |
| 8. Affected tests | Can omitted tests be justified from a complete dependency model? | [Selection, task caching, fail-closed rollout](references/jobs.md#8-affected-only-execution) |
| 9. Machine | Is the bottleneck CPU, RAM, storage, network, or queueing? | [Runner selection and cost-normalized experiments](references/jobs.md#9-runner-fit) |
| 10. Prerequisites | Which setup/dependency edge extends the final finish time? | [DAG slack, setup reuse, aggregation](references/jobs.md#10-prerequisites-and-tail-latency) |
| 11. Other wins | Is CI doing avoidable work or reporting false success? | [Efficiency and failure-propagation checks](references/jobs.md#11-additional-wins-and-truthful-green) |
| 12. Flake diagnosis | What uncontrolled cause changes the result? | [Reproduction matrix and root-cause evidence](references/test-signal.md#12-diagnose-flakes) |
| 13. Fewer tests | Which tests protect no distinct failure? | [Contract ownership and preservation during pruning](references/test-signal.md#13-reduce-the-portfolio-without-losing-protection) |
| 14. No flakes | Can the unique contract be kept deterministically? | [Repair, replacement, removal, acceptance](references/test-signal.md#14-zero-tolerance-retention-policy) |
| 15. Must go red | Does a relevant defect reach a meaningful failing assertion? | [Negative controls, mutations, false-green traps](references/test-signal.md#15-prove-tests-can-fail) |
| 16. No tautologies | Is the oracle independent of the implementation? | [Self-proof patterns and legitimate contracts](references/test-signal.md#16-remove-tautologies) |
| 17. Minimal DOM emulation | What is the cheapest adequate test boundary? | [Node/browser placement and justified exceptions](references/test-signal.md#17-minimize-dom-emulation) |
| 18. Mock browser network | Is the real frontend isolated from live services without inventing its behavior? | [Fail-closed routing, fixture contracts, protocol edges](references/test-signal.md#18-mock-pr-browser-network) |
| 19. Latest frameworks | What blocks the latest stable, compatible toolchain? | [Version inventory, migration, ongoing updates](references/tooling.md#19-maintain-current-testing-frameworks) |
| 20. New paradigms | Does a supported new capability improve the same contract? | [Bounded automated A/B experiments and rejection](references/tooling.md#20-benchmark-new-paradigms) |
| 21. Nightly browsers | Which supported engine/platform differences deserve another lane? | [Risk-to-engine mapping and matrix pruning](references/tooling.md#21-risk-based-nightly-browsers) |

**Decision record per check:** job/contract, observed bottleneck or risk, evidence,
adopt/reject/defer/not applicable, proposed experiment, acceptance/failure signal,
expected detection latency, owner, and rollback. Unknown is not not-applicable.

Preserve the [entrypoint's safety and completion rules](SKILL.md). “Green” is not
an optimization when work was silently skipped, retry-passed, or made incapable of
detecting the regression. Instructions here are audit policy, not an installed CI gate.
