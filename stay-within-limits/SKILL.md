---
name: stay-within-limits
description: Use when review, planning, or parallel agent work must route around Claude 5-hour and weekly usage limits without weakening required coverage.
---

# Stay Within Limits

Keep Claude review and planning inside both subscription windows. Use the exact Claude Code
statusline quota snapshot described in [REFERENCE.md](REFERENCE.md); `ccusage` is not
subscription-quota evidence and cannot select these bands.

## Review And Planning Profile

Before every Claude review/planning wave and between waves:

1. Run `select-review-profile.sh`.
2. Route from the higher of `five_hour.used_percentage` and
   `seven_day.used_percentage`.
3. Use one selected Claude profile for every hat in that wave:
   - `<20%`: Fable low.
   - `20-<50%`: Opus high.
   - `50-<75%`: Opus low.
   - `75-<90%`: Sonnet low.
   - `>=90%`: no Claude.
4. Missing, malformed, or stale quota snapshot means no Claude.
5. Always run the independent GPT-5.6 Sol xhigh check. If Claude is disabled, Sol owns all
   required hats; do not silently skip axes.

Use per-invocation Claude `model` and `effort`; reviewer and planning agent definitions
inherit so static frontmatter cannot override the selected profile. Let an in-flight wave
finish, then reroute the next wave from a fresh snapshot.

## Other Agent Waves

For long non-review fan-outs, default to at most 3 parallel subagents. Re-check the real
5-hour and 7-day windows between waves. At `>=90%`, stop new Claude work and prepare a
self-contained resume; use Sol only where the repo authorizes Codex.

## Separate Budgets

Codex and Claude are separate budgets. Claude usage never gates Codex. Codex review uses
GPT-5.6 Sol xhigh even when no Codex quota meter is available; do not infer Codex
subscription usage from `ccusage`, local tokens, session tokens, or Claude percentages.
Without a Codex meter, usage is unknown. Do not guess its reset time.
Native Codex runs required review/planning axes inline and never recursively invokes Codex.

## Resume

On resume, re-read the snapshot; do not trust elapsed wall-clock time. A resume handoff
names the remaining plan, last observed windows, exact selector command, next wave, verify
commands, and stop conditions.

## Reporting

Report the two observed percentages, selected maximum, Claude profile or disable reason,
and Sol xhigh status. When Claude is disabled, state which Sol pass covered each required
hat.
