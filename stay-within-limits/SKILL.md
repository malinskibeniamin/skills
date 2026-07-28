---
name: stay-within-limits
description: Route taste, implementation, review, planning, and agent waves around Claude 5-hour and weekly limits. Use when budgeting or selecting models without weakening required coverage.
---

# Stay Within Limits

Keep Claude work inside both subscription windows. Use the exact Claude Code statusline
quota snapshot described in [REFERENCE.md](REFERENCE.md). `ccusage` reconstructs Claude-local
token/cost history, not subscription-quota evidence, and cannot select bands.

## Taste Profile

Before every Claude taste/review/planning wave and between waves. Inspect both
`five_hour` and `seven_day` quota windows:

1. Run the selector adjacent to this skill. In this repository:
   `bash stay-within-limits/select-review-profile.sh`.
2. Route from the higher of `five_hour.used_percentage` and
   `seven_day.used_percentage`.
3. Use the selected Claude taste profile for every hat in that wave:
   - `0-20%`: Fable high.
   - `21-35%`: Fable medium.
   - `36-50%`: Fable low.
   - `51-75%`: Opus 5 xhigh.
   - `76-90%`: Opus 5 medium.
   - `91-95%`: Opus 5 low.
   - `96-100%`: no Claude.
4. Missing, malformed, or stale quota snapshot means no Claude.
5. Run planning and review axes inline. Non-trivial PR/ship work may add one bounded,
   foreground Sol high adversarial pass against Claude-authored work.

Use the selected Claude `model` and `effort` for inline taste work. Agent waves require
explicit delegation; reroute each authorized wave from a fresh snapshot.

## Implementation Profile

Implementation has one primary owner. The selector's `primary_model` is Opus 5 xhigh when
Claude is enabled and in budget; otherwise it is Sol xhigh only. Do not create a second
implementation or feedback lane automatically.

## Other Agent Waves

Do not start agent waves without explicit delegation or `/swarm`. For an authorized wave,
cap at 3 parallel subagents and re-check both windows between waves.

## Separate Budgets

Codex and Claude are separate budgets. Claude usage never gates Codex. Codex implementation
uses Sol xhigh; the one permitted foreground review of Claude work uses Sol high. Do not infer
Codex subscription usage from `ccusage`, local tokens, session tokens, or Claude percentages.
Without a Codex meter, usage is unknown. Do not guess its reset time.
Native Codex runs required review/planning axes inline and never recursively invokes Codex.

## Resume

On resume, re-read the snapshot; do not trust elapsed wall-clock time. A resume handoff
names the remaining plan, last observed windows, exact selector command, next wave, verify
commands, and stop conditions.

## Reporting

Report the two observed percentages, selected maximum, primary owner, foreground review
status, or disable reason.
