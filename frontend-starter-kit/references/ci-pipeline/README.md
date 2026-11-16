# Setup CI Pipeline

Set up or adapt GitHub Actions for the target repository; preserve its stack and policy.
Before platform/tool choices, read [current primary documentation](../../../read-the-damn-docs/SKILL.md)
and [CI maintenance](../../../t3code-skills/ci-maintenance/SKILL.md).
For an existing slow/flaky pipeline, start with [CI fixes](../../../ci-fixes/SKILL.md)
and measured run history rather than replacing workflows from a template.

## Steps

1. Resolve existing scripts, workflows/callers, required checks, coverage/bundle budgets,
   fork/credential boundaries, and pre-merge validation. Reuse them; add only requested gates.
2. Design the [workflow shape](REFERENCE.md): parallel independent checks, minimal job setup,
   truthful aggregation, and a full-suite pre-merge gate on the fresh combined candidate.
   Prefer a merge queue; missing hosted protection is a report, not permission to change it.
3. Use the [CI measurement goals](../../../ci-fixes/references/measurement.md#starting-budgets-not-a-checklist)
   unless the owner sets others. Benchmark cache/shard/runner changes, not blanket migrations.
4. Configure coverage reports, visual checks, bundle budgets, or dependency automation only
   within requested scope and existing contracts. Do not invent coverage thresholds,
   snapshot updates, auto-merge policy, paid runners, or report-token permissions.

## Verify

- Validate syntax, action pins, and actual script exits with repository-native commands.
- Prove a relevant failure reaches the final required check; missing/canceled shards cannot pass.
- Verify PR and full-suite pre-merge events/refs, including stale-candidate/base rejection.
- Compare real before/after runs for claimed performance gains. List hosted-only verification
  and account/secret/billing/policy needs together; local checks do not prove hosted behavior.

Use [consumer review safeguards](../../../shared/review-enforcement.md) without mutating
hosted settings outside authorization. See [REFERENCE.md](REFERENCE.md) for design decisions.
