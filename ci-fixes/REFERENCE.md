# CI audit

Keep the original points 1-21 stable; the audit continues beyond them. Assess every
indexed check; implement only evidence-backed improvements. Read
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
| 22. Reproducible builds | Can clean builders recreate the declared outputs without hidden inputs? | [Independent rebuilds and input isolation](references/delivery-integrity.md#22-hermetic-and-reproducible-builds) |
| 23. Artifact identity | Is the artifact consumed or shipped the one actually validated? | [Digest continuity and verified provenance](references/delivery-integrity.md#23-tested-artifact-promotion-and-provenance) |
| 24. Execution trust | Can untrusted code reach credentials or privileged execution? | [Event, identity, and permission boundaries](references/delivery-integrity.md#24-execution-trust-and-credential-boundaries) |
| 25. Security signal | Did the intended scan actually inspect the intended inputs? | [Scanner completeness and dependency admission](references/delivery-integrity.md#25-security-gate-effectiveness) |
| 26. Rollout compatibility | Will mixed versions and real migrations preserve supported contracts and data? | [Version-skew and migration rehearsal](references/delivery-integrity.md#26-mixed-version-and-migration-compatibility) |
| 27. Executable configuration | Do workflows, matrices, and generated outputs mean what their consumers expect? | [Native validation and regeneration](references/delivery-integrity.md#27-configuration-and-generated-code-validity) |
| 28. Interruption recovery | What survives cancellation, timeout, eviction, or a killed runner? | [Owned-resource cleanup and idempotent recovery](references/operations.md#28-interruption-cleanup-and-safe-recovery) |
| 29. Infrastructure outages | Can a transient setup failure be contained without concealing a product defect? | [Failure classification and bounded retry budgets](references/operations.md#29-infrastructure-outage-containment) |
| 30. Reproduction parity | Can a maintainer replay the same failure outside the hosted runner? | [Sanitized, exact-input replay](references/operations.md#30-local-and-ci-reproduction-parity) |
| 31. Diagnostic integrity | Are results complete, attributable, and useful enough to locate the failure? | [Report failure controls and diagnosis latency](references/operations.md#31-diagnostic-and-report-integrity) |
| 32. Evidence privacy | Who can read retained CI evidence, and what sensitive data does it contain? | [Redaction, access, and retention](references/operations.md#32-evidence-privacy-and-retention) |
| 33. Regression prevention | Will CI detect a meaningful future latency or resource regression? | [Noise-aware budgets with negative controls](references/governance.md#33-performance-and-resource-regression-prevention) |
| 34. Policy drift | Do actual hosted behavior and ownership match the intended CI contract? | [Required/advisory policy and lifecycle reconciliation](references/governance.md#34-ownership-and-hosted-policy-drift) |

For an uncovered failure, apply the [entrypoint's extension rule](SKILL.md#choose-the-smallest-useful-change).
Keep new checks independent: caching correctness does not prove reproducibility;
test coverage does not prove safe rollout; cancellation does not prove cleanup.
The index is extensible, not a target count or a mandate to install every control.

**Decision record per check:** job/contract, observed bottleneck or risk, evidence,
adopt/reject/defer/not applicable, proposed experiment, acceptance/failure signal,
expected detection latency, owner, and rollback. Unknown is not not-applicable.

Preserve the [entrypoint's safety and completion rules](SKILL.md). "Green" is not
an optimization when work was silently skipped, retry-passed, or made incapable of
detecting the regression. Instructions here are audit policy, not an installed CI gate.
