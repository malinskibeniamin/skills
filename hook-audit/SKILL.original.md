---
name: hook-audit
description: Analyze hook effectiveness from collected session metrics. Use when user asks to audit hooks, invokes `/hook-audit`, or wants to identify silent, over-aggressive, or under-enforced hooks across sessions.
---

# Hook audit

## Step 0: Gather context

Run these Bash commands before proceeding:

- `ls "$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/"*.sh 2>/dev/null | wc -l` — installed hook scripts
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | wc -l` — session summaries collected
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | head -1 | xargs -I{} jq -r '.date' {}` — earliest date
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | tail -1 | xargs -I{} jq -r '.date' {}` — latest date

Metrics directory: `~/.claude/hook-metrics/`

## Your task

Analyze hook effectiveness across all collected session metrics. Read every JSON file in `~/.claude/hook-metrics/` and produce a report covering:

### 1. Hook activity

For each hook that fired at least once across all sessions:
- Total blocks, warns, and denies
- Average fires per session
- Trend: increasing or decreasing over time?

### 2. Silent hooks

List all hook scripts installed in `.claude/hooks/` that have **zero entries** in any metrics file. These are prune candidates — they either never trigger or aren't wired into the logging.

### 3. Over-aggressive hooks

Hooks with high block counts that may be hurting productivity:
- Blocks-per-session ratio > 3 → flag as potentially too strict
- If a hook blocks the same rule repeatedly in one session → agent is retrying and failing

### 4. Enforcement gaps

Cross-reference CLAUDE.md rules against hook activity:
- Rules that have corresponding hooks but zero fires → either perfectly followed or not tested
- Rules with no corresponding hook at all → advisory-only, no enforcement

### 5. Recommendations

Based on the data:
- **Prune**: hooks that never fire (remove or merge)
- **Soften**: hooks that block too aggressively (demote to warn)
- **Harden**: warns that fire frequently (promote to block)
- **Add**: CLAUDE.md rules with no hook enforcement

### Output format

Present as a structured report. Use tables where data supports it. End with a prioritized action list (max 5 items). If fewer than 5 session files exist, note that data is limited and recommendations are preliminary.
