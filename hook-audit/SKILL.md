---
name: hook-audit
description: Analyze hook effectiveness and session telemetry. Use when auditing hook latency, violations, zero-fire rules, severity, manifest drift, skill firing, session trends, or retrospectives.
---

Audit `~/.claude/hook-metrics/` using [REFERENCE.md](REFERENCE.md) for metrics, cohorts, and data gaps.

Modes: default/`--hooks` activity; `--retro` adds flow and environment findings; `--all` includes retro, latency, skill firing, drift.

## Flow

1. Inventory hooks/date range; separate evals from real runs. Cohort by harness version/model; split or exclude mixed-model sessions using `model-switches.jsonl`.
2. Aggregate blocks, warnings, nudges, denials, sessions, trend; compute P50/P95 and wall time when requested.
3. Compare scripts, observed keys, and enforcement; distinguish true zero-fire candidates, untested hooks, and advisory rules.
4. Retro: follow [Session-environment retrospective](REFERENCE.md#session-environment-retrospective); add available retro metrics. Missing telemetry does not block transcript findings.
5. All: inspect `skill-fires.jsonl`; run `bash scripts/generate-hook-configs.sh --check`.
6. Model-switch policy: use `/quantify-impact`; success/rework is primary, cache-write cost a guardrail.
7. Rank at most five actions across telemetry and session findings by impact. Recommend only unless implementation is requested.

Before deletion, shadow via `HOOK_SHADOW_RULES` in a representative, version-qualified trial; compare outcomes/violations. Never shadow strict safety/permission.

## Done

Report available metrics/values, sample size, 7-day trend, next action; mark gaps unavailable. Below five comparable real sessions is preliminary. Cite source files and exact `harness_version` + `model` cohort for prune/severity changes.
