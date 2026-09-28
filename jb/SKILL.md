---
name: jb
description: "Review or draft whether a PR, plan, or ticket earns its time and lands well: value lane, a caller blocked today, falsifiable done, reversible rollout, craft, and taste. Use for PRs and plans."
---

Review one axis: does this change serve a real caller now, prove it works where users run
it, and land reversibly? Time is scarce; ship fast, fail fast, iterate in small slices.
Runs standalone or inline as the **jb hat** in `/review` (300 words); code defects stay there.

Default to approve. Block only on the P1 list, never on nits, effort, or diff size.

## 1. Pick one lane

Read the PR title, body, ticket, and diff. Assign one primary lane:

| Lane | Earns time by | Expected evidence |
|---|---|---|
| `ktlo` | Keeping the lights on, removing toil, saving money | The incident, failure, or spend it removes; a before/after number when one exists |
| `qol` | CI, DX, performance, reliability polish, reputation | Whose loop gets shorter or which user pain goes away, measured |
| `growth` | New capability a customer, deal, or launch pulls for; makes money | The caller blocked today, what they can do after merge, the gate, the acceptance scenario |
| `taste` | Deleting, unifying, or generating so the next change is cheap | What it deletes or makes impossible, and the next consumer it unblocks |

Mechanical PRs (bumps, generated sync, reverts) are justified `ktlo`. Enabling work takes
the lane it serves. Unrelated lanes are a split request. Compare with RULES.md **Lanes**.

## 2. Test the lane's evidence

Mark it **justified** only when the PR, ticket, or diff names the concrete problem or caller;
value you must infer is **thin**. **Unjustified**: no beneficiary, no problem, or speculative
generality. A named beneficiary never justifies silently overriding what the caller asked
for (model, identity, region, value) or leaving the standard contract; that is thin at best. Ask:

- `ktlo`: "What breaks, pages, or costs money if we skip this?"
- `qol`: "Whose loop gets shorter, and how will we see it?"
- `growth`: "Which caller is blocked today, and what can they do once this merges?"
- `taste`: "What does this delete, and what does it make cheaper next?"

## 3. Check cross-cutting rules

Load the matching [RULES.md](RULES.md) sections; apply S/A, flag B only on clear
violation, mention C only in the summary:

- **Always**: Scope, Evidence, approve and owner-decision lists.
- **Rollout** (flags, migrations, defaults, deploys, public API): Delivery.
- **Consumed output** (API, UI, CLI, tool result, error, metric): Contracts.
- **New surface or abstraction** (field, option, mode, service, generator): Taste.
- **Spend** (tokens, compute, CI minutes, quota, toil): Cost.

## 4. Check craft

Load [CRAFT.md](CRAFT.md): Ship and Verify always; Code for Go, proto, or SQL; Review
voice for comments. Craft findings cap at P2. When authoring, apply them to the draft first.

## Severity

- **P1**: non-trivial change with no identifiable beneficiary or problem (`unjustified`);
  speculative scope: a field, option, abstraction, service, or mode with no caller today;
  a `growth` or risky change with no falsifiable acceptance criterion or verification path;
  a one-way door with no flag, rollback, or recorded owner decision.
- **P2**: `thin` lane evidence with a concrete consequence; S/A rule violation. Default-off,
  opt-in, or dev-only additions drop evidence gaps to P3.
- **P3**: B/C nudges, cheaper slices, follow-ups; summary only.

At most three findings, merge-deciding first. Escalations name the scenario and decision.

## Output

Always lead with one verdict line:

`jb: <lane> -- <justified|thin|unjustified> -- <beneficiary and evidence, at most 20 words>`

Then `[P1|P2|P3] <file:line or PR body> <rule-id> -- <consequence>; <smallest fix>`. For
plans, cite the section and write missing criteria as falsifiable scenarios. Clean pass: the verdict line only.
