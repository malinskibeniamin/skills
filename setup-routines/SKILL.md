---
name: setup-routines
description: "Configure Claude Code routines for automated PR review, codebase health, issue triage, and docs drift detection. Use when setting up recurring automation, GitHub-triggered workflows, or API-triggered tasks that run on Anthropic cloud infrastructure."
---

# Setup Routines

Configure [Claude Code routines](https://claude.ai/code/routines) — cloud-hosted automated sessions triggered by schedule, GitHub events, or API calls. Routines clone your repo and run as full Claude Code sessions, so all hooks and CLAUDE.md rules from this harness enforce automatically.

## How it works

```
Routine fires → clones repo → SessionStart hooks → CLAUDE.md loads
→ routine prompt executes → PostToolUse hooks enforce on every edit
→ Stop hooks run quality gates → session ends
```

Your hooks are the enforcement layer. Routine prompts are the task layer. Separation means standards evolve in the repo (hooks + CLAUDE.md) while routine prompts stay stable.

## Available templates

| Template | Trigger | What it does |
|---|---|---|
| [pr-review](routines/pr-review.md) | GitHub: `pull_request.opened` | Reviews PR against project standards, posts inline comments |
| [pr-feedback-resolve](routines/pr-feedback-resolve.md) | GitHub: `pull_request.review_submitted` | Reads unresolved threads, fixes code, replies, resolves |
| [issue-triage](routines/issue-triage.md) | GitHub: `issues.opened` | Explores codebase, classifies, labels, posts investigation |
| [weekly-health](routines/weekly-health.md) | Schedule: weekly | Runs quality checks, measures drift, opens health report issue |
| [docs-drift](routines/docs-drift.md) | Schedule: weekly | Detects stale docs from recent code changes, opens fix PR or issue |

## Setup

### 1. Prerequisites

- Claude Code with web access enabled ([claude.ai/code](https://claude.ai/code))
- GitHub connected (`/web-setup` in CLI)
- Pro, Max, Team, or Enterprise plan

### 2. Pick routines

Match routines to installed skills:

| If you have | Recommended routines |
|---|---|
| Any hooks installed | pr-review (hooks enforce during review session) |
| resolve-pr-feedback skill | pr-feedback-resolve |
| triage-issue skill | issue-triage |
| Quality gate hooks or scripts | weekly-health |
| REFERENCE.md or other docs | docs-drift |

### 3. Create via web (recommended)

1. Go to [claude.ai/code/routines](https://claude.ai/code/routines) → **New routine**
2. Name it (for example, "PR Review — [repo name]")
3. Paste the template prompt from `routines/*.md` — customize the `OWNER`/`REPO` placeholders
4. Select your repository
5. Select environment (Default works, or custom with env vars)
6. Add trigger (GitHub event, schedule, or API)
7. Review connectors — remove any the routine doesn't need
8. Create

### 4. Create via CLI

```bash
/schedule daily codebase health check at 9am
```

CLI creates scheduled routines only. For GitHub triggers or API triggers, use the web UI.

### 5. Customize prompts

Templates are starting points. Customize for your project:

- **Add project-specific checks**: reference patterns your hooks enforce
- **Adjust labels**: match your issue label taxonomy
- **Set scope boundaries**: "only review files in `src/`" or "skip generated files"
- **Add connector actions**: "post summary to #engineering Slack channel"

See [REFERENCE.md](REFERENCE.md) for customization examples and API trigger setup.

### 6. Test

Run once manually before relying on triggers:

1. Web: click **Run now** on routine detail page
2. CLI: `/schedule run`
3. Watch the session live at the returned URL
4. Review what Claude did — adjust prompt if it wandered

## Routine vs. Sandcastle vs. interactive

| Scenario | Use |
|---|---|
| Automated on every PR | **Routine** — GitHub trigger, cloud-hosted |
| Scheduled health checks | **Routine** — schedule trigger, no local machine needed |
| 5+ independent issues in parallel | **Sandcastle** — parallel Docker agents |
| Overnight batch of issues | **Sandcastle** — AFK, local or CI |
| Interactive feature work | **Claude Code** — direct session with human |
| CD pipeline integration | **Routine** — API trigger from deploy script |

## Enforcement model

Routines don't bypass your harness — they run inside it:

- **Hooks**: fire on every Edit/Write/Bash inside the routine session. All installed checks.
- **CLAUDE.md**: loads from repo root. All rules active.
- **Skills**: available via `/skill-name` in routine prompt. Skills committed to repo work.
- **Agents**: reviewer agents (code-reviewer, self-reviewer, adversarial-reviewer) all dispatchable.
- **Stop hooks**: quality gates (lint, typecheck, and so on) fire before session ends.

Update a hook → every future routine run picks it up (next clone). No routine prompt changes needed.
