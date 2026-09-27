# Author playbook

Load when writing a change, not when reviewing one. Rules live in [RULES.md](RULES.md);
this file is the working rhythm behind them.

## Choose the work

1. Unblock before polishing: red main, flaky gates, broken onboarding, and slow local loops
   come before new surface, because they tax everyone at once.
2. Give every idea one of three outcomes: build the smallest slice, park it with a reopen
   condition, or point at the existing feature that already solves it.
3. Keep a share of time for multiplier work: CI speed, dev loop, dashboards, and docs
   verified against code. Record the before/after number.
4. Time-box low-value work out loud: "Beyond this change I will not spend more time; reject
   it if it is not worth it."

## Shape the change

| Size (changed lines) | Target time to merge | Typical content |
|---:|---:|---|
| under 50 | about 1 hour | fix, config, copy, dependency bump |
| 50-200 | a few hours | one behavior with its test |
| 200-800 | same day | a feature slice behind a default-off switch |
| over 800 | a planned series | scaffold, generated code, or step n of N |

- Aim for several small PRs a week, not one large one.
- Plan large work as "PR n of N" landing on main with zero behavior change each step,
  with Deferred and Up next sections. Reach for dependent-branch stacks only when a step
  cannot land alone.
- Split by blast radius: anything global (retry policy, shared layout, auth) ships alone.

## Write the PR body

Answer the reviewer before they ask; most well-written PRs need no review thread.

```md
## Why
<who hits this today and what it costs them>

## What
<the change in 1-3 bullets; the shape if bullets hide it>

## Verification
<command or real-entrypoint replay; failing on base, passing here; numbers>

## Rollout
<per environment; default state; rollback in one line>

## Worth reviewing
- Riskiest hunk: <file or hunk to push back on, and the assumption behind it>

## Not fixed here
- <adjacent problem found and deliberately left, with where it goes next>
```

## Test and verify

1. Reproduce first. Shrink the trigger until it runs in milliseconds.
2. Test through the real wiring with production-shaped fixtures; add round-trip checks for
   new fields.
3. After the fix, ask: which check makes this class impossible? Add the startup assertion,
   lint rule, drift test, or shared constant.
4. Measure performance claims on real traces and name the next bottleneck.

## Flake protocol

1. Pull recent run history and compute the flake rate for the gate.
2. Rerun per test so the report names the flaky test instead of retrying the whole job.
3. Fix the root cause, or remove the assertion and say why; never hide the signal.
4. Revert a fix attempt that does not move the rate.
5. Watch the gate for a week after merge and report the new rate.

## Review others

- Approve quickly when the change is sound; most approvals need no comment.
- Ask questions ("does this need to exist?", "how many callers apply this today?") and use
  suggestion blocks so the fix is one click. Leave style to formatters.
- Block only for contract, security, money, or release-safety breaks, and say what unblocks.
- Itemize replies to your own reviews: fixed with the commit, or declined with the reason.

## Work with AI

- Read every generated diff before it becomes a PR; close unreviewed agent PRs.
- Ask the model to argue against your change, then act on the answer, including closing it.
- Keep agent context lean: keep a line only if removing it would cause a mistake; move
  specialist guidance into skills.
- Question conventions the model invented before following them.
