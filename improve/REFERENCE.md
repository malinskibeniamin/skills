# Improve reference

Vendored from shadcn/improve. Use this with `/improve` to audit without editing source.

## Positioning

The core idea: use your smartest model where intelligence compounds, then hand execution to cheaper models later. `/improve` spends the expensive reasoning pass on audit, discovery, prioritization, and self-contained implementation plans. Executors then follow those plans with bounded scope, explicit tests, verification gates, and STOP conditions.

You can run it across the whole codebase, focus it on one category, or scope it to the current working branch. It studies code to find bugs, performance issues, tech debt, missing tests, dependency or tooling problems, and grounded product direction.

Every plan should cover:

- Audit evidence and discovery notes
- Exact scope and out-of-scope boundaries
- Ordered execution steps
- Testing and verification commands
- Done criteria
- STOP conditions for drift or unexpected complexity

## Audit categories

- **Correctness/bugs**: edge cases, races, stale state, error handling, data loss, broken invariants.
- **Security**: injection, authz/authn, path traversal, secret handling, unsafe HTML, dependency exposure. Never print secret values.
- **Performance**: N+1 queries, avoidable network calls, quadratic loops, bundle bloat, render churn, missing cache boundaries.
- **Test coverage**: high-risk untested code, missing regression tests, weak assertions, flaky async, absent integration/e2e coverage.
- **Tech debt and architecture**: duplication, drifted copies, poor seams, mixed concerns, abstractions that hide domain language.
- **Dependencies and migrations**: stale risky deps, half-finished migrations, deprecated APIs, incompatible peer ranges.
- **DX and tooling**: broken scripts, slow feedback loops, confusing setup, missing validation gates.
- **Docs**: incorrect setup, undocumented invariants, missing runbooks, stale examples.
- **Direction**: product/feature suggestions grounded in repo evidence. Present separately from defects.

## Finding format

Each finding returned by you or a subagent must include:

```markdown
### <short title>
- Category: correctness|security|performance|test coverage|tech debt|dependencies|DX|docs|direction
- Evidence: /absolute/path:line plus concise quote/paraphrase
- Impact: what user/operator/developer pain occurs
- Effort: S|M|L
- Fix risk: LOW|MED|HIGH
- Confidence: LOW|MED|HIGH
- Proposed plan slug: optional
```

Reject findings that are by design, unsupported by evidence, duplicate another finding, or not worth the cost. Record rejected items in `plans/README.md` when planning.

## Recon checklist

- `pwd`, `git rev-parse --short HEAD`, `git status --short`, `git log --oneline -30`.
- Read project instructions: `AGENTS.md`, `CLAUDE.md`, `README*`, `CONTRIBUTING*`.
- Identify verification gates from package/build config and CI.
- Map key directories and generated files to skip.
- Note conventions with exemplar files the executor can mimic.

## Read-only command policy

Allowed: `git diff`, `git grep`, `rg`, `find`, `sed`, `cat`, `jq`, typecheck in no-emit mode, lint check mode, cheap tests if side-effect free.
Avoid: package install, formatter writes, migrations, codegen writes, commits, pushes, destructive commands.
