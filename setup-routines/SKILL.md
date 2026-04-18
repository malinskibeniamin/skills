---
name: setup-routines
description: "Configure Claude Code routines for automated PR review, codebase health, issue triage, and docs drift detection. Use when setting up recurring automation, GitHub-triggered workflows, or API-triggered tasks that run on Anthropic cloud infrastructure."
---

# Setup Routines

Configure [Claude Code routines](https://claude.ai/code/routines) -- cloud-hosted automated sessions triggered by schedule, GitHub events, or API. Routines clone repo, run as full Claude Code sessions. Hooks and CLAUDE.md rules enforce automatically.

## How it works

```
Routine fires -> clones repo -> SessionStart hooks -> CLAUDE.md loads
-> routine prompt executes -> PostToolUse hooks enforce on every edit
-> Stop hooks run quality gates -> session ends
```

Hooks = enforcement layer | routine prompts = task layer. Standards evolve in repo (hooks + CLAUDE.md), routine prompts stay stable.

## Available templates

| Template | Trigger | What it does |
|---|---|---|
| [pr-review](routines/pr-review.md) | `pull_request.opened` | Reviews PR against standards, posts inline comments |
| [pr-feedback-resolve](routines/pr-feedback-resolve.md) | `pull_request.review_submitted` | Reads unresolved threads, fixes code, replies, resolves |
| [issue-triage](routines/issue-triage.md) | `issues.opened` | Explores codebase, classifies, labels, posts investigation |
| [weekly-health](routines/weekly-health.md) | Schedule: weekly | Runs quality checks, measures drift, opens health report issue |
| [docs-drift](routines/docs-drift.md) | Schedule: weekly | Detects stale docs from recent changes, opens fix PR or issue |

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
| triage-issue skill | issue-triage |
| Quality gate hooks/scripts | weekly-health |
| REFERENCE.md or other docs | docs-drift |

### 3. Create via web (recommended)

1. [claude.ai/code/routines](https://claude.ai/code/routines) -> **New routine**
2. Name it (for example "PR Review -- [repo name]")
3. Paste template from `routines/*.md` -- customize `OWNER`/`REPO` placeholders
4. Select repository + environment
5. Add trigger (GitHub event | schedule | API)
6. Review connectors -- remove unneeded
7. Create

### 4. Create via CLI

```bash
/schedule daily codebase health check at 9am
```

CLI creates scheduled routines only. GitHub/API triggers -> use web UI.

### 5. Customize prompts

Templates = starting points. Customize:

- **Project-specific checks**: reference patterns hooks enforce
- **Labels**: match issue label taxonomy
- **Scope boundaries**: "only review `src/`" or "skip generated files"
- **Connector actions**: "post summary to #engineering Slack"

See [REFERENCE.md](REFERENCE.md) for customization examples and API trigger setup.

### 6. Test

Run once manually before relying on triggers:

1. Web: **Run now** on routine detail page
2. CLI: `/schedule run`
3. Watch session live at returned URL
4. Review output -- adjust prompt if it wandered

## Routine vs. Sandcastle vs. interactive

| Scenario | Use |
|---|---|
| Automated on every PR | **Routine** -- GitHub trigger, cloud-hosted |
| Scheduled health checks | **Routine** -- schedule trigger |
| 5+ independent issues in parallel | **Sandcastle** -- parallel Docker agents |
| Overnight batch | **Sandcastle** -- AFK, local or CI |
| Interactive feature work | **Claude Code** -- direct session with human |
| CD pipeline integration | **Routine** -- API trigger from deploy script |

## Enforcement model

Routines run inside harness -- no bypass:

- **Hooks**: fire on every Edit/Write/Bash inside routine session
- **CLAUDE.md**: loads from repo root | all rules active
- **Skills**: available via `/skill-name` in routine prompt
- **Agents**: reviewer agents (code-reviewer, self-reviewer, adversarial-reviewer) dispatchable
- **Stop hooks**: quality gates (lint, typecheck) fire before session ends

Update hook -> every future routine run picks it up (next clone). No prompt changes needed.
