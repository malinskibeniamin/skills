---
name: codex
description: Delegate to GPT-5.6 through the Codex CLI. Use for clear-spec implementation, independent review, computer use, investigation, data analysis, or token-heavy mechanical work.
---

# Codex Delegation

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
| Sol | xhigh for implementation, plans, or Sol-only review; high reviewing Opus | all code, review, planning |
| Terra | medium/high | PR comments, test-runner and CI chores |
| Luna | high | tracker orchestration and remote tool loops |

Terra and Luna never write product code or review. Read [REFERENCE.md](REFERENCE.md) for
cross-provider gates, quota rules, background execution, and Claude wrapper mechanics.

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
- **Review:** Opus work gets Sol high; Sol implementation gets Opus 5 xhigh feedback;
  Sol-only fallback gets clean-context Sol xhigh. Use read-only mode and P0-P3 evidence.
- **Adversarial exchange (automatic in Claude-hosted workflows):** use a different family
  when authorized; treat the result as one lane, not the verdict.
- **Computer use:** name URL/app, states, and evidence.
- **Investigate/analyze:** read-only with a compact report.

## Workflow

1. Pass the host and authorization gates.
2. Select the cheapest permitted variant that meets the task's judgment and taste bar.
3. Write the self-contained prompt contract.
4. Run with explicit timeout or the reference background pattern.
5. Verify cited files, commands, and high-risk conclusions before integrating.

Judgment-heavy architecture, synthesis, product, safety, and final review stay with the
frontier coordinator. User-facing output needs Fable or Opus taste; Sol may draft.
