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
        onSandboxReady: [
          // Install project deps first (without --yarn for speed)
          { command: "bun install --frozen-lockfile" },
          // Then install our skills + hooks via plugin
          // Removed --yarn step (yarn.lock no longer required)
          // Plugin installs all skills + hooks + agents in one step
          { command: "bunx skills@latest add malinskibeniamin/skills/frontend-starter-kit --agent claude-code -y" },
          { command: "bunx skills@latest add malinskibeniamin/skills/development-lifecycle --agent claude-code -y" },
          // Optional: start backend + frontend for full-stack verification
          // { command: "bun run dev &" },
        ],
      },
      maxIterations: 3,
    })
  )
);

// Review pass — dispatch code-reviewer on each branch
// Tip: use the Monitor tool inside each agent to watch CI/test output
// in the background instead of blocking on long-running commands.
for (const result of results) {
  if (result.commits.length > 0) {
    await run({
      agent: claudeCode("claude-sonnet-4-6"),
      prompt: `Review the changes on branch ${result.branch}. Run tests, check types, verify quality. Use Monitor to watch CI in the background after pushing. Report APPROVED or NEEDS_CHANGES.`,
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

## Your Environment

You have the following skills and hooks pre-installed:

**Skills loaded:**
- /development-lifecycle — follow phases: understand → plan → TDD → verify → review
- /tdd — iron law: failing test FIRST
- /triage-issue — if this is a bug fix: explore → root cause → TDD fix plan

**Hooks active (fire automatically):**
- react-rules-check (25 checks): raw HTML, as any, ts-ignore, eval, XSS, barrel imports
- accessibility-check (5 checks): img alt, keyboard handlers, ARIA widgets
- tanstack-router-check (9 checks): route patterns, typed hooks
- connect-query-check (11 checks): protobuf v2, Connect Query
- orchestration-stop: blocks on missing tests, runs related tests
- typecheck-stop: runs tsgo before completion
- biome-autofix: auto-formats on completion

**Agents available:**
- code-reviewer — dispatch for fresh-eyes review before final commit
- verifier — dispatch to verify UI changes via browser

## Instructions

1. Read the issue requirements carefully
2. Follow /development-lifecycle: understand → plan → TDD → verify
3. The hooks will enforce patterns — follow their guidance when they fire
4. Dispatch code-reviewer agent before final commit
5. Commit with conventional format: fix(scope): description. Closes #{{ISSUE_NUMBER}}
6. Run bun run quality:gate as final check

When done, emit: <promise>COMPLETE</promise>
```

### review.md

```markdown
# Code Review: {{SOURCE_BRANCH}}

You are the code-reviewer agent. Review with fresh eyes — you have NOT seen the implementation.

## Pre-checks (run these first)

```bash
bun test --run --related $(git diff --name-only {{SOURCE_BRANCH}}..main)
bun run type:check
bun run lint
```

## Review Checklist (matches our hook enforcement)

**Spec compliance:**
- [ ] All requirements from the issue addressed
- [ ] No scope creep
- [ ] Edge cases handled

**React/TS rules (25 checks our hooks enforce):**
- [ ] No raw HTML (`<button>` → `<Button>`)
- [ ] No `as any`, `@ts-ignore`, `@ts-expect-error`
- [ ] No `dangerouslySetInnerHTML`, `eval()`, `.innerHTML`
- [ ] No barrel imports, no `import * as`
- [ ] React Compiler: no manual useMemo/useCallback (if compiler installed)

**Accessibility (5 checks):**
- [ ] `<img>` has `alt`, icon buttons have `aria-label`
- [ ] Clickable divs have keyboard handlers
- [ ] ARIA widget roles complete

**Testing:**
- [ ] Tests exist for new code (TDD)
- [ ] Tests verify behavior, not implementation
- [ ] No setTimeout/waitForTimeout in tests

**Data layer (if applicable):**
- [ ] Connect Query (not raw useQuery) with ConnectRPC
- [ ] Protobuf v2: create(), not new Message()
- [ ] Timestamp: timestampFromDate(), not { seconds, nanos }

Report: APPROVED or NEEDS_CHANGES with file:line references.

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
| Monitor tool | Agents use Monitor to watch CI, test output, and dev servers in the background instead of blocking |
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

Implement with Claude, review with `/codex:adversarial-review`. Codex agent provider for Sandcastle is not yet available — use manual review for now.
