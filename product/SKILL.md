---
name: product
description: "Keep work on track to business value: one lane, beneficiary, why now, evidence, reachability, smallest reversible slice. Use on every PR, plan, auto-review, or drift check."
---

For a material product or design fork, read the [Poteto adaptation](../shared/POTETO-NATIVE.md#product-and-planning).

Check value/reach. Correctness: `/review`; truth: `/lie-detector`. Apply the **product hat** inline in `/review`, `/grilling` and auto-review, or standalone. [RULES.md](RULES.md) grades independent evidence sets; [CRAFT.md](CRAFT.md) owns author practice.
Read the [two-kind contract](../shared/review-contract.md) for scope/direction advice.

## Lanes

Every change serves one primary lane. Mixed purposes split into separate PRs.

| Lane | Earns its time by | Evidence that counts |
| --- | --- | --- |
| Keep the lights on | Saving money or preventing loss: failures, idle cost, toil, dead surface, billing and upgrade paths | Incident or repro, dollars, hours of toil, verified fix |
| Quality of life | Speed and reputation: CI and dev loop, latency, actionable errors, docs that run, flakes | Before and after numbers, who is unblocked, how often |
| Feature | Making money: a named buyer, segment, launch, or demo can do something new | Named demand, a reachable surface, an adoption signal |
| Taste | Keeping the next change cheap: one source of truth, paved paths, class guards, deletion | Drift or carrying cost it already caused, a second caller |

## Modes

| Mode | When | Output |
| --- | --- | --- |
| Plan | Issue, spec, or plan before code; the `/grilling` product hat | Verdict, Given/When/Then acceptance, cheapest disproof, slice plan |
| Author | Writing a PR, including `/commit-push-pr` | The `Lane:` line and a body that answers the reviewer ([CRAFT.md](CRAFT.md)) |
| Review | `/review`, auto-review routine, explicit ask | Verdict line and at most three findings |
| Track | A long branch, a stack, or work that keeps growing | `on track`, `drifting`, or `park`, with the scope to cut |

## Procedure

1. **Intent:** read the plan or PR body, linked issue, commits, and full diff; never trust
   a summary over code. Record the declared lane (`Lane:` line), or infer it and say so.
2. **Beneficiary:** name the role and what changes for them. "Users" or "cleanup" alone is
   not a beneficiary.
3. **Why now:** find the trigger (incident, customer ask, launch, deal, cost spike,
   measured regression, blocked consumer). None means the work competes with the roadmap.
4. **Evidence:** measured > reproduced > named > asserted. Performance, cost, and
   reliability claims need numbers; a disproved hypothesis closes the work.
5. **Reach:** trace the value to a surface the beneficiary uses today: UI, API, CLI, docs,
   a flag that is on somewhere. Merged but unreachable earns nothing yet.
6. **Cost to own:** run cost, new surface, dependencies, on-call load, and review time,
   against the simplest alternative.
7. **Slice and safety:** smallest independently useful slice, default off with a rollback,
   live consumers protected, one-way doors left to their owner.
8. **Rules:** RULES.md Justification, Scope, and Evidence always; the lane's section; and
   Delivery, Trust, or Money when the diff touches rollout, customer-visible output, or
   billing. Load CRAFT.md for non-generated source or test changes. Enforce S and A;
   apply B when the diff plainly matches; C only when asked.

Track mode compares the branch with its stated outcome: work outside the lane is
`drifting` (name the cut or the follow-up PR); value that cannot land yet is `park`
(name the reopen condition).

## Verdicts and severity

- **justified**: every step answered with evidence. Approve quietly.
- **thin**: real value, but evidence, acceptance, reach, or rollout is missing; ship after
  the named fix.
- **unjustified**: no beneficiary or trigger, speculative surface, or cost above payoff;
  rethink the scope or park it with a reopen condition.

- **P1 Value**: false success or a silent no-op; a lost or double charge; a live-path break
  with no off switch; a one-way door taken without its owner; a public claim that is not
  true.
- **P2 Value**: missing beneficiary, trigger, evidence, acceptance, or rollout; speculative
  surface; mixed lanes.
- **P3**: a nudge; automation never posts it.

Never block on taste alone. Grade sets how firmly a rule applies; severity comes only from
this list.

## Automated review

Silence means the value case is clear: a **justified** change gets only the verdict line.
Otherwise post one top-level Value comment with at most three P1 or P2 findings, each with
its rule id, consequence, and smallest fix. Never restate the PR. Value-only findings
comment and never request changes; the owner decides. Judge bot findings on merit.

## Output

```
product: <ktlo|qol|feature|taste> (<declared|inferred>) -- <justified|thin|unjustified> -- <beneficiary>; trigger: <why now>; evidence: <strongest proof>
- [P1|P2 Value] <rule id> <gap> - <consequence> - <smallest fix>
```

Plan mode adds the acceptance scenarios and the cheapest disproof. Track mode puts
`on track`, `drifting`, or `park` in the verdict slot.
Name what the review could not verify and who should make the final call.
