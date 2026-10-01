---
name: effect-ts
description: Use when setting up a repository that uses the Effect TypeScript library.
---

# Effect repository setup

## Install Effect

Use the repository's package manager. For a new v4 setup, upstream uses the
release-candidate channel:

```sh
bun add effect@rc
```

Preserve an existing Effect version unless an upgrade was requested. For a v3-to-v4
upgrade, use `/effect-v3-to-v4` instead of treating it as a fresh installation.

In a monorepo, install Effect as a root dev dependency when needed to expose the
source and agent guide from `node_modules/effect`:

```sh
bun add -D effect@rc
```

Keep runtime dependencies in the packages that import Effect. Verify that
`node_modules/effect/AGENTS.md` and `node_modules/effect/src` exist before adding
the instruction below; if absent, report the installed version and missing files.

## Update agent instructions

Add this block to the repository's canonical agent-instruction source. Regenerate
any derived `AGENTS.md` or `CLAUDE.md`; do not hand-edit generated instructions.

```md
# Learning more about Effect

This repository uses the Effect TypeScript library.

Before writing any Effect code, read `node_modules/effect/AGENTS.md` completely
and follow its links when required.

For APIs and concepts not covered by that guide, search the installed source in
`node_modules/effect/src`.
```
