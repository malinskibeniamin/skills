# Skill mechanics

The skill-specific branch of [writing-for-agents](SKILL.md): frontmatter, invocation, and routers.

## Invocation

- A **model-invoked** skill keeps a model-facing `description`, so the agent and other skills can discover it. Omit `disable-model-invocation`; describe the distinct trigger branches. This spends permanent context load.
- A **user-invoked** skill sets `disable-model-invocation: true`. Its description is human-facing, and only the human can invoke it. This spends cognitive load instead.

Choose model invocation only when autonomous discovery or skill-to-skill reach is valuable. Shared reference needed by multiple user-invoked skills belongs in a plain external file they can both point to.

## Loading dependencies

When a workflow requires a model-invoked skill, invoke each dependency separately with Claude's Skill tool. In Codex or a host without that tool, read its canonical `SKILL.md` completely, following any generated proxy to the canonical file; load branch references when needed. A slash mention or catalog description is not a load.
Load conditional companions only when their trigger applies; read the linked section unless the owner requires the full file. Keep mandatory dependencies, safety and verification steps. Reuse unchanged guidance already loaded in the current context for this task; revalidate after relevant edits or scope changes and recover missing guidance after compaction. Required per-task instruction reads still apply.

For a user-invoked skill, recommend it to the human instead of invoking it automatically. Loading guidance grants no delegation or external-action permission.


## Splitting by invocation

Split a model-invoked skill when it has a distinct leading word that should trigger independently or another skill must reach it. Independent reach must justify the additional always-loaded description.

## Router skills

When user-invoked skills exceed what a human can remember, add one user-invoked router that names them and explains when to use each. The router can recommend but cannot autonomously invoke another user-invoked skill.

## Bundled helpers

Invoke bundled helpers with their declared interpreter (`bash scripts/check.sh`,
`node scripts/check.mjs`, or `python3 scripts/check.py`) rather than assuming the
host preserved executable bits. Use the repository's actual runtime and command.
This adapts the packaging guidance in
[Superpowers writing-skills at `22f0b463`](https://github.com/obra/superpowers/blob/22f0b463e7a5e579904dd6211a520321035526f7/skills/writing-skills/SKILL.md);
its test/delegation policies do not replace this harness's owners or consent rules.

## Navigation pointers

For repo guidance, use [repo navigation](../shared/repo-navigation.md). Put task ->
owning entry point -> adjacent test links in the existing maintained architecture
doc. A scoped `AGENTS.md`/`CLAUDE.md` is a small front door, not another rulebook.
Link repository-owned command scripts/configs instead of copying recipes into
memory or handoffs. Keep durable rationale; correct stale advice in place rather
than appending contradictory updates. Label historical snapshots/proposals with
date, status, and the current-policy pointer. Verify every referenced path exists.

## Improve the owning workflow

For broad authorized harness improvements, inventory registered skills and group them by task
family. Trace each lesson to its current owner and callers; record a concrete gap, existing
coverage, or non-applicability. Assess adapters through their local compatibility owner;
keep pinned upstream bytes intact. A catalogue pass is not a deep review of every skill.
For a scoped correction, start at the known owner and its callers instead.

Improve the step that changes behavior, not a standalone summary of the source material:

- **Selection:** named outcome, priority, displaced work and smallest useful slice.
- **Context:** authoritative inputs, domain helpers, invariants and existing area guide.
- **Execution:** one accountable owner, permitted tools, bounded independent work.
- **Feedback:** cheapest decisive check, credible failure/recovery and evidence limits.
- **Exit:** requested endpoint, compact result, durable context and actionable continuation.
- **Learning:** put a demonstrated miss in its owning type, test, check or scoped guidance;
  retain a valid control and known-bad case. Read-only advice proposes changes, not writes.

Keep shared rules once at a loaded owner, with skill-specific steps where needed. Verify
both lifecycle routing and direct invocations reach them. Preserve exceptions, permission
boundaries and context budgets; replace stale instructions rather than prefix every skill
with identical prose. Use the owning validator or prompt-contract check before and after;
instruction checks prove publication/routing, not adherence, review accuracy or productivity.
