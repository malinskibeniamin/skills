# CI Pipeline Reference

## Quality Gate Workflow

```yaml
name: Quality Gate

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  quality:
    runs-on: blacksmith-2vcpu-ubuntu-2404  # or ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: oven-sh/setup-bun@v2

      - name: Install dependencies
        run: bun install --frozen-lockfile --yarn

      - name: Lint + format integrity
        run: |
          bun run lint:fix
          git diff --exit-code || {
            echo "::error::Code not formatted. Run 'bun run lint:fix' locally."
            exit 1
          }

      - name: Type check
        run: bun run type:check

      - name: Unit + integration tests
        run: bun test --run --coverage --coverage.thresholds.lines=80

      - name: Coverage report
        if: github.event_name == 'pull_request'
        uses: davelosert/vitest-coverage-report-action@v2
```

## Blacksmith Worker Optimization

Use [Blacksmith MCP](https://github.com/grahamnotgrant/blacksmith-mcp) to analyze CI stats:

```bash
# Fetch CI run history to find bottlenecks
gh api repos/{owner}/{repo}/actions/runs --jq '.workflow_runs[:10] | .[] | "\(.name): \(.run_started_at) duration: \(.updated_at)"'
```

Optimization checklist:
- **Caching**: `bun install` is often faster than restoring cache. Check: if cache restore + install takes > bare install, remove caching. Measure with `time bun install --frozen-lockfile`.
- **Parallelization**: Split lint, type-check, tests into parallel jobs. Each is independent.
- **Sharding**: For large test suites, use `--shard=1/3` across 3 runners.
- **Artifact retention**: Default 90 days is excessive for most artifacts. Set `retention-days: 7` for coverage reports, `30` for screenshots.
- **Cache artifact size**: bun's `node_modules` can be large. Consider `actions/cache` only if install consistently takes >30s.

## Visual Regression Testing

Three layers, use the right one for each context:

| Layer | Tool | When to use | Speed |
|---|---|---|---|
| **Component** | Vitest browser mode or Rstest | Component-level rendering in happy-dom | Fast (~ms) |
| **Page** | Playwright `toHaveScreenshot()` | Full page rendering in real Chromium/Firefox | Medium (~s) |
| **Design system** | Chromatic / Percy | Storybook stories across all variants/browsers | Slow (hosted) |

### Playwright Visual Regression

```ts
test('dashboard renders correctly', async ({ page }) => {
  await page.goto('/dashboard')
  await expect(page).toHaveScreenshot('dashboard.png', {
    maxDiffPixelRatio: 0.01,
  })
})

// Specific component
test('sidebar navigation', async ({ page }) => {
  await page.goto('/topics')
  const sidebar = page.locator('[data-testid="sidebar"]')
  await expect(sidebar).toHaveScreenshot('sidebar.png')
})
```

Run across browsers:
```ts
// playwright.config.ts
projects: [
  { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
]
```

Update baselines: `bunx playwright test --update-snapshots`

### Chromatic (for component libraries / UI registries)

```bash
bun add -D chromatic --yarn
npx chromatic --project-token=<token>
```

Best for: registry playground, design system docs, component variant matrix. Creates a visual diff for every Storybook story. Not suitable for application-level page testing.

## Dependency Automation

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 10
    groups:
      minor-patch:
        update-types: ["minor", "patch"]
    ignore:
      # Don't auto-update major versions
      - dependency-name: "*"
        update-types: ["version-update:semver-major"]
```

## Coverage Gates

```bash
# In package.json scripts:
"test:coverage": "vitest --run --coverage --coverage.thresholds.lines=80 --coverage.thresholds.functions=80 --coverage.thresholds.branches=70"
```

Don't chase 100% — 80% lines / 80% functions / 70% branches is a practical floor. Focus coverage on critical paths, not utility functions.

## Bundle Size Budget

```yaml
# Add to quality-gate.yml
- name: Bundle size check
  run: |
    bun run build 2>&1 | tee /tmp/build-output.txt
    # Alert if main chunk exceeds budget
    if grep -E 'index.*\.js' /tmp/build-output.txt | awk '{print $NF}' | grep -qE '^[5-9][0-9]{2}|^[0-9]{4}'; then
      echo "::warning::Main bundle exceeds 500KB. Review code splitting."
    fi
```

Targets: main chunk <300KB gzip, total app <1MB gzip. Use Rsdoctor (`@rsdoctor/rspack-plugin`) for detailed analysis.

## Feature Flags for Breaking Changes

```tsx
// Generic pattern — works with any provider
const isEnabled = useFeatureFlag('new-feature-name')

// Or simple env-based for smaller teams:
const isEnabled = env.FEATURE_NEW_DASHBOARD === 'true'
```

Flag these: new routes, new shared components, API contract changes. Remove flags within 2 sprints of full rollout.

## Changesets (Versioning)

```bash
bun add -D @changesets/cli --yarn
bunx changeset init

# Before PR:
bunx changeset  # creates .changeset/*.md describing the change

# CI validates changeset exists for non-trivial PRs
```
