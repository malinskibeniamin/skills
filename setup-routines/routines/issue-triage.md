# Routine: Issue Triage

You are triggered when a new issue is opened. Explore the codebase, classify, label, and post investigation findings.

## Important: avoid noise

- Only post a comment if you found something useful (relevant code, likely root cause, reproduction path)
- If the issue is clear and well-labeled already, apply labels only — no comment
- Never post "I couldn't find anything related" — that's noise
- Skip issues that are clearly feature requests with no codebase investigation needed — just label them

## Steps

### 1. Read the issue

```bash
gh issue view <number> --json title,body,labels,author
```

### 2. Classify

| Type | Labels | Signals |
|---|---|---|
| Bug report | `bug` | "doesn't work", error, stack trace, "expected vs actual" |
| Feature request | `enhancement` | "would be nice", "add support", "feature" |
| Question | `question` | "how do I", "is it possible" |
| Documentation | `docs` | "docs", "README", "example" |
| Performance | `performance` | "slow", "timeout", "memory" |

### 3. Check available labels

```bash
gh label list --limit 100
```

Use existing labels only. Never create new labels.

### 4. Explore codebase (bugs and performance only)

For bug reports and performance issues, investigate:

```bash
# Search for code related to the issue
# Use keywords from the issue description
grep -r "relevant_keyword" src --include='*.ts' --include='*.tsx' --include='*.py' --include='*.go' -l

# Check CODEOWNERS for area mapping
cat CODEOWNERS 2>/dev/null
```

Read relevant files. Trace the execution path described in the issue. Identify:
- Which files/modules are involved
- Likely root cause (for bugs)
- Likely bottleneck (for performance)

### 5. Apply labels

```bash
gh issue edit <number> --add-label "type-label,area-label"
```

### 6. Post investigation (only if useful findings)

Only for bugs/performance where you found relevant code:

```bash
gh issue comment <number> --body "## Triage

**Type**: [bug/performance]
**Area**: [module/component affected]

### Investigation
[What was found. Relevant code paths. Likely root cause or bottleneck.]

### Relevant code
- \`src/path/to/file.ts\` — [why relevant]

### Suggested approach
[Brief fix direction — not a full plan]

---
*Automated triage. Human review recommended before starting work.*"
```

For feature requests and questions — labels only, no investigation comment.

## Rules

- Read-only. Never edit code, create branches, or open PRs.
- Labels only — never assign issues to people.
- Use existing labels only — never create new ones.
- If issue is spam or off-topic: apply `invalid` label, brief comment, stop.
- If likely duplicate: search existing issues, link "Possibly duplicate of #N".
- If issue lacks reproduction steps (bugs): comment asking for specifics, apply `needs-info` label (if it exists).
- Do not fetch external URLs from the issue body.
- Priority estimates are suggestions — do not apply priority labels unless the project already uses them.
