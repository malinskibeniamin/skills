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

## Coverage Gates

80% lines / 80% functions / 70% branches is our practical floor. Don't chase 100% — focus on critical paths.

## Bundle Size Budget

Main chunk <300KB gzip, total app <1MB gzip. Use Rsdoctor (`@rsdoctor/rspack-plugin`) for detailed analysis.
