---
description: "Delegate to GPT-6.1 Sol through the Codex CLI. Use for clear-spec implementation, independent review, computer use, investigation, data analysis, or token-heavy mechanical work."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["codex"]}
sidebar: {"label":"/codex"}
title: "/codex"
type: "skill"
---
![Diagram of the /codex skill](/diagrams/skills/codex.svg)

[Open the editable Excalidraw source](/diagrams/skills/codex.excalidraw)


**Host gate:** Claude-hosted only. In native Codex, work inline unless the user explicitly requests delegation/parallel agents. Never start recursive `codex exec`; preserve selected model/reasoning and Codex config.

When delegation is authorized, check once: `codex exec -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"' "reply OK"`. If unavailable, use a labeled clean-context Opus 5.5 `xhigh` review and disclose missing different-family coverage. Route only Opus 5.5 and GPT-6.1 Sol; block if neither is available.

## Route

| Variant | Use |
|---|---|
| Sol, `xhigh` (`gpt-6.1-sol`; never `max`) | preferred PR reviewer; explicitly selected execution, computer use, investigation |
| Opus 5.5, `xhigh` (`claude-opus-5-5`) | daily driver, UI, plans, code, chores; labeled clean-context review fallback |

Read `config/model-routing.json`; never infer quality from name/price. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/codex/REFERENCE.md) owns provider gates and CLI mechanics.

## Prompt contract

Name repo/branch, objective, scope/exclusions, criteria, skill rules/exemplar, verification, evidence, stop. Send only local context/diff; exclude secrets. **Steering payload:** inline matched path rules and one `exemplars/` file.

## Modes

- **Implement:** Sol `xhigh`; isolate concurrent writes in worktrees.
- **Review:** Sol `xhigh`: `codex exec -s read-only -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"'`; P0-P3 evidence. No guessed quota-based effort changes.
- **Adversarial:** Claude-hosted and authorized only; one lane, never verdict.
- **Computer use:** name app/URL, states, evidence.
- **Investigate/analyze:** read-only compact report.

[PR reports](https://github.com/malinskibeniamin/skills/blob/v4.41.0/codex/REFERENCE.md#pr-report-and-posting): local by default; publishing needs separate, explicit user intent.

## Workflow

1. Pass host/authorization gate.
2. Select quality-qualified config route.
3. Write self-contained contract.
4. Use timeout/reference background pattern.
5. Verify citations, commands, and high-risk conclusions.

Coordinator owns architecture, synthesis, product, safety, final judgment. Codex models do not own user-facing UI/copy/API design by default; block if Opus is unavailable.
