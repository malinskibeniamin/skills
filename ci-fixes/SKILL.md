---
name: ci-fixes
description: "Diagnose and fix slow or flaky CI, inefficient jobs, and low-signal test suites. Use for CI runtime, caching, sharding, affected-only testing, runner sizing, or testing-tool modernization."
---

# CI fixes

Make CI faster without letting it lie, whatever the stack. Optimize commit-to-required-result
latency, not just test duration; track compute separately. Audits/plans stay read-only.
Implement only when asked; install no audit tool, provision no runner, change no hosted policy,
create no schedules, and start no agents as a side effect.

## Protect the merge boundary

- The full regression suite must pass on the candidate combined with the current target
  branch before merge. Selection narrows PR feedback only; nightly or post-merge runs are
  not substitutes. Prefer a merge queue; without one, require equivalent fresh pre-merge
  proof. Report missing protection; changing queue/protection settings needs authorization.
- Keep first-attempt failures visible. Fix the cause instead of adding test retries,
  widening timeouts, skipping/quarantining tests, or weakening assertions/coverage for speed.
  Bounded idempotent infrastructure recovery is a [separate case](references/operations.md#29-infrastructure-outage-containment).

## Establish the baseline

1. Resolve the repository, branch, workflows/callers, actual scripts/test configs, required
   checks, merge policy, and local instructions. Identify the full-suite pre-merge lane.
2. Collect comparable recent runs, including failures/reruns: commit/run URLs, queue time,
   dependencies, setup/build/test/upload time, cache state, resources, workers, shards,
   executed test counts, and first-attempt failures. Prefer existing provider-native reports;
   missing history is unknown, not evidence of speed or reliability.
3. Trace the critical path through the last required result. Identify its largest removable
   wait or repeated cost before assuming tests are slow. Record workload and sample size.
   Use the [measurement protocol and starting budgets](references/measurement.md): PR result
   under 2 minutes median / 3 minutes p95, unless the owner sets another target. Goals are
   not guarantees or permission to drop protection; report unsupported tails as unknown.

## Choose the smallest useful change

Use the [CI audit index](REFERENCE.md) to route the observed bottleneck, not as a mandatory
migration checklist. A whole-CI audit assesses every point; a focused repair investigates
only its bottleneck and affected safety contracts, marking the rest out of scope.
Record **adopt**, **reject**, **defer**, or **not applicable** with evidence for assessed points;
unknown is not not-applicable. Rank measured critical-path gains, compute, confidence, and
maintenance risk. Fix the biggest evidenced bottleneck first, then remeasure.

Extend the index only for a distinct protected contract with a falsifiable experiment,
acceptance signal, and owner; cross-link overlap. Broader diagnosis grants no permission
to provision services, expose data, or change security/delivery policy.

Load supporting guidance only for the work being performed:

- Workflow edits: [CI maintenance](../t3code-skills/ci-maintenance/SKILL.md), including its
  canonical source and trust-boundary rules. Keep credentials, caches, artifacts, and forks safe.
- Test pruning: [test audit](../test-audit/SKILL.md). Name each retained contract and primary
  test owner before deletion; speed and coverage percentages alone do not justify removal.
- Flake diagnosis: [diagnosing bugs](../diagnosing-bugs/SKILL.md). Reproduce first-attempt
  failures and fix the owner or harness; passing on retry is not a fix.
- Tool changes: [upgrade dependency](../upgrade-dependency/SKILL.md). Verify version support,
  migration, and runner compatibility from primary sources. Benchmark alternatives alongside
  existing gates before replacement; named vendors/tools are candidates, not defaults.

Change one coherent bottleneck at a time; when PRs are requested, keep each optimization
small and independently measurable without splitting an existing owned PR unasked.
Add a failing public-contract test only for an uncovered behavioral risk; configuration
and documentation use executable validation, not tests that grep instructions.

## Prove the improvement

- Run workflow/repository gates and affected tests. Exercise cache miss, hit, and invalidation;
  verify shard completeness, failure propagation, and required-check completion.
- For selection, compare with full-suite results, force full execution on lockfile/CI-config
  changes or uncertain inputs, and deliberately omit a relevant change in a disposable
  selector experiment: the full pre-merge gate must catch it. Restore and verify green.
- Compare before/after on matched workload, runner, versions, workers, and cache conditions
  except the variable under test. Repeat real runs; report raw samples, median, supported
  tails, queue time, and runner-minutes separately. Local timing is not hosted CI proof.
- For workers/isolation/distribution, exercise repeated and reordered runs at the proposed
  concurrency; inspect memory, CPU, shared-state races, and first-attempt failures.
- For pruning, preserve unique failure detection and critical journeys with negative controls;
  compare line/branch coverage using the same instrumentation, exclusions, and denominator.
- Verify the full-suite pre-merge event/ref and stale-base invalidation. Missing hosted access
  or runs remain explicit gaps, not evidence of safety. Never hold fast jobs open for symmetry.

## Handoff

Lead with the result and its limit: bottleneck, assessed decisions, real before/after total
CI latency and compute, sample/cache conditions, commands/run URLs, protection proof, remaining
risks, and rollback. Include changed test ownership/deletion rationale and version/source dates
when relevant. Separate measured gains from proposals; unavailable totals stay unknown.
Finish reversible in-scope work first; consolidate needs for accounts, secrets, paid capacity,
or policy changes into one actionable owner list. Keep receipts in the existing evidence
location; summarize rather than dumping logs.
