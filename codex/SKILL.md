---
name: codex
description: Delegate to GPT-6 Sol through the Codex CLI. Use for clear-spec implementation, independent review, computer use, investigation, data analysis, or token-heavy mechanical work.
---

**Host gate:** Claude-hosted only. In native Codex, work inline unless the user explicitly requests delegation/parallel agents. Never start recursive `codex exec`; preserve selected model/reasoning and Codex config.

Capability-check once: `codex exec -m gpt-6-sol "reply OK"`. If unavailable, fall back to Astra `high` and name it; if both fail, report the lane blocked. Never substitute a cheaper GPT model.

## Route

| Variant | Use |
|---|---|
| Sol, `medium` (`high`+ only eval-backed/explicit) | clear-spec code, computer use, investigation |
| Astra, `high` (Sol fallback; `max` only eval-backed/explicit) | PR review first; code, planning, computer use; UI only if no Claude owner |
| Luna, `high` (`gpt-6-luna`) | chores: tiny edits, clean rebases, mechanical CI fixes, read-only listing; judgment goes to Sol |

Read `config/model-routing.json`; never infer quality from name/price. [REFERENCE.md](REFERENCE.md) owns provider gates and CLI mechanics.

## Prompt contract

Codex lacks this conversation. Name repo/branch, objective, scope/exclusions, criteria, skill rules/exemplar, verification, evidence, stop. Send only local context/diff; exclude secrets. **Steering payload:** inline matched path rules and one `exemplars/` file.

## Modes

- **Implement:** `codex exec -m gpt-6-sol -c 'model_reasoning_effort="medium"'`; concurrent writes use isolated worktrees.
- **Review:** Astra `high` (`xhigh` at >=50% Codex usage left), `-s read-only`, P0-P3 evidence.
- **Adversarial:** Claude-hosted and authorized only; one lane, never verdict.
- **Computer use:** name app/URL, states, evidence.
- **Investigate/analyze:** read-only compact report.

## Workflow

1. Pass host/authorization gate.
2. Select quality-qualified config route.
3. Write self-contained contract.
4. Run with timeout/reference background pattern.
5. Verify citations, commands, and high-risk conclusions before integrating.

Architecture, synthesis, product, safety, and final judgment stay with the coordinator. Codex models do not own user-facing UI, copy, or API design while a Claude owner exists; an Astra fallback meets the visual evidence gate.
