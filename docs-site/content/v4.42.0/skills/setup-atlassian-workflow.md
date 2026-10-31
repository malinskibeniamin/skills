---
description: "Configure opt-in Jira workflows through acli for work items, status, comments, and PR links."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["setup atlassian workflow"]}
sidebar: {"label":"/setup-atlassian-workflow"}
title: "/setup-atlassian-workflow"
type: "skill"
---
![Diagram of the /setup-atlassian-workflow skill](/diagrams/skills/setup-atlassian-workflow.svg)

[Open the editable Excalidraw source](/diagrams/skills/setup-atlassian-workflow.excalidraw)


Opt-in Jira via `acli`, alongside `gh`. Missing `acli` silently skips Jira. Supports create/transition/comment/search/view work items and PR links. Commands: [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/setup-atlassian-workflow/REFERENCE.md).

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
