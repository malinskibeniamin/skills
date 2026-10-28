---
name: review
description: Use for evidence-backed review of diff-introduced defects in branches, PRs, WIP, or releases.
---

# Review

Review pinned scope. Keep one owner; explicit delegation. Do not edit, commit, push or post without intent.
Scoped repairs: [author delivery](../shared/delivery-workflow.md). Posting comments need intent.

## Review contract

- **Objective**: does the diff achieve its outcome without a credible defect?
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

1. Read spec, rules, complete diff, callers and behavior. Do not trust a PR summary over code. Include applicable `REVIEW.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`.
2. For changed assumptions, reverse-trace authoritative producers, schemas, storage,
   consumers and public surfaces. Search by domain concept, field and emitted value,
   not only the changed symbol.
3. Reuse [change evidence](../shared/change-evidence.md).
4. Check independent artifacts in relevant unchanged code, base, recent history,
   runtime evidence and fixtures; match fixtures to production shape.
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

Add surface-specific scrutiny only when the diff supplies evidence:

Interface: [checks](../shared/INTERFACES.md#interface-review).

| Surface | Check |
|---|---|
| Customer-facing UI/CLI/report | Render, states, copy, keyboard/a11y, console, viewport |
| Security/privacy/data loss | Attacker/access, trust boundary, credential source-to-sink, reachable impact, recovery |
| Documentation/public behavior | Discoverability, defaults/omission, migration/release notes; internal-only changes owe none |
| API/schema/SQL/PostgreSQL | Compatibility, migrations, generated output, actual dialect |
| Go/concurrency/workflows | Ownership, cancellation, races, retries, idempotency |
| Dependency/external API | Primary docs, versions, lockfile, advisories |

Proto/Buf/codegen/runtime: load [protobuf](../protobuf/SKILL.md) fully.

Load per [dependency loading](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
Call the Skill tool separately for "product" and "lie-detector"; apply their hats inline.
Authorized axes run in the foreground; aggregate every report.

### Classify

Place concrete diff-introduced findings on the tightest changed line; state impact and smallest safe fix.

- **P0**: exposure, data loss, outage, or impossible core flow.
- **P1**: user regression, broken contract, false success, or major a11y defect.
- **P2**: useful bounded correction with lower impact.
- Omit optional future work and polish from inline comments.

No performance finding without measurement or a structural bound. No edge-case finding
without credible risk.

### Synthesize

Use [communication](../shared/communication.md); keep schema.
Lead with findings. Deduplicate by root cause. Omit praise and narration. For a re-review, mark each prior finding's state.
Separate value from defects.

## Deep mode

For `--deep`, use the same loop with a complete applicability ledger. Read
[DEEP-AUDIT.md](DEEP-AUDIT.md); cover all surfaces and do not add automatic agents.

## Output

Schema: [REFERENCE.md](REFERENCE.md). Report
`[P0|P1|P2] <file:line> <title> - <evidence, consequence, correction, verify command>`.
Append `entrypoint, data, actions, observations, timing, limits`, fixed point, mode, counts,
the `product:` and `lie-detector:` lines, verdict, and residual limits. A clean review returns only those lines, verdict, and residual limits.
