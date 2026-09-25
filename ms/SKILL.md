---
name: ms
description: "Review whether a PR, plan, or ticket earns its time: one lane, a named beneficiary, cost or revenue path, acceptance criteria, and a small reversible slice."
---

Review one axis: is this change worth shipping now, for whom, and is it the smallest
reversible slice that proves it. Rules live in [RULES.md](RULES.md).

Run standalone on a PR, branch, plan, or ticket, or inline as the **ms hat** in `/review`
on every PR review. Spawns no agents.

## Lanes

Every PR serves one lane. Read the PR body `Lane:` line; infer it when missing.

| Lane | Earns time when | Demand |
|---|---|---|
| Keep the lights on | it removes toil, risk, or spend | the incident, alert, or cost it removes; rollback |
| Quality of life | it unblocks people or protects reputation | before/after number or failing reproduction; who feels it |
| New value | a named segment gets closer to paying or staying | beneficiary, revenue path, smallest shippable slice, default-off launch |
| Taste | it avoids a costly one-way door or removes a concept | future cost avoided; why now is cheaper than later |

Split mixed lanes unless one change strictly enables the other.

## Procedure

1. **Scope:** PR title and body, linked ticket, commits, diff. Trust the diff over claims.
2. **Classify:** lane plus surfaces: money path, customer-facing, contract/API, operations,
   docs, CI or dev loop, agent platform.
3. **Ask:** Who hits this today and what does it cost them? What proves done, observably?
   What is the smallest reversible slice, and what is deliberately out?
4. **Load:** matching [RULES.md](RULES.md) sections. Apply S/A rules, clear B violations,
   and only plain C violations.
5. **Rate revenue likelihood:** High, Medium, Low, or None with one reason. None is fine for
   maintenance, quality of life, or taste when their evidence exists. Unknown stays unknown;
   never invent figures.

## Severity

- **P1:** false success, health, or price; unknown usage billed as free; free users locked
  out or wrongly gated; customer data beyond expectation; contract break without rollout.
- **P2:** no beneficiary or lane; mixed lanes; unmeasured performance or CI claim;
  speculative generality; no observable done-when; docs contradict behavior.
- **P3:** wording, naming, or an obvious lane left undeclared.

Value findings never block a confirmed correctness or security fix.

## Exclude

- Correctness, security, and style owned by other `/review` hats.
- Strategy vetoes: question fit and name the missing evidence; the owner decides.
- Generated files.

## Output

`Lane: <lane> | Beneficiary: <who> | Revenue likelihood: <level> - <reason>`, then
`[P1|P2|P3] <rule-id> <file:line or PR body> <missing evidence> - <smallest fix>`.
Hat limit 250 words. If clean:
`APPROVED -- <lane>, <beneficiary>, value evidenced.`
