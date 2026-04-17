# Commit-push-pr reference

## Review skill list (Phase 0 pre-flight)

Before `/commit-push-pr`, one of these review skills must run in the session:

- `/simplify` — small fixes/tweaks
- `/request-refactor-plan` — refactors
- `/improve-codebase-architecture` — cleanup (oversized files, shallow modules, tangled deps)
- `/design-an-interface` — redesign module or layout

If none ran: warn — "Lifecycle requires review skill before shipping. Recommend: `/simplify` for small changes, `/request-refactor-plan` for refactors, `/improve-codebase-architecture` for cleanup."

## Conventional commit types (Phase 3)

Group changed files by purpose:

| Type | Matches |
|------|---------|
| `docs` | *.md, SKILL.md, REFERENCE.md, comments-only changes |
| `test` | *.test.ts, *.test.tsx, *.spec.ts, EVAL.ts, agent-evals/ |
| `refactor` | restructure without behavior change |
| `style` | formatting, whitespace, lint-only fixes |
| `fix` | bug fixes, error corrections |
| `feat` | new features, components, endpoints |
| `chore` | config, deps, build scripts, tooling |
| `perf` | performance improvements |
| `ci` | CI/CD pipeline changes |
| `build` | build system changes |

If file fit multiple categories → pick most specific.

## Auto-label map (Phase 5)

Map commit types to GitHub labels. Verify label exists first: `gh label list --search "<name>" --json name --jq '.[0].name'` — only add existing labels.

| Commit type | Label |
|-------------|-------|
| `feat` | `enhancement` |
| `fix` | `bug` |
| `docs` | `documentation` |
| `perf` | `performance` |
| `ci` | `ci` |
| `test` | `testing` |

## PR body template (Phase 5)

```
gh pr create --base <base> --assignee @me --fill-verbose --body "$(cat <<'EOF'
## Summary
<bulleted summary synthesized from commits>

## Commits
<list each commit: hash + message>

## Test plan
<checklist of how to verify — infer from changes>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

Note: `--fill-verbose` sets title from commits. Override with `--title` only if auto-gen title poor.

Append `--label <label1> --label <label2>` for each verified label.

**Draft mode**: if changes look WIP (TODO comments, incomplete implementations, test stubs), add `--draft`.
