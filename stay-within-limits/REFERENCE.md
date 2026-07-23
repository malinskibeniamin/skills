# Claude Quota Snapshot

Claude Code exposes exact subscription usage to statusline commands:

- `rate_limits.five_hour.used_percentage`
- `rate_limits.seven_day.used_percentage`

The fields appear after the session's first API response for Claude.ai subscribers. Cache
them locally so review and planning workflows can read them without guessing.

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

## Select A Profile

Run before every review/planning wave:

```bash
<plugin-or-repo>/stay-within-limits/select-review-profile.sh
```

The JSON result always includes `codex_model: "gpt-5.6-sol"` and
`codex_effort: "xhigh"`. A fresh valid snapshot also includes the selected Claude model and
effort. The default freshness window is 120 seconds; override with
`CLAUDE_RATE_LIMIT_MAX_AGE`.

Do not substitute `ccusage`: it reconstructs local token/cost history, not the live
subscription quota percentages.
