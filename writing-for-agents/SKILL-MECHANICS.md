# Skill mechanics

The skill-specific branch of [writing-for-agents](SKILL.md): frontmatter, invocation, and routers.

## Invocation

- A **model-invoked** skill keeps a model-facing `description`, so the agent and other skills can discover it. Omit `disable-model-invocation`; describe the distinct trigger branches. This spends permanent context load.
- A **user-invoked** skill sets `disable-model-invocation: true`. Its description is human-facing, and only the human can invoke it. This spends cognitive load instead.

Choose model invocation only when autonomous discovery or skill-to-skill reach is valuable. Shared reference needed by multiple user-invoked skills belongs in a plain external file they can both point to.

## Splitting by invocation

Split a model-invoked skill when it has a distinct leading word that should trigger independently or another skill must reach it. Independent reach must justify the additional always-loaded description.

## Router skills

When user-invoked skills exceed what a human can remember, add one user-invoked router that names them and explains when to use each. The router can recommend but cannot autonomously invoke another user-invoked skill.
