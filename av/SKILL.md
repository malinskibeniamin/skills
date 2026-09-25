---
name: av
description: "Review whether a PR, plan, or ticket earns its engineering time: value lane, beneficiary, money-path risk, rollout, and design taste. Use for PR reviews, specs, tickets, and plans."
---

Review one axis: is this change worth its cost, for whom, and will it land safely? Time
is scarce; the bar is ship fast, fail fast, iterate in small increments. Judge stated or
inferable value, not effort or line count. Runs standalone or inline as the **av hat** in
`/review` and the product hat in `/grilling`; hat limit 300 words.

## 1. Pick one lane

Read the PR title, body, linked ticket, and diff. Assign one primary lane:

| Lane | Earns time by | Expected evidence |
|---|---|---|
| `ktlo` | Keeping the lights on, removing toil, saving money | What breaks, pages, or costs without it; toil or spend saved, ideally a number |
| `qol` | CI, DX, performance, UX papercuts, reputation | Who notices; a concrete repro or before/after measurement |
| `growth` | New capability, pricing, channel, customer ask; makes money | Named segment, deal, launch, or milestone; how it is used and billed; acceptance scenario |
| `taste` | Deletion, simplification, API/design shape, RFCs | What it deletes or unlocks; why now; reversal cost |

Trivial mechanical PRs (dependency bump, typo, generated sync) are `ktlo` and justified
without prose. Enabling work (an API for our own UI, a migration for a later feature)
takes the lane of the user-facing change it serves and must name it. When the lane is
inferable from the diff but unstated, say so once.

## 2. Test the lane's evidence

Mark the lane **justified**, **thin** (value plausible, evidence missing), or
**unjustified** (no beneficiary, no problem, or speculative generality). When thin, ask:

- `ktlo`: "What happens, and who pays, if we skip this?"
- `qol`: "Who feels this, and how will we see it improved?"
- `growth`: "Which customer or launch uses this first, and how does it make money?"
- `taste`: "What does this delete or make cheaper next?"

## 3. Check cross-cutting rules

Load the matching [RULES.md](RULES.md) sections:

- **Money paths** (metering, pricing, billing, credits, entitlements, suspension, deletion): always load Money.
- **Customer-visible** (UI, API, CLI, docs, errors, numbers): load Trust.
- **Rollout** (flags, migrations, breaking changes, defaults, enablement): load Delivery.
- **New surface or abstraction** (fields, options, services, configs): load Scope and Taste.

Apply S/A rules; flag B only on clear violation; mention C only in the summary.

## Severity

- **P1**: non-trivial change with no identifiable beneficiary or problem (`unjustified`);
  or a money-path risk: silent under/over-billing, lost billable usage, revenue or channel
  leak, unguarded destructive automation; or customer-facing numbers that can be false.
- **P2**: `thin` lane evidence with concrete consequence; S/A rule violation.
- **P3**: B/C nudges, cheaper wedges, follow-up ideas. Summary only.

Report at most three av findings; prefer the one that changes the merge decision.
Confirmed correctness bugs belong to `/review`'s core loop, not this axis.

## Output

Lead with one verdict line, always:

`av: <lane> -- <justified|thin|unjustified> -- <beneficiary and why, at most 20 words>`

Then findings as `[P1|P2|P3] <file:line or PR body> <rule-id> -- <consequence>; <smallest
fix or the question to answer>`. For plans and tickets, replace `file:line` with the
plan section and add missing acceptance criteria as scenarios
(`Given/When/Then` or "I ... / I see ..."). A clean pass is only the verdict line.
