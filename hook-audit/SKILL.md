---
name: hook-audit
description: Analyze hook effectiveness and session telemetry. Use when auditing hook latency, violations, zero-fire rules, severity, manifest drift, skill firing, session trends, or retrospectives.
---

Audit `~/.claude/hook-metrics/`. Codex turns count toward flow, but empty hook maps do not prove silence. [REFERENCE.md](REFERENCE.md) defines metrics/thresholds.

Modes: default/`--hooks` activity; `--retro` adds flow; `--all` adds latency, skill firing, drift.

## Flow

1. Inventory hooks/date range; separate evals from real runs and cohort by harness version/model. Split or exclude sessions listed in `model-switches.jsonl` rather than assigning a mixed-model session to one model.
2. Aggregate blocks, warnings, nudges, denials, sessions, trend.
3. When requested compute P50/P95 and wall time.
4. Compare scripts to observed keys; flag true zero-fire candidates.
5. Compare rules/enforcement; distinguish untested hooks from advisory rules.
6. Retro: PR lag, CI first-pass, review rounds, feedback latency, worktrees.
7. All: inspect `skill-fires.jsonl` and `model-switches.jsonl`; run `bash scripts/generate-hook-configs.sh --check`.
8. Recommend at most five actions: `Prune` purposeless zero-fire; `Soften` noisy blocks; `Harden` risky warnings; `Add` missing deterministic rule.

Before deletion, shadow via `HOOK_SHADOW_RULES` in a representative, version-qualified trial; compare outcomes/violations. Never shadow strict safety/permission.

## Done

Report metric, value, sample size, 7-day trend, next action. Below five comparable real sessions is preliminary. Cite source files and exact `harness_version` + `model` cohort for prune/severity changes.
