---
name: review
description: Use for evidence-backed review of diff-introduced defects in branches, PRs, WIP, or releases.
---

Review: read [Poteto](../shared/POTETO-NATIVE.md#review-and-diagnosis).

Scope. Keep one owner; explicit delegation. Do not edit, commit, push or post without intent.
Fixes: [author delivery](../shared/delivery-workflow.md). Posting comments need intent.

Depth/convergence: [operating model](OPERATING-MODEL.md); no added permissions.

## Review contract

- **Objective**: achieve the outcome without credible defects.
- **Guardrails**: diff-introduced only; standards separate from product/spec gaps;
  generated files are evidence.
- **Verification**: Dogfood every runnable change yourself at its real entrypoint.
- **Stop**: cover every surface and evidence gap.

Missing fixed point: ask. Otherwise resolve
`BASE=$(PR_BASE_REF="${REVIEW_BASE:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`,
pin head/merge-base SHAs; inspect their complete diff and log.
WIP includes staged, unstaged, relevant untracked inputs; label exclusions.
Mutations/concurrent reads: [snapshots](REFERENCE.md#source-snapshots-and-mutation-tests).
Recheck identity before verdict; drift invalidates affected evidence.

## Evidence loop

**inspect -> verify -> classify -> synthesize.**

### Inspect

1. Read spec/rules, full diff, callers/behavior and applicable `REVIEW.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`. Do not trust a PR summary.
2. For changed assumptions, reverse-trace authoritative producers, schemas, storage,
   consumers and public surfaces. Search by domain concept, field and emitted value,
   not only the changed symbol.
3. Reuse [change evidence](../shared/change-evidence.md).
4. Check independent artifacts in relevant unchanged code, base, recent history,
   runtime and fixtures; match fixtures to production shape.
5. Build a behavioral counterexample. Map permissions/surfaces; skip formatter-owned style and pre-existing defects.
6. What could still be wrong if tests pass?

### Verify

- Reproduce from source, schema, primary docs or an executable check.
- When safety hinges on one non-local fact, use `/blast-radius`; carry proof, not prose.
- With representative live-scale data, exercise the intended path and one credible failure or recovery path.
  Observe console/network/logs and response time; name unsafe/unavailable paths.
- Inspect test integrity: public behavior, RED, assertions, coverage, no duration waits.
  Source-text checks are no coverage unless text is public output; delete or replace at a
  public seam. Use static analysis for syntax.

Add surface-specific scrutiny only when the diff supplies evidence ([interfaces](../shared/INTERFACES.md#interface-review)).

| Surface | Check |
|---|---|
| Customer-facing UI/CLI/report | Render, states, copy, keyboard/a11y, console, viewport |
| Security/privacy/data loss | Attacker/access, trust boundaries, credential flow, reachable impact, recovery |
| Documentation/public behavior | Discoverability, defaults/omission, migration/release notes; none for internal-only changes |
| API/schema/SQL/PostgreSQL | Compatibility, migrations, generated output, actual dialect |
| Go/concurrency/workflows | Ownership, cancellation, races, retries, idempotency |
| Dependency/external API | Primary docs, versions/pins, advisories |

Proto/Buf/codegen/runtime: load [protobuf](../protobuf/SKILL.md) fully.
[Dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies):
Call the Skill tool separately for "product" and "lie-detector"; apply their hats inline.
Authorized axes: foreground; aggregate reports.

### Classify

Place diff-introduced findings on the tightest changed line; give impact and smallest safe fix.

- **P0**: exposure, data loss, outage, or impossible core flow.
- **P1**: user regression, broken contract, false success, or major a11y defect.
- **P2**: useful bounded correction with lower impact.
- Omit future work/polish from inline comments.

No performance finding without measurement or a structural bound. No edge-case finding
without credible risk.

### Synthesize

Use [communication](../shared/communication.md); keep schema.
Lead with count (including zero). Deduplicate by root cause; name bug class/affected instances.
For a re-review, use repair delta/prior findings after full coverage; widen for changed assumptions.
Prove dispositions; separate value from defects. Omit praise/unrelated bugs.

## Deep mode

For `--deep`, read [DEEP-AUDIT.md](DEEP-AUDIT.md); use the same loop and a
complete applicability ledger. Cover all surfaces; do not add automatic agents.

## Output

Use [REFERENCE.md](REFERENCE.md) for schema and finding format.
Append `entrypoint, data, actions, observations, timing, limits`, fixed point, mode, counts,
`product:`/`lie-detector:` lines, verdict and residual limits. Clean: receipt/verdict only.
