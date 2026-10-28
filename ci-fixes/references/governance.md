# Regression prevention and ownership

Use when an optimization should remain effective or workflow behavior has drifted
from owner policy. Keep controls proportionate: existing measurements and native
configuration first, not new mandatory services or recurring work by default.

## 33. Performance and resource regression prevention

**Inspect** whether existing runs retain comparable queue/setup/build/test/upload time,
runner-minutes, memory peaks, artifact sizes, and workload size. Identify a useful
baseline window and accountable owner. Separate runner-image, workload, toolchain,
event, and cache changes from a code regression. An absolute duration without context
can punish a larger suite or hide a smaller suite getting slower.

**Experiment** with existing benchmark/report infrastructure on repeated comparable
runs. Predeclare a meaningful budget or trend alert and calibrate ordinary variation.
Use a realistic synthetic slowdown or memory growth in a disposable fixture to prove
the detector can go red, then exercise harmless noise to expose brittle thresholds.
Track setup/queue and execution separately so a provider incident does not become a
false product-performance diagnosis. Collect per-test detail only where it informs action.

**Accept only if** a material regression is detected with an actionable cause, normal
variance does not create another flaky gate, and collection/maintenance cost is smaller
than its value. Keep advisory versus blocking behavior aligned with owner policy.
Record baseline-reset rules so tool upgrades cannot silently erase regressions.
[Measurement](measurement.md) proves a one-off improvement; this check protects it
over time. A proposal for scheduled benchmarks or a hosted dashboard is not permission
to create either, nor evidence that monitoring is already installed.

## 34. Ownership and hosted-policy drift

**Inspect** workflow sources alongside actual hosted settings: required/advisory checks,
rulesets, check names and producing apps, event coverage, environments, reusable workflow
callers, and existing merge-queue behavior if configured. Resolve the current owner
policy and exceptions; a README or saved payload can be stale. Identify who owns each
job, test contract, generated configuration, and exception, including retirement consumers.

**Experiment** read-only first: reconcile expected checks with provider API settings and
recent event/run results. Look for renamed or deleted checks still required, missing
events, duplicated producers, expired exceptions, and consumers relying on retired output.
For changed policy/config validators, use isolated valid and known-bad cases through
the real validation command. Assert the intended contract rather than incidental prose;
static instruction checks do not establish agent behavior or human approval.

**Accept only if** observed hosted behavior matches the stated policy, drift has an
owner/disposition, and job retirement preserves live callers. [GitHub branch protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
and rulesets must be inspected in the target repository; do not infer them from another
project's defaults. Preserve advisory CI where chosen and required checks where required.
Changing protection, merge policy, or credentials remains a reserved decision; never
silently bootstrap stronger or weaker gates. Unknown hosted state is deferred evidence,
not proof that policy is satisfied or permission to block delivery against owner intent.
