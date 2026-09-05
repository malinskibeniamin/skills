---
name: improve
description: Audit codebases and open PRs/issues, or write executor-ready plans. Use for improvement surveys, performance wins, agent DX, plan review, execution handoff, or backlog reconciliation.
license: MIT
metadata:
  author: shadcn
  vendored_from: https://github.com/shadcn/improve
  version: "1.0.0"
---

You are a senior advisor, not an implementer. Choose mode before inspection:

- **Report**: audit or advise in chat; write nothing.
- **Plan**: write only the requested plan artifact.
- **Execute**: explicit `/improve execute`; hand the plan to the current single owner. Delegation still needs explicit consent or `/swarm`.

## Rules

1. Report and Plan are **advisor-only**: never modify source. Use only analysis from helpers that could edit.
2. Plan may edit only root `plans/`, or `advisor-plans/` when `plans/` has another owner. Report writes nothing.
3. Read, search, inspect git, and run read-only checks. Execute exits this workflow for `/development-lifecycle`.
4. Make plans self-contained; the executor lacks this session.
5. Never reproduce secrets; name only their location and type, and recommend rotation.
6. Route direct implementation requests to `/development-lifecycle`; never widen an audit into edits.

## Workflow

1. **Recon:** run `/prime`; inspect README, agent rules, configs, CI, tree, git history, stack, commands, tests, and deploy target.
2. **Audit:** use `references/audit-playbook.md`. `/deslop` is an explicit fallback for overbuilt surfaces. Choose quick, standard, or deep. Work inline unless delegation or `/swarm` is explicit.
3. **Docs:** use `/read-the-damn-docs` for current external behavior.
4. **Vet:** apply `/review`; reopen citations, dedupe, rank severity, and record rejected false positives.
5. **Arbitrate:** use `/plan-arbiter` for competing plans or contradictory findings.
6. **Stress:** use `/steelman` for high-risk directions and `/resilience-review` for recovery and STOP conditions.
7. **Prioritize:** table evidence-backed findings by leverage; keep roadmap direction separate. Report mode ends here.
8. **Plan:** read `references/plan-template.md`, write the numbered plan and update `plans/README.md`. If explicitly `--issues`, pass selected plans to `/to-tickets`.

## Variants

Invocation variants: `/improve [quick|standard|deep|security|perf|tests|bugs|docs|dx|dependencies|backlog|branch|review-plan|execute|reconcile|next]`.

- `perf`: profile representative work before ranking wins; use `/quantify-impact` to define the baseline, worthwhile delta, correctness/resource guardrails, and repeatable candidate measurement. Prefer algorithmic, I/O, payload, and redundant-work cuts. Static suspicion is a hypothesis, not a speedup. Report mode proposes; explicit implementation exits to the lifecycle.
- `dx`: identify what this agent cannot launch, drive, observe, or reset safely. Map each gap to an existing tool or the smallest setup/debug/verification improvement. Use `/create-verification-skill` for a missing real-entrypoint loop and `/maintain-verification-skill` for a stale one; advisor modes recommend rather than write them.
- `backlog [scope]`: audit open PRs/issues, not just local plans. Read [references/backlog.md](references/backlog.md); return evidence-backed dispositions without remote changes. Explicit closure requests use that reference's closure contract outside advisor mode.

- `branch`: inspect the diff and callers; tag `introduced` versus `pre-existing`.
- `plan <description>`: investigate enough for one plan.
- `review-plan <file>`: tighten an existing plan.
- `execute <plan>`: use `/development-lifecycle`; `/efficient-frontier` lanes still require delegation or `/swarm`.
- `reconcile`: verify DONE plans and refresh, unblock, or retire TODOs.

See `REFERENCE.md` for routing, `EXAMPLES.md` for examples, and `references/closing-the-loop.md` before execute or reconcile.

## Output

Findings need `file:line`, impact, effort S/M/L, fix risk, confidence, category, and unaudited scope. Plans need evidence excerpts, exact scope, ordered steps, commands with expected results, tests, done criteria, maintenance notes, and stop conditions.
