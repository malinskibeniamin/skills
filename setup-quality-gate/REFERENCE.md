# Quality Gate Reference

## typecheck-stop.sh

> Script: [`scripts/typecheck-stop.sh`](scripts/typecheck-stop.sh)

## bundle-guard.sh

> Script: [`scripts/bundle-guard.sh`](scripts/bundle-guard.sh)

## quality-gate.yml

```yaml
name: Quality Gate

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: oven-sh/setup-bun@v2

      - name: Install dependencies
        run: bun install --frozen-lockfile --yarn

      - name: Check formatting integrity
        run: |
          bun run lint:fix
          git diff --exit-code || {
            echo "::error::Code is not properly formatted. Run 'bun run lint:fix' locally and commit."
            exit 1
          }

      - name: Type check
        run: bun run type:check

      - name: Run tests
        run: bun test --run
```

## Script Breakdown

| Script | What it runs | Expected time |
|--------|-------------|---------------|
| `lint` | `biome check .` | ~1s |
| `lint:fix` | `biome check --write .` | ~1s |
| `type:check` | `tsgo` | ~2s |
| `test` | `vitest --run` | varies |
| `test:related` | `vitest --run --related` | ~1-3s |
| `quality:gate` | lint + type:check + related tests | <5s target |

## CI Integrity Check

The `git diff --exit-code` pattern catches cases where someone bypassed pre-commit hooks or merged unformatted code:

1. CI runs `bun run lint:fix` (auto-formats)
2. CI checks `git diff --exit-code` (any diff = code wasn't clean)
3. If diff exists → CI fails with clear error message

This ensures the committed code is always the same as what the formatter would produce.

## CI Status Check via gh CLI

After pushing changes or creating a PR, verify CI passes before declaring work complete:

```bash
# Check the latest run status for current branch
gh run list --branch "$(git branch --show-current)" --limit 1

# Watch a run in progress (blocks until complete)
gh run watch

# Check PR checks specifically
gh pr checks
```

### In Stop hooks

The Stop hook can suggest checking CI status after pushing:

```bash
# After a push, remind to verify CI
if git log --oneline -1 | grep -q "push"; then
  echo "Verify CI: gh run list --branch $(git branch --show-current) --limit 1"
fi
```

### In quality:gate workflow

Before merging, verify all checks pass:

```bash
# Wait for all checks to pass
gh pr checks --watch

# Or check specific workflow
gh run list --workflow quality-gate.yml --branch "$(git branch --show-current)" --limit 1 --json status,conclusion
```

## Codex Second Opinion (Optional)

Install [codex-plugin-cc](https://github.com/openai/codex-plugin-cc) for cross-model code review inside Claude Code:

```
/plugin marketplace add openai/codex-plugin-cc
/plugin install codex@openai-codex
/reload-plugins
/codex:setup
```

### Review commands

| Command | Purpose |
|---------|---------|
| `/codex:review` | Standard read-only review — same quality as running Codex directly |
| `/codex:adversarial-review` | Challenge review — questions design decisions and tradeoffs |
| `/codex:rescue <task>` | Delegate bug investigation or continuation to Codex |
| `/codex:status` | Check running/completed background jobs |
| `/codex:result` | Retrieve final output from background job |

### Recommended workflow

Run `/codex:review` before creating a PR for a second opinion from a different model:

```
1. Finish coding → our hooks catch pattern violations automatically
2. /codex:review → Codex reviews for architectural/logic issues
3. Fix any findings
4. gh pr create → @claude review for remote review on full diff
5. Merge
```

For contentious design decisions, use `/codex:adversarial-review` — it specifically challenges tradeoffs rather than just checking correctness.

### Review gate (use with caution)

`/codex:setup --enable-review-gate` auto-reviews every Claude response and blocks completion if issues found. This creates extended loops that drain usage limits — only enable for critical code paths.

### Requirements

- ChatGPT subscription or OpenAI API key
- Node.js 18.18+
- `npm install -g @openai/codex` (or let the plugin auto-install)

## @claude Review on PRs

After creating a PR, trigger an automated Claude review by commenting `@claude review` on the PR. This provides an additional review layer beyond the local hooks.

### Auto-trigger after PR creation

After `gh pr create` succeeds, add a review comment:

```bash
# Create PR and capture the URL
PR_URL=$(gh pr create --title "feat(auth): add JWT tokens" --body "..." 2>&1 | tail -1)

# Trigger Claude review
gh pr comment "$PR_URL" --body "@claude review"
```

### What @claude reviews

The Claude review checks for:
- Code quality and patterns missed by static hooks
- Architectural concerns across multiple files
- Security issues that require semantic understanding
- Test coverage gaps
- Documentation completeness

### Selective review

For targeted reviews, be specific:

```bash
# Review only security aspects
gh pr comment "$PR_URL" --body "@claude review security"

# Review with specific focus
gh pr comment "$PR_URL" --body "@claude review - focus on the auth middleware changes and whether the token refresh is race-safe"
```

