---
title: "/setup-atlassian-workflow"
description: "Configure opt-in Jira workflows through acli for work items, status, comments, and PR links."
type: skill
sidebar:
  label: "/setup-atlassian-workflow"
---
![Diagram of the /setup-atlassian-workflow skill](/diagrams/skills/setup-atlassian-workflow.svg)

[Open the editable Excalidraw source](/diagrams/skills/setup-atlassian-workflow.excalidraw)

Opt-in Jira integration via `acli` (Atlassian CLI). Works alongside `gh`. If `acli` missing, Jira ops skip silent.

Capabilities: create/transition/comment work items, link PRs, search/view for context.

See [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/setup-atlassian-workflow/REFERENCE.md) for acli command patterns.

## Steps

### 1. Install + Authenticate
```bash
# Install: https://developer.atlassian.com/cloud/acli/guides/installation/
acli jira auth login
acli jira auth status  # verify
```

### 2. Configure session-env.sh
```bash
if command -v acli &>/dev/null; then
  echo "export JIRA_PROJECT=YOUR_PROJECT_KEY" >> "$CLAUDE_ENV_FILE"
  echo "export ISSUE_TRACKER=acli" >> "$CLAUDE_ENV_FILE"
fi
```
Set `ISSUE_TRACKER=both` for parallel gh + acli.

### 3. Verify
- [ ] `acli jira auth status` authenticated
- [ ] `JIRA_PROJECT` set in session env
