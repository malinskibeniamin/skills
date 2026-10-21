# Review reference

Detailed output rules for `/review`. The skill owns the evidence loop; this file keeps the
priority vocabulary, smell baseline, and comment shape out of the default context.

## Source snapshots and mutation tests

- Freeze the reviewed head and merge-base as full SHAs; use their diff and matching
  source, not moving branch names. A PR review uses the supplied PR head, not an
  unrelated local checkout. Record dirty exclusions for committed-only reviews.
- WIP reviews also freeze the staged/unstaged patch and selected untracked inputs.
  Capture a reproducible manifest or fingerprints; avoid ignored credentials and
  unrelated work. A dirty filename cannot establish defect provenance: compare
  the failing behavior/hunk with the original baseline.
- Mutation testing changes a disposable, reviewer-owned snapshot only. Allocate a
  unique empty directory, add a detached worktree at the frozen head, and apply
  only the captured WIP delta when applicable. Use absolute bundled guidance
  paths. Keep the original checkout's files, index, and branch untouched.
- Run the test once on the snapshot, then change the behavior it claims to protect
  there and rerun it. Assertion failure is RED; setup/import failure is not.
  Preserve evidence, then remove only the worktree you created. Never reuse or
  force-remove an existing worktree, stash/reset the original, or restore its files.
- A worktree isolates edits, not executable code. Untrusted builds/tests need a
  restrictive execution sandbox without production credentials or services. If
  unavailable, inspect source and report the runtime evidence gap; do not run
  untrusted repository commands on the host to complete a review.
- Recheck head/base and WIP fingerprints before reporting. Drift requires a new
  snapshot and replay of affected evidence, not approval of a different candidate.

These are review instructions, not an automatic sandbox. Hook-schema tests do not
prove a model followed them; model adherence needs a separate behavioral trial.
## Gate coverage

For requested multi-gate coverage, an opted-in consumer, or an existing gate plan,
follow [review gates](GATES.md) before returning the receipt. Keep source read-only;
local review artifacts go in ignored scratch. Gate preparation grants neither
delegation nor publication permission. Ordinary reviews remain inline.

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
[P1 Major] <specific defect>
<Concrete execution path and consequence>. <Smallest safe correction>.
Verify: <exact command or real-entrypoint replay>
```

Use labels only when they improve scanning. Do not repeat the changed code, add praise,
or explain the review process.
For authorized delegated reviews, recheck serious claims against the frozen source.
Retain fixed, rejected, duplicate, or blocked dispositions with proof. Missing or
skipped lanes remain explicit; agreement between reviewers is not verification.

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
## Findings
- [P0|P1|P2] <file:line> <title>
  Evidence: <reproduction or concrete path>
  Consequence: <user or contract impact>
  Correction: <smallest safe fix>
  Verify: <command or replay>

## Receipt
Fixed point: <commit> | Mode: standard | deep
Verification: <commands and real-entrypoint replay>
Counts: <P0/P1/P2>
Value: product: <ktlo|qol|feature|taste> -- <justified|thin|unjustified> -- <beneficiary, trigger, evidence>
Truth: lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence>
Verdict: approve | changes required | blocked by missing evidence
Residual limits: <unverified external behavior or none>
```

## Example inline comment

```md
[P1 Major] Save reports success before refresh
The handler resolves before list invalidation, so navigation can show stale data and make
the saved change appear lost. Await invalidation before the success state.
Verify: `bun test src/items/save.test.ts`
```
