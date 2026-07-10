---
name: swarm
description: parallel executor. Use /swarm.
---

# Swarm
Parallel executor: not planner, not autopilot.

Use `/swarm <free-form goal>`. Infer lanes from the user's text. Do not ask for approval before launch unless required context is missing.

## Position

- `/work` owns lifecycle.
- `/grilling` settles plan and docs.
- `/swarm` executes independent lanes faster.
- `/go` verifies and ships.

## Launch flow

1. Prime fast: inspect current repo state, rules, docs, branch, PR, and active goal when present. Use `/prime` style brief internally.
2. For long/high-cost swarms, apply `/efficient-frontier` usage-limit budgeting before the first wave and between waves. Default throttle: at most 3 parallel agents unless the user says otherwise.
3. Use `/efficient-frontier` under the hood: keep orchestration, integration, and final review with the coordinator; delegate bounded repo search, implementation, test, and log-reduction lanes.
4. Choose workspace policy from text:
   - Default: same branch/worktree/PR.
   - If user asks separate, isolated, or per-agent worktrees: create one worktree/branch per lane.
   - If conflict risk is high: split or serialize writes; say why in manifest.
5. Draft a tiny swarm manifest, then launch immediately:
   ```txt
   Swarm manifest
   Policy: shared | worktrees | hybrid
   - swarm-<lane-name>: <mission> | scope: <paths> | skills: </skill...>
   ```
6. Spawn only distinct lanes. No duplicate or vague agents.
7. Coordinator keeps critical path local, merges results, resolves conflicting findings, verifies, and closes agents.

## Lane design

Every lane gets a Task packet:

```yaml
agent_name: swarm-<area>-<mission>
role: explorer | worker | reviewer | teacher
mission: one concrete outcome
skills: [/prime, /tdd, /review]
context: docs, decisions, branch or PR, relevant paths
workspace_policy: shared | worktree | hybrid
write_scope: exact paths or "report-only"
forbidden: duplicate lanes, unrelated files, commits, pushes unless asked
model_policy: inherit by default; override only when useful or user asks
output schema: status, summary, changed_files, tests_run, findings, blockers, next_action
```

Agents may read and write unless the packet says `report-only`. In shared policy, assign file ownership or serialize write-heavy lanes. In worktree policy, branch names should be descriptive and may follow `<owner>/<ticket>/<lane-desc>` when creating worktrees.

## Skill composition

- Long/high-cost wave control: `/efficient-frontier` owns usage checks and pause/resume handoffs.
- Lane model choice: `/efficient-frontier` Model rankings. Bulk mechanical lanes -> GPT-5.6 via `/codex` wrapper (sonnet+low, `GPT-5.6:` label, worktree isolation). Cross-model review per CLAUDE.md runs on every lane result. Never Haiku.
- Frontier-token discipline: `/efficient-frontier` owns what to delegate versus keep in the coordinator.
- Worker lanes start with `/deslop` write mode; reviewer lanes include `/deslop` complexity tags before broader review.
- Architecture: fan out `/improve architecture` by context, module, seam, or adapter.
- TDD: split coverage by independent behavior or public interface. RED before production edits; require RED->GREEN or failing-test evidence in result.
- Skill/harness work: assign eval ownership per lane. Each changed skill or hook needs matching evals in scope, owned by the lane or the coordinator.
- Design/copy work: split `/visual-review`, `setup-ux-copy`/copywriting, accessibility, and articulation lanes only when their write scopes do not overlap.
- Review: split standards, spec, resilience, security, performance, tests, UX, and steelman axes.
- Diagnose: split reproduction loops, hypotheses, instrumentation, and regression tests.
- Product: combine `/grilling` explore mode, `/prototype`, and `/steelman` lanes for options and pushback.
- Handoff: after grilling, create compact packets so each agent starts with current decisions.
- Learning: split topic by theory, examples, repo usage, trade-offs, and pitfalls.

## Merge protocol

- Read every result; do not trust summaries blindly for write lanes.
- Apply or keep changes intentionally; never accept overlapping edits blindly.
- Conflicting recommendations: show options, evidence, and coordinator recommendation.
- Run targeted checks after merge. For TDD lanes, require failing-test evidence before implementation evidence.
- Final output: manifest recap, landed changes, rejected/deferred work, tests, blockers, next action.

## Compatibility

Codex and Claude Code must work from prompts and artifacts, not hidden hooks. Use native subagents when available. If no subagent tool exists, emit Task packets as handoff files or commands for manual launch.
