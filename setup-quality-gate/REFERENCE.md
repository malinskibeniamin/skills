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

### CI workflow integration

Add to `.github/workflows/quality-gate.yml` to auto-trigger on every PR:

```yaml
  claude-review:
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    permissions:
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - name: Trigger Claude review
        run: gh pr comment "${{ github.event.pull_request.number }}" --body "@claude review"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
