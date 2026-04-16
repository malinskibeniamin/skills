---
allowed-tools: Bash(ls *), Bash(cat *), Bash(jq *), Bash(wc *), Bash(sort *), Bash(head *), Bash(tail *), Bash(find *), Bash(awk *)
description: Analytics dashboard for the frontend-skills hook harness. Latency percentiles, top-violated rules, zero-fire hooks, session trends.
---

## Context

- Metrics dir: `~/.claude/hook-metrics/`
- Hook scripts: !`ls "$(git rev-parse --show-toplevel 2>/dev/null)/.claude/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' '` scripts
- Wired hooks: !`jq '[.hooks[]?[]?.hooks[]?] | length' "$(git rev-parse --show-toplevel 2>/dev/null)/skill-manifest.json" 2>/dev/null`
- Session summaries: !`ls ~/.claude/hook-metrics/*.json 2>/dev/null | wc -l | tr -d ' '`
- Date range: !`ls ~/.claude/hook-metrics/*.json 2>/dev/null | head -1 | xargs -I{} jq -r '.date' {} 2>/dev/null` to !`ls ~/.claude/hook-metrics/*.json 2>/dev/null | tail -1 | xargs -I{} jq -r '.date' {} 2>/dev/null`

## Your task

Analyze the frontend-skills harness across all collected session metrics. Read every JSON file in `~/.claude/hook-metrics/` and produce a prioritized report.

### 1. Latency profile

Parse `perf_ms` field from each session summary (added in 2.2.2). For each hook:

| Hook | P50 (ms) | P95 (ms) | Invocations | Total wall-clock |
|---|---|---|---|---|

Flag hooks with:
- P95 > 100ms → perf budget breach
- P95 > 500ms → critical
- Invocations = 0 across all sessions → zero-fire candidate

### 2. Rule activity

For each rule that fired at least once:

| Rule | Blocks | Warns | Nudges | Info | Diagnostic |
|---|---|---|---|---|---|

Detect new tier usage (nudge, info, diagnostic — added 2.2.2). Report adoption rate.

### 3. Silent hooks (zero fires)

List wired hooks with zero fires across ALL sessions. These are prune candidates.

### 4. Over-aggressive hooks

- Blocks-per-session ratio > 3 → too strict, consider demoting to warn
- Same rule blocked ≥ 2× in one session → Claude retrying, hook message unclear
- block-strict with no escape-hatch adoption → rule too harsh

### 5. Under-enforced rules

Cross-reference CLAUDE.md rules vs hook activity:
- Rule in CLAUDE.md, no hook → advisory only; add hook or accept as doc-only
- Rule has hook, zero fires → Claude never violates; safe
- Rule has hook, high fire rate → document in README prominently

### 6. Session health signals

- Sessions with hook errors (exit > 0 not in {0, 2}) → config bug
- Sessions with >20 blocks from same rule → feedback loop
- Sessions with 0 hook fires → either perfect compliance or hooks dead

### 7. Manifest drift check

Compare `skill-manifest.json` to `.claude/settings.json` and `hooks/hooks.json`:

```
bash scripts/generate-hook-configs.sh --check
```

If drift detected: RED FLAG — drift bug regression. Run `--apply` to fix.

### Output format

Structured report. Tables for numeric data. End with prioritized action list (max 5 items). If <5 session files exist, mark recommendations as preliminary.

Use plain markdown. No emojis.
