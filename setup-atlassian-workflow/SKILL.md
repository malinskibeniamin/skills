---
name: setup-atlassian-workflow
disable-model-invocation: true
description: Configure opt-in Jira workflows through acli for work items, status, comments, and PR links.
---

Opt-in Jira via `acli`, alongside `gh`. Missing `acli` silently skips Jira. Supports create/transition/comment/search/view work items and PR links. Commands: [REFERENCE.md](REFERENCE.md).

## Setup

```bash
# Install: https://developer.atlassian.com/cloud/acli/guides/installation/
acli jira auth login
acli jira auth status
```

In `session-env.sh`:

```bash
if command -v acli &>/dev/null; then
  echo "export JIRA_PROJECT=YOUR_PROJECT_KEY" >> "$CLAUDE_ENV_FILE"
  echo "export ISSUE_TRACKER=acli" >> "$CLAUDE_ENV_FILE"
fi
```

Use `ISSUE_TRACKER=both` for gh + acli. Verify auth and `JIRA_PROJECT` in session env.
