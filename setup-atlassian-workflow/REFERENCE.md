# Atlassian Workflow Reference

## acli Command Patterns

### Work Item Operations

#### Create a work item

```bash
# Interactive
acli jira workitem create --project "$JIRA_PROJECT"

# Non-interactive (for automation)
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Task \
  --summary "Implement user authentication" \
  --description "Add login and signup endpoints with JWT tokens"
```

#### Create work items in bulk (PRD → work items)

```bash
acli jira workitem create-bulk \
  --project "$JIRA_PROJECT" \
  --type Story \
  --input workitems.csv
```

#### Transition a work item

```bash
# Move to In Progress
acli jira workitem transition PROJ-123 "In Progress"

# Move to Done with comment
acli jira workitem transition PROJ-123 "Done" \
  --comment "Completed in PR #456"
```

#### Assign a work item

```bash
acli jira workitem assign PROJ-123 "user@company.com"
```

#### Comment on a work item

```bash
acli jira workitem comment-create PROJ-123 \
  --body "Investigation: root cause is a race condition in the auth middleware. See PR #789 for the fix."
```

#### Link a PR to a work item

```bash
acli jira workitem link PROJ-123 \
  --url "https://github.com/org/repo/pull/456" \
  --title "fix(auth): resolve race condition"
```

#### Search work items

```bash
# By status
acli jira workitem search --project "$JIRA_PROJECT" --status "To Do"

# By assignee
acli jira workitem search --project "$JIRA_PROJECT" --assignee "me"

# Raw JQL
acli jira workitem search --jql "project = $JIRA_PROJECT AND status = 'In Progress' ORDER BY updated DESC"
```

#### View a work item

```bash
acli jira workitem view PROJ-123
```

### Sprint Operations

```bash
# List sprints for a board
acli jira board list-sprints --board-id 42

# List work items in a sprint
acli jira sprint list-workitems --sprint-id 100
```

## Workflow Patterns

### PRD → Work Items (mirrors prd-to-issues)

After `/prd-to-plan` generates a plan:

```bash
# Create epic
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Epic \
  --summary "User Authentication System"

# Create stories under epic
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Story \
  --summary "Implement JWT token generation" \
  --parent PROJ-100

acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Story \
  --summary "Add login endpoint" \
  --parent PROJ-100
```

### Bug Triage (mirrors triage-issue)

After investigating a bug:

```bash
# Create bug with investigation findings
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Bug \
  --priority High \
  --summary "Race condition in auth middleware causes 401 on concurrent requests" \
  --description "## Root Cause\nThe token refresh logic is not atomic...\n\n## Fix\nWrap refresh in a mutex..."

# Link to related work item
acli jira workitem link PROJ-150 PROJ-100 "is caused by"
```

### QA Session (mirrors qa skill)

During QA, auto-file findings:

```bash
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Bug \
  --summary "Login form does not show error on invalid credentials" \
  --label qa-session \
  --label accessibility
```

### Test Guardian → Work Items

After running test-guardian diagnostics:

```bash
# File work item for flaky test
acli jira workitem create \
  --project "$JIRA_PROJECT" \
  --type Bug \
  --summary "Flaky test: auth.spec.ts intermittently fails on CI" \
  --label test-health \
  --description "## Findings\nAsync leak detected in auth.spec.ts:42..."
```

## Dual Tracker Support

When `ISSUE_TRACKER=both`, Claude should:

1. Create issues in **both** GitHub and Jira
2. Link the Jira work item to the GitHub issue URL
3. Use `gh` for PR-related operations (PRs live in GitHub)
4. Use `acli` for sprint/board operations (sprints live in Jira)

```bash
# Create in both
gh issue create --title "Fix auth race condition" --body "..."
acli jira workitem create --project "$JIRA_PROJECT" --type Bug --summary "Fix auth race condition"

# Link Jira to GitHub issue
acli jira workitem link PROJ-150 --url "https://github.com/org/repo/issues/42"
```

## Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `JIRA_PROJECT` | Default project key for work item creation | `CLOUD` |
| `ISSUE_TRACKER` | Which tracker to use: `gh`, `acli`, or `both` | `acli` |

## Detection

Skills should check for acli availability before using it:

```bash
if command -v acli &>/dev/null && [ -n "${JIRA_PROJECT:-}" ]; then
  # acli is available and project is configured
fi
```
