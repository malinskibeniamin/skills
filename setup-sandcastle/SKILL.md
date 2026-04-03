---
name: setup-sandcastle
description: "Configure Sandcastle for AFK agent delegation — pick tasks from GitHub issues, run agents in parallel worktrees, merge results. Use when delegating work to autonomous agents, parallelizing implementation, or running AFK coding sessions."
---

# Setup Sandcastle

## What This Sets Up

[Sandcastle](https://github.com/mattpocock/sandcastle) runs Claude Code agents in isolated Docker containers with git worktrees. Each agent gets its own branch, implements a task using our development-lifecycle, and commits independently.

- **Task picking** — pull issues from GitHub, dispatch one agent per issue
- **Parallel execution** — N agents run simultaneously in isolated worktrees
- **Quality enforcement** — our hooks run inside each container
- **Code review** — dispatch code-reviewer agent on each branch
- **Merge** — fast-forward merge completed branches

## Steps

### 1. Install

```bash
bun add -D @ai-hero/sandcastle --yarn
npx sandcastle init
```

### 2. Configure `.sandcastle/.env`

```
ANTHROPIC_API_KEY=sk-ant-...
```

### 3. Create orchestration script

See [REFERENCE.md](REFERENCE.md) for the full `main.ts` template with task picking, parallel agents, and review pass.

### 4. Run

```bash
bunx tsx .sandcastle/main.ts
```

Each agent:
1. Reads the issue/task description
2. Follows development-lifecycle (understand → plan → TDD → verify → review)
3. Our hooks enforce patterns inside the container
4. Commits to its own branch
5. Code-reviewer agent reviews before merge

See [REFERENCE.md](REFERENCE.md) for templates, prompt patterns, and dogfooding setup.
