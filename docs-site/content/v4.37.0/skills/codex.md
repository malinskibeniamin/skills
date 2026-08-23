---
title: "/codex"
description: "Delegate to GPT-5.6 through the Codex CLI. Use for clear-spec implementation, independent review, computer use, investigation, data analysis, or token-heavy mechanical work."
type: skill
sidebar:
  label: "/codex"
---
![Diagram of the /codex skill](/diagrams/skills/codex.svg)

[Open the editable Excalidraw source](/diagrams/skills/codex.excalidraw)

**Host gate:** this path is Claude-hosted. In native Codex, work inline unless the user
explicitly requests delegation or parallel agents. Do not start recursive `codex exec`;
preserve the selected model and reasoning effort; do not rewrite Codex configuration.

Capability-detect once per session:

```bash
codex exec -m gpt-5.6-sol "reply OK"
```

If unavailable, use the strongest available GPT and label it. CLI unavailable skips the
lane and records why.

## Route variants

| Variant | Effort | Use |
|---|---|---|
| Sol | `xhigh`; `max` when eval-backed or explicitly selected | code, UI, review, planning, computer use |
| Terra | capability-dependent | eval-gated non-code tool loops |
| Luna | capability-dependent | eval-gated low-risk tool loops |

Read `config/model-routing.json` before choosing. Do not infer variant quality from price
or a name. Read [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/codex/REFERENCE.md) for cross-provider gates and CLI mechanics.

## Prompt contract

Codex sees none of this conversation. Every prompt names the repo and branch, objective,
scope and exclusions, acceptance criteria, applicable skill rules and exemplar, exact
verification commands, evidence format, and stop conditions. Send only the diff and
task-local context; exclude secrets and unrelated files.

**Steering payload:** inline the matched path-specific rules and matching `exemplars/`
file for implementation work.

## Modes

- **Implement:** `codex exec -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"'`;
  isolate concurrent writes in worktrees.
- **Review:** prefer a different model family from the author. Sol-authored work may use
  a Claude quality alternative; the fallback is a labeled clean-context Sol pass. Use
  `-s read-only` mode and P0-P3 evidence.
- **Adversarial exchange (automatic in Claude-hosted workflows):** use a different family
  when authorized; treat the result as one lane, not the verdict.
- **Computer use:** name URL/app, states, and evidence.
- **Investigate/analyze:** `-s read-only` with a compact report.

## Workflow

1. Pass the host and authorization gates.
2. Select the quality-qualified route from `config/model-routing.json`.
3. Write the self-contained prompt contract.
4. Run with explicit timeout or the reference background pattern.
5. Verify cited files, commands, and high-risk conclusions before integrating.

Judgment-heavy architecture, synthesis, product, safety, and final review stay with the
frontier coordinator. Sol may own user-facing output and must meet the same visual
evidence gate.
