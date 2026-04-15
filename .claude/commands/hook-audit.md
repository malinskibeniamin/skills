---
allowed-tools: Bash(ls *), Bash(cat *), Bash(jq *), Bash(wc *), Bash(sort *), Bash(head *), Bash(find *)
description: Analyze hook effectiveness from collected session metrics
---

## Context

- Metrics directory: `~/.claude/hook-metrics/`
- Hook scripts: !`ls "$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' '` hook scripts installed
- Metrics files: !`ls ~/.claude/hook-metrics/*.json 2>/dev/null | wc -l | tr -d ' '` session summaries collected
- Date range: !`ls ~/.claude/hook-metrics/*.json 2>/dev/null | head -1 | xargs -I{} jq -r '.date' {} 2>/dev/null` to !`ls ~/.claude/hook-metrics/*.json 2>/dev/null | tail -1 | xargs -I{} jq -r '.date' {} 2>/dev/null`

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
