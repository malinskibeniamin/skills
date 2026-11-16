# CI Pipeline Reference

Use the repository's existing package manager, scripts, compatible action versions, and
required-check names. This is a workflow design guide, not a copy-paste YAML template.
Read [CI maintenance](../../../t3code-skills/ci-maintenance/SKILL.md) for events, action
pins, credentials, permissions, and untrusted-data boundaries before workflow edits.

## Quality gate shape

- Run lint/format verification, typecheck, build, and tests in parallel unless an actual
  artifact/data dependency requires ordering. CI verifies formatting without silently fixing it.
- Keep setup job-specific: immutable dependency install, only needed browser engines/system
  packages, only consumed service containers, and condition-based readiness instead of sleeps.
- Preserve the full suite before merge on the fresh combined candidate. Prefer a merge
  queue and verify `merge_group` producers/reporting; without one, require equivalent
  fresh-base validation. A full run after push to main or at night is not a substitute.
- Narrow PR feedback only with a proven affected graph and full fallback for lockfile,
  CI-config, unmapped inputs, or missing history. Exercise a deliberately missed change
  against the full pre-merge gate; see [selection proof](../../../ci-fixes/references/jobs.md#8-affected-only-execution).
- Cancel superseded PR feedback runs, never default-branch or merge-group validation.
  Scope concurrency groups to avoid sibling shard cancellation and pending-run replacement.
- A final aggregate must reject failed, canceled, or missing required jobs/shards while
  distinguishing an explicitly justified empty selection. Preserve child/pipeline exit status.

Changing hosted protection or queue settings requires authorization; report gaps instead.
For syntax, consult [GitHub's merge-queue documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
and [concurrency semantics](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency)
at execution time, not fixed action versions or another repository's YAML.

## Measurement and runner fit

Use [CI fixes](../../../ci-fixes/SKILL.md) for baseline runs, critical-path diagnosis,
starting budgets, and one coherent optimization at a time. Keep raw before/after samples,
queue/setup/body/report times, first-attempt failures, and runner-minutes separate.
Neither a workflow's updated timestamp nor summed parallel job times is end-to-end latency.

Reuse available capacity first. Blacksmith, StarSling, and other runners are optional
measured candidates, not prerequisites. Account for queue time, resource fit, security,
price, and worker tuning. Do reversible work first; consolidate account/secret/billing
needs for the owner instead of creating a paid service or installing an audit tool.

For caches, compare restoration/save cost with recomputation; seed from trusted main runs
where supported. Verify remote task-cache writes as well as reads without exposing credentials
to forks. Fix perpetual misses at declared inputs/outputs; test miss, hit, and invalidation.
Playwright browser caching is a benchmark candidate, not an assumed gain. See
[cache correctness](../../../ci-fixes/references/jobs.md#3-cache-economics-and-correctness).

## Test sharding

Shard by measured durations, not equal file counts or a fixed time threshold. Include
queue/setup/report duplication and runner capacity when judging the gain. Keep stable
identities, a safe weight for new tests, complete shard union, unique artifacts, and a
fail-closed aggregate; follow [shard validation](../../../ci-fixes/references/jobs.md#6-shard-balance).
Use the installed runner's compatible blob/report/coverage format. Do not assume downloading
some artifacts proves every shard ran, or that merging reports reinstalls dependencies.

Keep test retries at zero. Diagnose first-attempt failures; neither retries, wider timeouts,
weaker assertions, nor skipped tests make a performance improvement valid.

## Coverage gates

Preserve repository-owned thresholds, instrumentation, exclusions, and source denominators.
Compare merged coverage on the same basis and retain unique regression detection with
negative controls, not just percentages. Reports need minimum permissions and safe fork
handling; posting a diff is not authorization to run untrusted code with a write token.

## Bundle size budget

Use the target's existing bundle budget and representative routes/assets. A 300KB gzip
main chunk or 1MB total can be a starting hypothesis, not a universal gate. Measure the
production artifact and preserve its identity through validation/promotion; bundle size
does not prove interactive performance. New reports or blocking budgets need task scope.
