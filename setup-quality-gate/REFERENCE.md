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

## Asset Type Declarations

tsgo needs declarations for asset imports (`.svg`, `.css`, `.png`). Create `src/types/assets.d.ts`:

```ts
declare module '*.svg' {
  const content: string
  export default content
}
declare module '*.css' {
  const content: Record<string, string>
  export default content
}
declare module '*.png' {
  const content: string
  export default content
}
declare module '*.jpg' {
  const content: string
  export default content
}
declare module '*.webp' {
  const content: string
  export default content
}
declare module '*.woff2' {
  const content: string
  export default content
}
```

For rsbuild: `@rsbuild/core/types` in tsconfig may make this unnecessary.

## CI Status Check

After push: `gh pr checks` or `gh run watch`. Before merge: `gh pr checks --watch`.

## Cross-Model Review (Optional)

| Command | Purpose |
|---------|---------|
| `/codex:review` | Standard review from different model |
| `/codex:adversarial-review` | Challenge design decisions |
| `/codex:rescue <task>` | Delegate to Codex |
| `@claude review` | PR comment triggers remote Claude review |

## CI Pipeline Recommendations

### Coverage Gates

```yaml
# In quality-gate.yml, add after tests:
- name: Check coverage
  run: bun test --run --coverage --coverage.thresholds.lines=80
```

Enforce minimum thresholds — don't let coverage drop.

### Changesets (Versioning & Changelogs)

```bash
bun add -D @changesets/cli --yarn
bunx changeset init
```

Before every PR that changes user-facing behavior, run `bunx changeset` to create a changelog entry. CI validates changeset exists for non-trivial PRs.

### Feature Flags

For breaking changes or risky rollouts, wrap new features in feature flags:

```tsx
// Generic pattern — works with any flag provider (LaunchDarkly, Unleash, env vars)
const isNewFeatureEnabled = useFeatureFlag('new-dashboard-layout')

if (isNewFeatureEnabled) {
  return <NewDashboard />
}
return <LegacyDashboard />
```

Flag new routes, new shared components, and API contract changes. Remove flags within 2 sprints of full rollout.

### Visual Regression

```ts
// In Playwright e2e tests:
test('dashboard renders correctly', async ({ page }) => {
  await page.goto('/dashboard')
  await expect(page).toHaveScreenshot('dashboard.png', {
    maxDiffPixelRatio: 0.01,
  })
})
```

Run across Chromium + Firefox. Store baselines in the repo. Review screenshot diffs in Playwright report.

### Bundle Size Budget

```bash
# In quality-gate script, add:
bun run build 2>&1 | grep -E 'Total size|gzip' | tail -5
```

Set alerts if total bundle size exceeds a budget (e.g., 500KB gzip for main chunk). Use Rsdoctor or `@rsdoctor/rspack-plugin` for detailed analysis.

