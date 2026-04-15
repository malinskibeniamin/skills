# Setup Routines — Reference

## Trigger configuration

### GitHub trigger: PR review

| Field | Value |
|---|---|
| Event | Pull request |
| Action | opened, synchronize |
| Filter (optional) | is draft = false, from fork = false |

### GitHub trigger: PR feedback resolve

| Field | Value |
|---|---|
| Event | Pull request |
| Action | review_submitted |
| Filter (optional) | is draft = false |

### GitHub trigger: issue triage

| Field | Value |
|---|---|
| Event | Issues |
| Action | opened |

### Schedule trigger: weekly health

| Field | Value |
|---|---|
| Frequency | Weekly (or weekdays) |
| Suggested time | Monday 9:00 AM local |

### Schedule trigger: docs drift

| Field | Value |
|---|---|
| Frequency | Weekly |
| Suggested time | Monday 10:00 AM local (offset from health check) |

## API trigger setup

For CI/CD integration (deploy verification, post-merge checks):

1. Create routine with desired prompt
2. Edit routine → Add trigger → API
3. Copy URL and generate token
4. Store token in CI secrets

```bash
# Example: trigger from GitHub Actions
curl -X POST https://api.anthropic.com/v1/claude_code/routines/trig_XXXXX/fire \
  -H "Authorization: Bearer $ROUTINE_TOKEN" \
  -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"Deploy $GITHUB_SHA completed. Run smoke checks.\"}"
```

GitHub Actions step:

```yaml
- name: Trigger post-deploy routine
  if: success()
  run: |
    curl -X POST "${{ secrets.ROUTINE_URL }}" \
      -H "Authorization: Bearer ${{ secrets.ROUTINE_TOKEN }}" \
      -H "anthropic-beta: experimental-cc-routine-2026-04-01" \
      -H "anthropic-version: 2023-06-01" \
      -H "Content-Type: application/json" \
      -d "{\"text\": \"Deploy ${{ github.sha }} to ${{ github.ref_name }}\"}"
```

## Customization examples

### Scope to specific directories

Add to any template prompt:

```
Only review files under src/features/ and src/components/.
Skip: node_modules/, dist/, *.gen.ts, *_pb.ts, coverage/.
```

### Add connector actions

```
After posting the review, send a summary to the #code-reviews Slack channel
using the Slack connector. Include PR title, verdict, and link.
```

### Team-specific label taxonomy

Replace the label table in issue-triage template:

```
| Type | Labels |
|---|---|
| Bug — frontend | bug, area:frontend |
| Bug — backend | bug, area:backend |
| Bug — infra | bug, area:infra |
| Feature | enhancement, needs-design |
| Chore | chore |
```

### Filter PRs by team

Add to PR review trigger filters:

| Filter | Operator | Value |
|---|---|---|
| Head branch | starts with | `feature/` |
| Labels | is one of | `needs-review` |

## Noise reduction checklist

Before enabling a routine, verify:

- [ ] **PR review**: confirms hooks handle style/pattern enforcement — routine prompt says "skip what hooks catch"
- [ ] **PR feedback resolve**: has "skip ambiguous" and "max 2 CI attempts" guardrails
- [ ] **Issue triage**: labels-only for feature requests, investigation-only for bugs
- [ ] **Weekly health**: delta-based reporting, silent when stable
- [ ] **Docs drift**: verified drift only, no false positives
- [ ] **All templates**: tested with "Run now" before enabling triggers

## Enforcement flow diagram

```
┌─────────────┐
│ Trigger      │  schedule / GitHub event / API POST
└──────┬──────┘
       ▼
┌─────────────┐
│ Clone repo   │  picks up .claude/ hooks, CLAUDE.md, skills, agents
└──────┬──────┘
       ▼
┌─────────────┐
│ SessionStart │  session-env.sh, llm-env.sh
└──────┬──────┘
       ▼
┌─────────────┐
│ Execute      │  routine prompt drives the session
│ prompt       │  ┌──────────────────────────┐
│              │  │ Every Edit/Write:        │
│              │  │  → PostToolUse hooks fire │
│              │  │ Every Bash:              │
│              │  │  → PreToolUse hooks fire  │
│              │  └──────────────────────────┘
└──────┬──────┘
       ▼
┌─────────────┐
│ Stop hooks   │  lint, typecheck, quality gates
└──────┬──────┘
       ▼
┌─────────────┐
│ Session ends │  results visible at claude.ai session URL
└─────────────┘
```

## Routine limits (research preview)

| Plan | Daily runs |
|---|---|
| Pro | 5 |
| Max | 15 |
| Team/Enterprise | 25 |

Extra runs consume subscription usage when overage is enabled.

## Routines vs. other automation

| Feature | Routines | Sandcastle | GitHub Actions | `/loop` |
|---|---|---|---|---|
| Runs on | Anthropic cloud | Local Docker | GitHub runners | Local CLI |
| Triggers | Schedule, GitHub, API | Manual / script | GitHub events | Timer / manual |
| Repo access | Clone per run | Mount / clone | Checkout | Current worktree |
| Hooks active | Yes (from clone) | Yes (installed in container) | No (unless configured) | Yes (local) |
| Parallel agents | No (1 session per trigger) | Yes (N containers) | Yes (matrix) | No |
| Cost | Subscription usage | API keys + compute | GitHub minutes | API keys |
| Best for | Recurring single-repo tasks | Batch parallel work | CI/CD pipelines | In-session polling |

## Troubleshooting

**Routine runs but hooks don't fire**
Hooks load from `.claude/settings.json` in the cloned repo. Verify the file exists and hooks are wired. Run `bash scripts/verify-install.sh` locally.

**Routine creates noisy comments**
Tighten the prompt: add explicit "skip nitpicks", "only P0/P1", "silent approval". Review session transcript to see where Claude wandered.

**Routine hits daily limit**
Reduce trigger frequency. For PR review: filter to non-draft, non-fork PRs only. For schedules: weekly instead of daily.

**Routine can't push branches**
By default, routines can only push to `claude/`-prefixed branches. Enable "Allow unrestricted branch pushes" in routine config if needed.

**GitHub trigger not firing**
Claude GitHub App must be installed on the repository. The trigger setup prompts installation. Running `/web-setup` alone is not sufficient — it grants clone access but not webhook delivery.
