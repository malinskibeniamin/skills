# Review reference

Detailed output rules for `/review`. The skill owns the evidence loop; this file keeps the
priority vocabulary, smell baseline, and comment shape out of the default context.

## Priority and comment policy

Use one priority label on every finding:

| Label | Meaning | Merge rule |
|---|---|---|
| P0 Blocker | Security/privacy exposure, data loss, outage, impossible core flow, or entirely missing required behavior | Block |
| P1 Major | Normal-user defect, regression, broken contract/spec, false success, or major accessibility failure | Block unless owner overrides |
| P2 Minor | Clear contained lower-impact defect or test gap | Fix or track |
| P3 Future | Optional polish or later cleanup | Summary only by default |

A reproduced normal-user bug is at least P1. Do not lower priority because the correction
is small. Place a comment on the tightest changed line that introduces the defect; when no
accurate inline location exists, return a top-level comment-ready item and explain why.

Post only when explicitly requested. Resolve the target in this order: explicit PR URL or
number, open PR for the current branch, then comment-ready output. Never post while still
investigating or dump the entire review into a PR.

## Comment shape

```md
[P1 Major] <short title>
What: <the defect and concrete execution path>
Why: <user or contract consequence>
Suggested fix: <smallest safe correction>
Verify: <exact command or real-entrypoint replay>
```

## Fowler smell baseline

Use this as judgment support for semantic density, not a quota. A documented repository
standard always wins; skip anything deterministic tooling already owns.

- **Mysterious Name**: the name does not reveal the role.
- **Duplicated Code**: the same real logic exists in multiple places.
- **Feature Envy**: behavior reaches into another object more than its own data.
- **Data Clumps**: the same related fields travel together repeatedly.
- **Primitive Obsession**: a primitive stands in for a domain concept.
- **Repeated Switches**: the same type decision is scattered.
- **Shotgun Surgery**: one logical change requires unrelated edits across modules.
- **Divergent Change**: one module changes for unrelated reasons.
- **Speculative Generality**: abstraction or options exist for unproven needs.
- **Message Chains**: a caller walks deep object structure.
- **Middle Man**: a wrapper mostly delegates without adding a contract.
- **Refused Bequest**: a subtype does not honor the inherited contract.

## Report schema

```md
## Review
Fixed point: <commit>
Diff: `git diff <fixed>...HEAD`
Mode: standard | deep
Applicability: <changed surfaces and evidence checked>
Verification: <commands, real-entrypoint replay, and exact limits>

## Findings
- [P0|P1|P2] <file:line> <title>
  Evidence: <reproduction or concrete path>
  Consequence: <user or contract impact>
  Correction: <smallest safe fix>
  Verify: <command or replay>

## Summary
Counts: <P0/P1/P2>
Verdict: approve | changes required | blocked by missing evidence
Residual limits: <unverified external behavior or none>
```

## Example inline comment

```md
[P1 Major] Save reports success before refresh
What: The handler resolves before list invalidation, so navigation can show stale data.
Why: A normal user can believe the saved change was lost.
Suggested fix: Await invalidation before the success state.
Verify: `bun test src/items/save.test.ts`
```
