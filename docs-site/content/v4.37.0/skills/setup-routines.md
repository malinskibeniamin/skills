---
title: "/setup-routines"
description: "Configure Claude Code routines for PR review, codebase health, issue triage, and docs drift."
type: skill
sidebar:
  label: "/setup-routines"
---
![Diagram of the /setup-routines skill](/diagrams/skills/setup-routines.svg)

[Open the editable Excalidraw source](/diagrams/skills/setup-routines.excalidraw)

Configure [Claude Code routines](https://claude.ai/code/routines) -- cloud-hosted auto sessions triggered by schedule, GitHub events, or API. Routines clone repo, run as full Claude Code sessions. Hooks + CLAUDE.md rules enforce auto.

## How it works

```
Routine fires -> clones repo -> SessionStart hooks -> CLAUDE.md loads
-> routine prompt executes -> PostToolUse hooks enforce on every edit
-> Stop hooks run quality gates -> session ends
```

### Enforcement model

Hooks = enforcement layer | routine prompts = task layer. Standards evolve
in repo (hooks + CLAUDE.md), routine prompts stay stable. Every routine
session runs the same PostToolUse/Stop gates as an interactive dev session,
so a routine cannot ship code that a developer could not ship locally.
For routine outputs, add `/agent-watchdog` audit steps. Add `/visual-recap` only when the
routine request explicitly includes that artifact.


Routines are cloud-hosted sessions triggered by schedule/webhook/API --
recurring automation that must survive your laptop closing.

## Available templates

| Template | Trigger | What it does |
|---|---|---|
| [pr-review](https://github.com/malinskibeniamin/skills/blob/v4.37.0/setup-routines/routines/pr-review.md) | `pull_request.opened` | Reviews PR vs standards, posts inline comments |
| [pr-feedback-resolve](https://github.com/malinskibeniamin/skills/blob/v4.37.0/setup-routines/routines/pr-feedback-resolve.md) | `pull_request.review_submitted` | Reads unresolved threads, fixes code, replies, resolves |
| [issue-triage](https://github.com/malinskibeniamin/skills/blob/v4.37.0/setup-routines/routines/issue-triage.md) | `issues.opened` | Explores codebase, classifies, labels, posts investigation |
| [weekly-health](https://github.com/malinskibeniamin/skills/blob/v4.37.0/setup-routines/routines/weekly-health.md) | Schedule: weekly | Runs quality checks, measures drift, opens health report issue |
| [docs-drift](https://github.com/malinskibeniamin/skills/blob/v4.37.0/setup-routines/routines/docs-drift.md) | Schedule: weekly | Detects stale docs from recent changes, opens fix PR or issue |

## Setup

### 1. Prerequisites

- Claude Code with web access ([claude.ai/code](https://claude.ai/code))
- GitHub connected (`/web-setup` in CLI)
- Pro, Max, Team, or Enterprise plan

### 2. Pick routines

| If you have | Recommended routines |
|---|---|
| Any hooks installed | pr-review |
| resolve-pr-feedback skill | pr-feedback-resolve |
| triage skill | issue-triage |
| Quality gate hooks/scripts | weekly-health |
| REFERENCE.md or other docs | docs-drift |

### 3. Create via web (recommended)

1. [claude.ai/code/routines](https://claude.ai/code/routines) -> **New routine**
2. Name (example "PR Review -- [repo name]")
3. Paste template from `routines/*.md` -- customize `OWNER`/`REPO` placeholders
4. Pick repo + environment
5. Add trigger (GitHub event | schedule | API)
6. Check connectors -- drop unneeded
7. Create

### 4. Create via CLI

```bash
/schedule daily codebase health check at 9am
```

CLI = scheduled routines only. GitHub/API triggers -> use web UI.

### 5. Customize prompts

Templates = start point. Customize:

- **Project-specific checks**: reference patterns hooks enforce
- **Labels**: match issue label taxonomy
- **Scope boundaries**: "only review `src/`" or "skip generated files"
- **Connector actions**: "post summary to #engineering Slack"

See [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/setup-routines/REFERENCE.md) for customization examples + API trigger setup.

### 6. Test

Run once by hand before trusting triggers:

1. Web: **Run now** on routine detail page
2. CLI: `/schedule run`
3. Watch session live at returned URL
4. Check output -- tweak prompt if wandered
See [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/setup-routines/REFERENCE.md): enforcement model, trigger/API/customization setup, troubleshooting.
