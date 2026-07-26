# Hook Audit Reference

## Hook metrics

- Activity: total blocks, warnings, nudges, denials; average per session; trend.
- Latency: P50, P95, invocations, total wall time.
- P95 above 100 ms is a budget breach; above 500 ms is critical.
- More than three blocks per session or repeated blocks from one rule suggests
  over-enforcement.

## Retro metrics

- Median first edit to PR.
- CI first-run pass rate.
- Sessions that wrote code without the lifecycle grill marker.
- Review rounds per change.
- Human comment to resolved-thread latency.
- Active worktrees; sustained counts above four require inspection.

## Skill firing

Read `~/.claude/hook-metrics/skill-fires.jsonl`. A model-invoked skill with no firing
evidence may have a weak description or no remaining value. Inspect both before proposing
deletion. High-fire skills are candidates for more tuning.

## Codex records

`codex-turns.jsonl` and `*-codex-*.json` contribute session and retro counts. Codex lacks
SessionEnd per-hook metrics, so empty hook maps are missing data, not silent-hook evidence.
