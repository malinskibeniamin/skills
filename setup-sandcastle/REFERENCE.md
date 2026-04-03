# Sandcastle Reference

## Orchestration Template

```typescript
// .sandcastle/main.ts
import { run, createSandbox, claudeCode } from "@ai-hero/sandcastle";

// Pick tasks from GitHub issues
const issues = JSON.parse(
  execSync('gh issue list --state open --label "ready" --json number,title,body --limit 5').toString()
);

// Run agents in parallel — each gets its own worktree + container
const results = await Promise.all(
  issues.map((issue) =>
    run({
      agent: claudeCode("claude-opus-4-6"),
      promptFile: ".sandcastle/implement.md",
      promptArgs: {
        ISSUE_NUMBER: String(issue.number),
        ISSUE_TITLE: issue.title,
        ISSUE_BODY: issue.body,
      },
      branch: `agent/fix-${issue.number}`,
      hooks: {
        onSandboxReady: [{ command: "bun install --frozen-lockfile --yarn" }],
      },
      maxIterations: 3,
    })
  )
);

// Review pass — dispatch code-reviewer on each branch
for (const result of results) {
  if (result.commits.length > 0) {
    await run({
      agent: claudeCode("claude-sonnet-4-6"),
      prompt: `Review the changes on branch ${result.branch}. Run tests, check types, verify quality. Report APPROVED or NEEDS_CHANGES.`,
      branch: result.branch,
      worktreeMode: { mode: "none" }, // read-only review
    });
  }
}
```

## Prompt Templates

### implement.md

```markdown
# Task: {{ISSUE_TITLE}}

Issue: #{{ISSUE_NUMBER}}

## Requirements
{{ISSUE_BODY}}

## Instructions

Follow the development lifecycle:
1. Understand the requirements — read relevant code
2. Plan — break into exact steps
3. Implement with TDD — failing test first
4. Verify — run tests, check types
5. Commit with conventional format: fix(scope): description. Closes #{{ISSUE_NUMBER}}

When done, emit: <promise>COMPLETE</promise>
```

### review.md

```markdown
# Code Review: {{SOURCE_BRANCH}}

Review the changes on this branch against the original issue requirements.

## Checklist
- [ ] All requirements addressed
- [ ] Tests pass (`bun test --run`)
- [ ] Types clean (`bun run type:check`)
- [ ] No as any, @ts-ignore, or escape hatches
- [ ] Accessibility: keyboard nav, aria-labels
- [ ] No barrel imports, no heavy static imports

Report: APPROVED or NEEDS_CHANGES with specific file:line references.

When done, emit: <promise>COMPLETE</promise>
```

## Dogfooding (Running on This Repo)

Use Sandcastle to work on our own skills repo:

```typescript
// .sandcastle/dogfood.ts
const issues = JSON.parse(
  execSync('gh issue list --repo malinskibeniamin/skills --state open --json number,title,body').toString()
);

await Promise.all(
  issues.map((issue) =>
    run({
      agent: claudeCode("claude-opus-4-6"),
      promptFile: ".sandcastle/implement.md",
      promptArgs: { ISSUE_NUMBER: String(issue.number), ISSUE_TITLE: issue.title, ISSUE_BODY: issue.body },
      branch: `agent/issue-${issue.number}`,
    })
  )
);
```

## Integration with Our Stack

| Our layer | How Sandcastle uses it |
|---|---|
| development-lifecycle | Each agent follows the 6-phase lifecycle |
| Hooks (25 total) | Run inside each container — react-rules, accessibility, etc. |
| code-reviewer agent | Dispatched as a review pass after implementation |
| verifier agent | Can verify UI changes via agent-browser inside container |
| orchestration-stop | Blocks agent from completing without tests + type check |
| intent-detect | Not used (agents get explicit prompts, not user prompts) |

## When to Use Sandcastle vs Claude Code

| Scenario | Use |
|---|---|
| Single feature, interactive | Claude Code directly |
| Bug fix needing human input | Claude Code directly |
| 5+ independent issues | Sandcastle — parallelize |
| Large plan with independent tasks | Sandcastle — one agent per task |
| Overnight batch work | Sandcastle — AFK |
| PR review pass | Sandcastle — code-reviewer on each branch |

## Cross-Model with Sandcastle

Run Claude Code for implementation + Codex for review:

```typescript
// Implement with Claude
const result = await run({
  agent: claudeCode("claude-opus-4-6"),
  promptFile: ".sandcastle/implement.md",
  branch: "agent/feature-42",
});

// Review with Codex (when codex agent is supported)
// For now: manual codex review or /codex:adversarial-review in Claude Code
```
