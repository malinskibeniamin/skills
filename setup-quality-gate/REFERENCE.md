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


