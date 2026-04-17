---
name: hook-audit
description: Analyze hook effectiveness from collected session metrics. Use when user asks to audit hooks, invokes `/hook-audit`, or wants to identify silent, over-aggressive, or under-enforced hooks across sessions.
---

# Hook audit

## Step 0: Gather context

Run Bash commands before proceed:

- `ls "$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/"*.sh 2>/dev/null | wc -l` — installed hook scripts
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | wc -l` — session summaries collected
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | head -1 | xargs -I{} jq -r '.date' {}` — earliest date
- `ls ~/.claude/hook-metrics/*.json 2>/dev/null | tail -1 | xargs -I{} jq -r '.date' {}` — latest date

Metrics dir: `~/.claude/hook-metrics/`

## Your task

Analyze hook effectiveness across all collected session metrics. Read every JSON in `~/.claude/hook-metrics/`. Produce report:

### 1. Hook activity

Each hook fired ≥1 across sessions:
- Total blocks, warns, denies
- Avg fires per session
- Trend: up or down over time?

### 2. Silent hooks

List hook scripts in `.claude/hooks/` with **zero entries** in any metrics file. Prune candidates — never trigger or not wired to logging.

### 3. Over-aggressive hooks

High block counts hurt productivity:
- Blocks-per-session ratio > 3 → flag too strict
- Same rule blocked repeat in one session → agent retry and fail

### 4. Enforcement gaps

Cross-ref CLAUDE.md rules vs hook activity:
- Rules with hook but zero fires → followed perfect or untested
- Rules with no hook → advisory, no enforce

### 5. Recommendations

From data:
- **Prune**: hooks never fire (remove or merge)
- **Soften**: hooks block too much (demote to warn)
- **Harden**: warns fire often (promote to block)
- **Add**: CLAUDE.md rules with no hook enforce

### Output format

Structured report. Tables where data fit. End with prioritized action list (max 5). If <5 session files, note data limited, recs preliminary.