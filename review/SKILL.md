---
name: review
description: Review a diff for evidence-backed, diff-introduced product and engineering defects. Use for branches, PRs, WIP, or deep release audits.
---

# Review
Produce a diagnostic artifact from a fixed point to `HEAD`. Do not edit, commit, push,
reply, resolve, or post comments unless the user explicitly requests posting.
Keep one owner in the primary context; agents require explicit delegation.

## Review contract
- **Objective**: determine whether the diff achieves its requested outcome without a
  credible defect.
- **Guardrails**: report only diff-introduced, actionable findings; keep documented
  standards separate from product/spec gaps; treat generated files as evidence, not edit
  targets.
- **Verification**: trace claims to source, run cheap deterministic checks, and exercise a
  real entrypoint when runnable behavior is locally reviewable.
- **Stop**: every applicable surface is accounted for and each finding has evidence,
  consequence, priority, and a concrete correction.

If the fixed point is missing, ask what to review against. Otherwise use the PR base or
`origin/main`. Pin the comparison before reading summaries:

```bash
git diff <fixed>...HEAD
git log <fixed>..HEAD --oneline
```

## Evidence loop
**inspect -> verify -> classify -> synthesize.**

### Inspect
1. Read the request or spec, repository instructions, complete diff, and relevant
   call-sites. Do not trust a PR summary over code.
2. Map changed behavior, contracts, data flow, permissions, visible surfaces, and tests.
   Skip formatter-owned style and pre-existing defects.
3. Ask what could still be wrong if tests pass and the code appears to match the request.

### Verify

- Reproduce claims against source, schema, current primary documentation, or the smallest
  executable check.
- For runnable behavior, exercise the intended path and one credible failure or recovery path
  through the public seam. State exact environmental limits instead of guessing.
- Inspect test integrity: public behavior, correct failure before the fix, meaningful
  assertions, no weakened coverage, and no flaky duration waits.
- Challenge every helper, branch, dependency, option, and file against required behavior,
  semantic density, domain clarity, credible risk, and demonstrated scale.
Never optimize LOC or reward code golf; reduce concepts while preserving clarity.

Add surface-specific scrutiny only when the diff supplies evidence for it:

| Surface | Check |
|---|---|
| Customer-facing UI/CLI/report | Rendered behavior, key states, copy, keyboard/a11y, console, relevant viewport |
| Security/privacy/data loss | Trust boundary, authorization, secrets, injection, irreversible and recovery paths |
| API/schema/SQL/PostgreSQL | Compatibility, resource semantics, migration safety, generated output, actual dialect |
| Go/concurrency/workflows | Ownership, cancellation, errors, races, retries, idempotency |
| Dependency/external API | Current primary docs, version compatibility, lockfile, advisories |

### Classify

Every finding must be introduced by the diff; user-impacting or contract-breaking;
reproducible or supported by a concrete path; placed on the tightest changed line; and
paired with the smallest safe correction and verification command.

- **P0**: merge-blocking exposure, data loss, outage, impossible core flow, or missing
  required behavior.
- **P1**: normal-user defect, regression, broken contract/spec, false success, or major
  accessibility failure.
- **P2**: useful, bounded correction with lower impact.
- **P3**: optional future or polish; omit from inline comments by default.

No performance finding without measurement or a structural bound. No edge-case finding
without credible risk. A reasoned decline with evidence is valid.

### Synthesize

Deduplicate by root cause and keep the highest supported priority. Findings are the main
output; do not pad a clean review with praise. For a re-review, mark each previous finding
against the new tip as fixed, open, or no longer applicable.

## Deep mode

For `/review --deep` or a high-stakes release audit, use the same loop with a complete applicability ledger.
Add structural boundaries, security/dependency tooling, every
changed public surface, and exact verification evidence. Read
[DEEP-AUDIT.md](DEEP-AUDIT.md); do not add automatic agents, model panels, or skill chains.

## Output

Read [REFERENCE.md](REFERENCE.md) for priority vocabulary and the comment-ready schema.
Report the fixed point, diff command, mode, verification evidence or limits, findings as
`[P0|P1|P2] <file:line> <title> - <evidence, consequence, correction, verify command>`,
finding counts, and merge verdict.

If there are no findings, say so and list residual verification limits. Posting comments
requires explicit user intent; otherwise return comment-ready text only.
