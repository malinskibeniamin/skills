---
name: stay-within-limits
description: Use when taste, implementation, review, planning, or parallel agent work must route around Claude 5-hour and weekly usage limits without weakening required coverage.
---

# Stay Within Limits

Keep Claude work inside both subscription windows. Use the exact Claude Code statusline
quota snapshot described in [REFERENCE.md](REFERENCE.md). `ccusage` reconstructs Claude-local
token/cost history, not subscription-quota evidence, and cannot select bands.

## Taste Profile

Before every Claude taste/review/planning wave and between waves:

1. Run `select-review-profile.sh`.
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
5. Plan gates retain the independent Sol xhigh check. Opus-authored work gets a fresh Sol
   high adversarial review. Sol implementation gets Opus 5 xhigh feedback as a required
   review lane. If Claude is disabled, use Sol xhigh only and let a clean-context pass own
   every required hat; do not silently skip axes.

Use per-invocation Claude `model` and `effort`; reviewer and planning agent definitions
inherit so static frontmatter cannot override the selected profile. Let an in-flight wave
finish, then reroute the next wave from a fresh snapshot.

## Implementation Profile

When Claude is enabled, actual implementation pairs Opus 5 xhigh with GPT-5.6 Sol xhigh.
Use isolated or non-overlapping lanes and integrate centrally; never let both edit the same
files concurrently. When Claude is unavailable or above 95%, use Sol xhigh only.

## Other Agent Waves

For long non-review fan-outs, default to at most 3 parallel subagents. Re-check the real
5-hour and 7-day windows between waves. Above `95%`, stop new Claude work and prepare a
self-contained resume; use Sol only where the repo authorizes Codex.

## Separate Budgets

Codex and Claude are separate budgets. Claude usage never gates Codex. Codex implementation
uses Sol xhigh; Opus-work adversarial review uses Sol high; Sol implementation gets Opus 5
xhigh feedback while Claude is enabled. Do not infer Codex subscription usage from `ccusage`,
local tokens, session tokens, or Claude percentages.
Without a Codex meter, usage is unknown. Do not guess its reset time.
Native Codex runs required review/planning axes inline and never recursively invokes Codex.

## Resume

On resume, re-read the snapshot; do not trust elapsed wall-clock time. A resume handoff
names the remaining plan, last observed windows, exact selector command, next wave, verify
commands, and stop conditions.

## Reporting

Report the two observed percentages, selected maximum, taste profile, implementation pair,
reciprocal review status (Sol high on Opus work and Opus 5 xhigh on Sol implementation), or
disable reason. When Claude is disabled, state which clean-context Sol xhigh pass covered
each required hat.
