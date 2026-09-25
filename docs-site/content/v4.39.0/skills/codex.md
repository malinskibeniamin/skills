---
title: "/codex"
description: "Delegate to GPT-6 Astra through the Codex CLI. Use for clear-spec implementation, independent review, computer use, investigation, data analysis, or token-heavy mechanical work."
type: skill
sidebar:
  label: "/codex"
---
![Diagram of the /codex skill](/diagrams/skills/codex.svg)

[Open the editable Excalidraw source](/diagrams/skills/codex.excalidraw)


**Host gate:** Claude-hosted only. In native Codex, work inline unless the user explicitly requests delegation/parallel agents. Never start recursive `codex exec`; preserve selected model/reasoning and Codex config.

Capability-check once: `codex exec -m gpt-6-astra "reply OK"`. If unavailable, report the lane blocked; do not substitute another GPT model.

## Route

| Variant | Use |
|---|---|
| Astra, `high` (`max` only eval-backed/explicit) | code, UI, review, planning, computer use |

Read `config/model-routing.json`; never infer quality from name/price. [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/codex/REFERENCE.md) owns provider gates and CLI mechanics.

## Prompt contract

Codex lacks this conversation. Name repo/branch, objective, scope/exclusions, criteria, skill rules/exemplar, verification, evidence, stop. Send only local context/diff; exclude secrets. **Steering payload:** inline matched path rules and one `exemplars/` file.

## Modes

- **Implement:** `codex exec -m gpt-6-astra -c 'model_reasoning_effort="high"'`; concurrent writes use isolated worktrees.
- **Review:** different model family when permitted; otherwise labeled clean-context Astra, `-s read-only`, P0-P3 evidence.
- **Adversarial:** Claude-hosted and authorized only; one lane, never verdict.
- **Computer use:** name app/URL, states, evidence.
- **Investigate/analyze:** read-only compact report.

## Workflow

1. Pass host/authorization gate.
2. Select quality-qualified config route.
3. Write self-contained contract.
4. Run with timeout/reference background pattern.
5. Verify citations, commands, and high-risk conclusions before integrating.

Architecture, synthesis, product, safety, and final judgment stay with the coordinator. Astra may own user-facing output and meets the same visual evidence gate.
