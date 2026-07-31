---
name: hook-audit
description: Analyze hook effectiveness and session telemetry. Use when auditing hook latency, violations, zero-fire rules, severity, manifest drift, skill firing, session trends, or retrospectives.
---

# Hook Audit

Audit session files in `~/.claude/hook-metrics/`. Codex turn records count toward session
flow, but their empty hook maps do not make hooks silent. Read
[REFERENCE.md](REFERENCE.md) for metric definitions and thresholds.

Modes:

- default or `--hooks`: hook activity, silence, severity, enforcement.
- `--retro`: add session-flow metrics.
- `--all`: include latency, skill firing, and manifest drift.

## Flow

1. Inventory installed hooks and metric date range. Separate real runs from evals and
   group evidence by harness version and model before comparing it.
2. Aggregate per hook: blocks, warnings, nudges, denials, sessions, trend.
3. Compute P50/P95 latency and total wall time when requested.
4. Compare installed scripts with observed keys; flag true zero-fire candidates.
5. Compare agent rules with enforcement; distinguish untested hooks from advisory rules.
6. In retro mode, measure PR lag, CI first-pass rate, review rounds, human-feedback
   latency, and worktree count.
7. In all mode, inspect `skill-fires.jsonl` and run:

```bash
bash scripts/generate-hook-configs.sh --check
```

8. Recommend at most five actions:
   - `Prune`: never fires and has no evidence-backed purpose.
   - `Soften`: blocks too often.
   - `Harden`: frequent warnings prove correctness risk.
   - `Add`: a deterministic high-value rule lacks enforcement.

For a deletion candidate, shadow the rule through `HOOK_SHADOW_RULES` on a
representative, version-qualified trial. Compare task outcomes and violations before
removing enforcement. Never shadow strict safety or permission rules.

## Completion

Report each metric with value, sample size, 7-day trend, and next action. Mark findings
preliminary below five comparable real sessions. Cite source files and the exact
`harness_version` + `model` cohort for every prune or severity change.
