# Quality Gate Reference

## typecheck-stop.sh

```bash
#!/bin/bash
set -euo pipefail

# Run tsgo type checking before Claude finishes responding
output=""
exit_code=0
output=$(tsgo --noEmit 2>&1) || exit_code=$?

if [ $exit_code -ne 0 ]; then
  # Truncate to keep context manageable
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Type errors found. Fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

exit 0
```

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
        run: bun run typecheck

      - name: Run tests
        run: bun test --run
```

## Script Breakdown

| Script | What it runs | Expected time |
|--------|-------------|---------------|
| `lint` | `biome check .` | ~1s |
| `lint:fix` | `biome check --write .` | ~1s |
| `typecheck` | `tsgo` | ~2s |
| `test` | `vitest --run` | varies |
| `test:related` | `vitest --run --related` | ~1-3s |
| `quality:gate` | lint + typecheck + related tests | <5s target |

## CI Integrity Check

The `git diff --exit-code` pattern catches cases where someone bypassed pre-commit hooks or merged unformatted code:

1. CI runs `bun run lint:fix` (auto-formats)
2. CI checks `git diff --exit-code` (any diff = code wasn't clean)
3. If diff exists → CI fails with clear error message

This ensures the committed code is always the same as what the formatter would produce.
