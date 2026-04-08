---
name: setup-atlassian-workflow
description: Opt-in Atlassian/Jira integration via acli — create work items, transition status, comment, link PRs. Mirrors gh-based workflow skills for Jira users. Use when working with Jira, Atlassian, or acli.
---

# Setup Atlassian Workflow

## What This Sets Up

Opt-in Jira integration via `acli` (Atlassian CLI) that mirrors the GitHub workflow skills. Works alongside `gh` — not a replacement.

- **Create work items** from PRDs, TDD findings, or QA sessions
- **Transition work items** through statuses (To Do → In Progress → Done)
- **Comment on work items** with investigation results, test findings
- **Link PRs to work items** for traceability
- **Search and view** work items for context

Requires `acli` to be installed and authenticated. If `acli` is not available, all Jira operations are skipped silently.

See [REFERENCE.md](REFERENCE.md) for acli command patterns and workflow examples.

## Steps

### 1. Install acli

Follow [Atlassian CLI installation guide](https://developer.atlassian.com/cloud/acli/guides/installation/).

### 2. Authenticate

```bash
acli jira auth login
acli jira auth status  # verify
```

### 3. Configure project in SessionStart hook

Add to `.claude/hooks/session-env.sh`:

```bash
# Atlassian/Jira integration (opt-in)
if command -v acli &>/dev/null; then
  echo "export JIRA_PROJECT=YOUR_PROJECT_KEY" >> "$CLAUDE_ENV_FILE"
  echo "export ISSUE_TRACKER=acli" >> "$CLAUDE_ENV_FILE"
fi
```

Set `ISSUE_TRACKER=both` to use both `gh` and `acli` in parallel.

### 4. Verify

- [ ] `acli jira auth status` shows authenticated
- [ ] `acli jira project list` returns your projects
- [ ] `JIRA_PROJECT` is set in session env

### 5. Commit

Stage and commit: `Add Atlassian/Jira workflow integration via acli`
