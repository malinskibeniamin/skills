---
description: "Analyze hook effectiveness and session telemetry. Use when auditing hook latency, violations, zero-fire rules, severity, manifest drift, skill firing, session trends, or retrospectives."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["hook audit"]}
sidebar: {"label":"/hook-audit"}
title: "/hook-audit"
type: "skill"
---
![Diagram of the /hook-audit skill](/diagrams/skills/hook-audit.svg)

[Open the editable Excalidraw source](/diagrams/skills/hook-audit.excalidraw)


Repeated corrections/skill improvements: read [Poteto](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#harness-improvement).

Audit `~/.claude/hook-metrics/` per [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/hook-audit/REFERENCE.md).

Modes: default/`--hooks` activity; `--retro` adds flow/environment; `--all` also adds latency, skill firing and drift.

## Flow

1. Inventory hooks/date range; separate evals from real runs. Cohort by harness version/model; split or exclude mixed-model sessions using `model-switches.jsonl`.
2. Aggregate blocks, warnings, nudges, denials, sessions, trend; compute P50/P95 and wall time when requested.
3. Compare scripts, observed keys, and enforcement; distinguish true zero-fire candidates, untested hooks, and advisory rules.
4. Retro: follow [Session-environment retrospective](https://github.com/malinskibeniamin/skills/blob/v4.42.0/hook-audit/REFERENCE.md#session-environment-retrospective); add available retro metrics. Missing telemetry does not block transcript findings.
5. All: inspect `skill-fires.jsonl`; run `bash scripts/generate-hook-configs.sh --check`.
6. Model-switch policy: use `/quantify-impact`; success/rework is primary, cache-write cost a guardrail.
7. Rank at most five actions by telemetry/session impact. Recommend only unless edits were requested.

Before deletion, shadow via `HOOK_SHADOW_RULES` in a representative, version-qualified trial; compare outcomes/violations. Never shadow strict safety/permission.

## Done

Report metrics/values, sample size, 7-day trend, next action; name gaps. Below five comparable real sessions is preliminary. Cite source files and exact `harness_version` + `model` cohort for prune/severity changes.
