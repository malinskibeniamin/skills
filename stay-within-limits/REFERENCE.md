# Claude Quota Snapshot

Claude Code exposes exact subscription usage to statusline commands:

- `rate_limits.five_hour.used_percentage`
- `rate_limits.seven_day.used_percentage`

The fields appear after the session's first API response for Claude.ai subscribers. Cache
them locally so an explicitly authorized agent wave can check capacity without guessing.

## One-Time Setup

Copy `capture-rate-limits.sh` to a stable user path:

```bash
cp <plugin-or-repo>/stay-within-limits/capture-rate-limits.sh \
  ~/.claude/capture-rate-limits.sh
chmod +x ~/.claude/capture-rate-limits.sh
```

In the statusline script, immediately after reading stdin into `input`, add:

```bash
printf '%s' "$input" | "$HOME/.claude/capture-rate-limits.sh" || true
```

Keep the statusline's existing output unchanged. The capture helper writes
`~/.claude/rate-limits.json` atomically with mode `0600`. Override that path with
`CLAUDE_RATE_LIMIT_SNAPSHOT` when needed.

Example:

```bash
input="$(cat)"
printf '%s' "$input" | "$HOME/.claude/capture-rate-limits.sh" || true
# existing statusline rendering follows
```

## Read capacity

Run before an explicitly authorized Claude wave:

```bash
<plugin-or-repo>/stay-within-limits/select-review-profile.sh
```

The JSON reports `claude_capacity`, `claude_eligible`, both observed percentages, their
maximum, and a reason when unavailable. It never selects a model or effort. Missing,
malformed, or stale data is `unknown`; above 95% is `exhausted`. The default freshness
window is 120 seconds; override with `CLAUDE_RATE_LIMIT_MAX_AGE`.

Use `config/model-routing.json` for model selection after capacity removes unavailable
routes. Capacity never lowers the quality gate.

Do not substitute `ccusage`: it reconstructs local token/cost history, not the live
subscription quota percentages.
