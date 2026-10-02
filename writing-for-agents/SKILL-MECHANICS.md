# Skill mechanics

The skill-specific branch of [writing-for-agents](SKILL.md): frontmatter, invocation, and routers.

## Invocation

- A **model-invoked** skill keeps a model-facing `description`, so the agent and other skills can discover it. Omit `disable-model-invocation`; describe the distinct trigger branches. This spends permanent context load.
- A **user-invoked** skill sets `disable-model-invocation: true`. Its description is human-facing, and only the human can invoke it. This spends cognitive load instead.

Choose model invocation only when autonomous discovery or skill-to-skill reach is valuable. Shared reference needed by multiple user-invoked skills belongs in a plain external file they can both point to.

## Loading dependencies

When a workflow requires a model-invoked skill, invoke each dependency separately with Claude's Skill tool. In Codex or a host without that tool, read its canonical `SKILL.md` completely, following any generated proxy to the canonical file; load branch references when needed. A slash mention or catalog description is not a load.
Reuse guidance already loaded in the current context; recover it after compaction when missing. For a user-invoked skill, recommend it to the human instead of invoking it automatically. Loading guidance grants no delegation or external-action permission.


## Splitting by invocation

Split a model-invoked skill when it has a distinct leading word that should trigger independently or another skill must reach it. Independent reach must justify the additional always-loaded description.

## Router skills

When user-invoked skills exceed what a human can remember, add one user-invoked router that names them and explains when to use each. The router can recommend but cannot autonomously invoke another user-invoked skill.

## Navigation pointers

For repo guidance, use [repo navigation](../shared/repo-navigation.md). Put task ->
owning entry point -> adjacent test links in the existing maintained architecture
doc. A scoped `AGENTS.md`/`CLAUDE.md` is a small front door, not another rulebook.
Link repository-owned command scripts/configs instead of copying recipes into
memory or handoffs. Keep durable rationale; correct stale advice in place rather
than appending contradictory updates. Label historical snapshots/proposals with
date, status, and the current-policy pointer. Verify every referenced path exists.
