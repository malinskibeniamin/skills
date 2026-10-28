---
name: ci-fixes
description: "Diagnose and fix slow or flaky CI, inefficient jobs, and low-signal test suites. Use for CI runtime, caching, sharding, affected-only testing, runner sizing, or testing-tool modernization."
---

# CI fixes

Make meaningful CI green sooner, with less compute and no lost regression protection.
Optimize time from commit to the last required check, not just individual test duration.
Preserve the requested endpoint: audits and plans stay read-only; implement only when asked.
Do not create schedules, buy runners, change branch protection, or start agents as a side effect.

## Establish the baseline

1. Resolve the target repository, branch, workflows, reusable/composite actions, scripts,
   test configs, required checks, and relevant instruction files. Inspect actual commands.
2. Collect comparable recent runs, including failures and reruns: commit/run URLs, queue
   time, job dependencies, setup/build/test/upload time, cache state, runner resources,
   workers, shard durations, test counts, and first-attempt failures. Use provider-native
   logs/reports; unavailable history is unknown, not evidence of speed or reliability.
3. Draw the critical path from prerequisites through the final required result. Separate
   wall-clock latency from total runner-minutes/cost; record sample size and environment.

## Choose the smallest useful change

Read the complete [CI audit](REFERENCE.md). Assess every indexed check; record each applicable
job's decision as **adopt**, **reject**, **defer**, or **not applicable**, with evidence.
Do not change every lever just because it exists. Rank by measured critical-path savings,
compute savings, confidence, and implementation/maintenance risk. Unknowns need a small
experiment, not invented estimates. Never delay fast jobs merely to align finish times.

The original checks are a foundation, not a ceiling. Follow the index into delivery
integrity, operations, and governance when relevant. Extend it for an uncovered failure
only with a distinct protected contract, falsifiable experiment, acceptance signal, and
owner; cross-link overlapping checks instead of multiplying them. Broader diagnosis grants
no permission to provision services, expose data, or change security/delivery policy.

Load supporting guidance only for the work being performed:

- Workflow edits: [CI maintenance](../t3code-skills/ci-maintenance/SKILL.md), including its
  canonical source and trust-boundary rules. Keep credentials, caches, artifacts, and forks safe.
- Test pruning: [test audit](../test-audit/SKILL.md). Identify each retained contract and its
  primary test owner before deletion; speed and line coverage alone do not justify removal.
- Flake diagnosis: [diagnosing bugs](../diagnosing-bugs/SKILL.md). Reproduce first-attempt
  failures and fix the owner or harness; passing on retry is not a fix.
- Tool upgrades: [upgrade dependency](../upgrade-dependency/SKILL.md). Verify current stable
  releases, migration guides, and runner compatibility from primary sources at execution time.

For implementation, change one coherent bottleneck at a time. New behavior and repairs
start with a failing public-contract test; configuration and documentation use executable
validation rather than tests that grep the instructions. Preserve unrelated work.

## Prove the improvement

- Run workflow syntax/repository gates and the affected tests. Exercise cache miss, hit,
  and invalidation paths; compare selected tests against a full-suite reference when changing
  selection. Verify failure propagation, missing shards, and required-check completion.
- Benchmark before/after on the same workload, runner, tool versions, worker count, and
  cache conditions except for the variable under test. Repeat runs; report raw timings,
  sample counts, median and tail where meaningful, runner-minutes, and queue time separately.
- After changing workers, isolation, or distribution, exercise repeated and reordered
  runs at the proposed concurrency. Inspect memory, CPU, flakes, and shared-state races.
- For pruning, compare full retained-suite line/branch coverage with the same instrumentation,
  thresholds, exclusions, and source denominator. Preserve unique failure detection and
  critical journeys, not only percentages; use targeted negative controls or mutations.
- Run full regression checks appropriate to the changed contracts. Report hosted-only or
  unavailable verification explicitly; local success is not proof of GitHub CI success.

Green means correct work actually ran. Keep failures visible: no swallowed exits,
`continue-on-error`, weakened assertions/coverage, permanent skips/quarantine, or retries
that conceal flaky tests. Never move a broken test to nightly to claim a fix.

## Handoff

Lead with the result and its limit. Include the critical bottleneck, decisions for indexed
checks, before/after evidence and sample/cache conditions, changed test ownership and
deletion rationale, version/source verification dates, actual commands/run URLs, unresolved
risks, and rollback. Distinguish measured gains from proposed experiments. Keep detailed
receipts in the repository's existing evidence location; summarize rather than dumping logs.
