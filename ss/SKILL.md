---
name: ss
description: "Review whether a change is worth our limited time: value bucket, beneficiary, evidence, reachability, cost, and slice size. Use on every PR review, auto-review routine, or work plan."
---

Review one axis: is this the right work, at the right size, now? Correctness stays with
`/review`; this lens asks who benefits, how we know, and what it costs to own.
[RULES.md](RULES.md) carries every rule with its grade and recency-weighted support.

## Buckets

Every PR serves exactly one primary bucket. Mixed purposes split into separate PRs.

| Bucket | Claim | Evidence that justifies it |
| --- | --- | --- |
| Keep the lights on | Saves money, removes toil or risk | Incident, alert, finding, deprecation date, dollars, hours of toil |
| Quality of life | CI, DX, performance, reputation | Measured before and after, who is unblocked, how often |
| Feature | Makes money | Named customer, prospect, segment, launch, or demo; revenue path |
| Design bet | Taste that keeps the future cheap | Fewer concepts, deleted surface, reversible slice, keep or kill signal |

## Procedure

1. **Read intent:** PR body, linked ticket, commits, diff stats. Record the claimed bucket;
   if absent, infer it and flag the missing claim.
2. **Beneficiary:** name the persona or customer and what changes for them. "Users" or
   "cleanup" alone is not a beneficiary.
3. **Why now:** find the trigger (incident, customer ask, launch date, deal, cost spike,
   measured regression). No trigger means the work competes with the roadmap; say so.
4. **Evidence grade:** measured > named > plausible > asserted. Performance, cost, and
   reliability claims need numbers; a disproved hypothesis closes the PR.
5. **Reachability:** trace the value to a surface the beneficiary can use today: UI, API,
   CLI, docs, a flag that is on somewhere. Merged but unreachable earns nothing yet.
6. **Cost to own:** run cost in dollars, new infra, config surface, flags, on-call load,
   review load. Deletions and simplifications count as value.
7. **Slice:** smallest reversible increment that proves the claim; default off; follow-ups
   ticketed, not folded in; existing paying customers protected by construction.
8. **Apply rules:** check the RULES.md entries that match the bucket and surface.

## Verdict

- **justified**: bucket, beneficiary, and evidence line up; slice is proportionate.
- **needs justification**: likely valuable but the PR does not show it. Ask for the one
  missing fact (beneficiary, trigger, number, or AC), not an essay.
- **unlikely to pay off**: no beneficiary, no trigger, cost exceeds a plausible return, or
  an unmeasured claim is the only reason. Recommend defer, shrink, or close.

Never block on taste alone. Value is decided by the owner; this lens makes the trade
visible. A deadline can justify a rough slice when the PR names the follow-up.

## Severity

- **P1 Value**: merging likely loses money or trust: billing leak or double charge,
  configured-but-inert paid or security feature, breaking change for existing customers,
  revenue or pricing change without product sign-off, one-way door for a speculative need.
- **P2 Value**: missing beneficiary, trigger, evidence, AC, or reachability; oversized or
  mixed PR; new standing cost without a dollar figure; generality with a single user.
- **P3**: wording or ticket hygiene. Summary only.

## Automated review

In an auto-review routine: post one top-level Value comment only when the verdict is not
**justified**, at most three findings, each with the missing fact and a one-line fix.
Silence means the value case is clear. Never restate the PR back to the author.

## Output

```md
Value: <bucket> | Beneficiary: <who> | Trigger: <why now> | Evidence: <grade>
Verdict: justified | needs justification | unlikely to pay off
- [P1|P2 Value] <rule id> <gap> - <consequence> - <smallest fix>
```

Hat limit 250 words. A clean result is the first two lines only.
