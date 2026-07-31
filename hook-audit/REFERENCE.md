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
- Sessions ending without a classified endpoint or outcome.
- Review rounds per change.
- Human comment to resolved-thread latency.
- Active worktrees; sustained counts above four require inspection.

## Skill firing

Read `~/.claude/hook-metrics/skill-fires.jsonl`. A model-invoked skill with no firing
evidence is not automatically dead: first establish that comparable tasks presented a
real opportunity for the skill. Inspect its description and distinct knowledge before
proposing deletion. High-fire skills are candidates for more tuning, not automatic
promotion into ambient context.

Only use `run_kind: real` records for production-retention claims. Compare records from
the same `harness_version` and `model`; missing or `unknown` qualifiers cannot support a
prune decision. Synthetic and eval runs are useful for controlled shadow trials, not
adoption counts.

## Shadow trials

Set `HOOK_SHADOW_RULES` to a comma-separated list of non-strict rule labels. Shadowed
rules log `shadow-block`, `shadow-warn`, or `shadow-nudge` without steering the model.
Compare equivalent tasks on the same model and harness version, then retain the rule only
when it improves outcomes enough to justify its latency and prompt interference. Strict
safety and permission checks stay enforced.

## Codex records

`codex-turns.jsonl` and `*-codex-*.json` contribute session and retro counts. Codex lacks
SessionEnd per-hook metrics, so empty hook maps are missing data, not silent-hook evidence.

## Session summaries

Schema v4 summaries carry a stable hashed `session_id`, requested `endpoint`, terminal
`outcome`, harness version, model, and run kind. Group by the hash; never reconstruct or
expose the raw provider session ID. Treat `unknown` qualifiers and `ended` outcomes as
missing classification, not success.
