---
name: mm
description: Judge whether a PR, plan, or ticket earns its cost: lane, user, evidence, acceptance, rollout.
---

# mm

Review one axis: is this change worth our limited time, now, in this shape? Runs as the
**value hat** on every `/review` and PR-review routine; standalone for plans, RFCs, and
tickets. Do not edit, commit, or post. Other hats own code correctness; this hat owns
"should we ship this, and is it proven?"

Bias: ship fast, fail fast, iterate in small gains. Block only waste, unproven risk, or
silent harm; never slow a cheap reversible bet.

## Inputs

Read the PR title, body, linked tickets and RFCs, commit messages, diff stat, and changed
public surfaces (API, proto, config, flags, UI, CLI, CI, dependencies). Treat the body as a
claim; confirm it against the diff.

## 1. Classify the lane

Pick exactly one primary lane. Say `declared` when the PR states it, `inferred` otherwise.

| Lane | Payoff | Evidence that earns it |
|---|---|---|
| **Keep the lights on** | saves money, prevents incident or data loss, unblocks a dependent | the consequence today, a reproduction that fails before the fix, or a cost delta |
| **Quality of life** | faster CI/dev loop, perf unlock, reliability; reputation | before/after measurement on the path users or developers actually hit |
| **New capability** | makes money | a named user or buyer, the problem, why us, and how we will know it worked |
| **Design taste** | the next change gets cheaper | the specific change it unblocks or the surface it deletes |

Mixed PRs: classify by the largest user-visible effect, and flag the rest under rule V8.

## 2. Rate the bet

- **Payoff**: money saved, reputation, revenue, or cheaper next change; one line in user terms.
- **Revenue likelihood** (new capability only): `high` = named customer, deal, design
  partner, or compliance requirement; `medium` = credible persona plus a gap no competitor
  closes; `low` = neither. Never invent customers; mark assumptions as assumptions.
- **Confidence**: what evidence exists versus what the PR asserts.

## 3. Apply the checks

Load [RULES.md](RULES.md) and walk V1-V16 against the PR. Each rule lists its question,
the evidence that satisfies it, and the finding it produces. Lane emphasis:

- Keep the lights on: V2, V5, V9, V10, V12.
- Quality of life: V5, V6, V12, V13.
- New capability: V1, V3, V4, V9, V11, V14.
- Design taste: V6, V7, V8, V15.

Respect recorded product decisions (tickets, RFCs, stakeholder asks); challenge them only
with new evidence. Experiments and drafts labeled as such are judged against their stated
learning goal, not merge readiness.

## 4. Classify findings

- **P1**: irreversible or customer-visible change with no gate, compatibility path, or
  rollback; correctness traded for convenience; new API, service, dependency, or config
  surface with no user; cost increase with no stated benefit.
- **P2**: missing why, acceptance criteria, or measurement for a claim; speculative knob or
  abstraction; unrelated change bundled; follow-up gap neither fixed nor tracked.
- **q**: a genuine necessity question ("Why do we need this?") the author can answer in one line.

At most five findings, highest payoff first. No nits, no praise, no restating the diff.
Silence on a check means it passed.

## Output

```
mm: <lane> (<declared|inferred>) | payoff <one line> | revenue <high|medium|low|n/a> | confidence <high|medium|low>
verdict: ship | ship after fixes | rethink scope | not now
- [P1|P2|q] <file:line or PR body> V<n>: <problem>. <smallest fix>.
```

Clean: `mm: <lane> | <payoff> | verdict: ship` and nothing else. In `/review`, append the
findings to the review with their `V<n>` ids; the review verdict owns merge.
