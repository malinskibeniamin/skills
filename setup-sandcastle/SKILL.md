---
name: setup-sandcastle
description: "Configure Sandcastle for AFK agent delegation — pick tasks from GitHub issues, run agents in parallel sandboxes, merge results. Use when delegating work to autonomous agents, parallelizing implementation, or running AFK coding sessions."
---

# Setup Sandcastle

[Sandcastle](https://github.com/mattpocock/sandcastle) runs agents in isolated Docker sandboxes with branch strategies. Each agent gets own branch, implements task via development-lifecycle, commits independently.

- Task picking: GitHub issues → one agent per issue
- Parallel: N agents in isolated sandboxes
- Quality: our hooks run inside each container
- Review: code-reviewer agent per branch
- Merge: fast-forward completed branches

```mermaid
sequenceDiagram
    participant GH as GitHub Issues
    participant Main as main.ts
    participant A1 as Agent 1
    participant An as Agent N
    participant Rev as code-reviewer

    GH->>Main: Fetch labeled issues

    par Parallel execution in Docker
        Main->>A1: Issue #1 (isolated sandbox)
        A1->>A1: development-lifecycle (6 phases)
        A1->>A1: hooks enforce 69+ checks
    and
        Main->>An: Issue #N (isolated sandbox)
        An->>An: development-lifecycle (6 phases)
        An->>An: hooks enforce 69+ checks
    end

    A1->>Rev: Branch for review
    Rev->>Main: Approved — fast-forward merge
    An->>Rev: Branch for review
    Rev->>Main: Approved — fast-forward merge
```

## Steps

### 1. Install
```bash
bun add -D @ai-hero/sandcastle && bunx sandcastle init
```

### 2. Configure `.sandcastle/.env`
```
ANTHROPIC_API_KEY=sk-ant-...
```

### 3. Orchestration Script
See [REFERENCE.md](REFERENCE.md) for `main.ts` template (task picking, parallel agents, review pass).

### 4. Run
```bash
bunx tsx .sandcastle/main.ts
```

Each agent: reads issue → development-lifecycle → hooks enforce patterns → commits to branch → code-reviewer reviews → merge.

See [REFERENCE.md](REFERENCE.md) for templates and prompt patterns.
