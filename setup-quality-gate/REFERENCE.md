# Quality Gate Reference

## typecheck-stop.sh

```bash
#!/bin/bash
set -euo pipefail

# Stop hook: run type checking and related tests before Claude finishes.
# Only runs if JS/TS files were actually changed.

changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx)$' || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# ── Type check (incremental for speed) ──────────────────────────
# tsgo/tsc cannot target single files — they need the full project graph.
# --incremental reuses .tsbuildinfo to skip unchanged modules.
output=""
exit_code=0
output=$(bun run type:check 2>&1) || exit_code=$?

if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Type errors found. Fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

# ── Related tests (only tests affected by changed files) ────────
# Detect test runner: vitest (--related), jest (--findRelatedTests), bun test (file-only)
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
abs_changed=""
for f in $changed_files; do
  abs_changed="$abs_changed $repo_root/$f"
done

test_output=""
test_exit=0

if [ -f "$repo_root/node_modules/.bin/vitest" ]; then
  # Vitest: --related finds tests that transitively import changed files
  test_output=$(bun run test:related -- $abs_changed 2>&1) || test_exit=$?
elif [ -f "$repo_root/node_modules/.bin/jest" ]; then
  # Jest: --findRelatedTests does the same
  test_output=$(npx jest --findRelatedTests $abs_changed --passWithNoTests 2>&1) || test_exit=$?
else
  # Bun test or unknown: find co-located test files for changed source files
  test_files=""
  for f in $changed_files; do
    base="${f%.*}"
    ext="${f##*.}"
    for suffix in test spec; do
      candidate="$repo_root/${base}.${suffix}.${ext}"
      [ -f "$candidate" ] && test_files="$test_files $candidate"
    done
  done
  if [ -n "$test_files" ]; then
    test_output=$(bun test $test_files 2>&1) || test_exit=$?
  fi
fi

if [ $test_exit -ne 0 ] && [ -n "$test_output" ]; then
  truncated=$(echo "$test_output" | head -30)
  escaped=$(echo "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Related tests failed. Fix before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

exit 0
```

## bundle-guard.sh

```bash
#!/bin/bash
set -euo pipefail

# PostToolUse hook: warn when known-heavy dependencies are added to package.json.
# Only checks production "dependencies" (not devDependencies).

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Edit" ] && [ "$tool_name" != "Write" ]; then
  exit 0
fi

file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [ -z "$file_path" ] || [ ! -f "$file_path" ]; then
  exit 0
fi

# Only check package.json files
case "$file_path" in
  */package.json|package.json) ;;
  *) exit 0 ;;
esac

# Get added lines from diff
diff_output=""
diff_output=$(git diff HEAD -- "$file_path" 2>/dev/null) || true

if [ -z "$diff_output" ]; then
  added_lines=$(cat "$file_path")
else
  added_lines=$(echo "$diff_output" | grep '^+' | grep -v '^+++' || true)
fi

if [ -z "$added_lines" ]; then
  exit 0
fi

# We need to verify the dep is in "dependencies", not "devDependencies".
# Extract the "dependencies" block from the file.
deps_block=$(jq -r '.dependencies // {} | keys[]' "$file_path" 2>/dev/null || true)

# ── Check: moment ──
if echo "$added_lines" | grep -qE '"moment"' && echo "$deps_block" | grep -qx 'moment'; then
  echo '{"suppressOutput":true,"systemMessage":"Bundle guard: moment is 330KB. Use date-fns (22KB) instead."}' >&2
  exit 2
fi

# ── Check: lodash (but not lodash-es or lodash/) ──
if echo "$added_lines" | grep -qE '"lodash"' && ! echo "$added_lines" | grep -qE '"lodash-es"|"lodash/' && echo "$deps_block" | grep -qx 'lodash'; then
  echo '{"suppressOutput":true,"systemMessage":"Bundle guard: Full lodash is 530KB. Use lodash-es or per-function imports (e.g., lodash/get)."}' >&2
  exit 2
fi

# ── Check: jquery ──
if echo "$added_lines" | grep -qE '"jquery"' && echo "$deps_block" | grep -qx 'jquery'; then
  echo '{"suppressOutput":true,"systemMessage":"Bundle guard: jQuery is unnecessary in React projects. Use native DOM APIs or React refs."}' >&2
  exit 2
fi

# ── Check: core-js ──
if echo "$added_lines" | grep -qE '"core-js"' && echo "$deps_block" | grep -qx 'core-js'; then
  echo '{"suppressOutput":true,"systemMessage":"Bundle guard: Full core-js polyfill is 250KB+. Use specific polyfills or @babel/preset-env with useBuiltIns: '\''usage'\''."}' >&2
  exit 2
fi

# ── Check: classnames ──
if echo "$added_lines" | grep -qE '"classnames"' && echo "$deps_block" | grep -qx 'classnames'; then
  echo '{"suppressOutput":true,"systemMessage":"Bundle guard: Use clsx (330B) instead of classnames (1.8KB)."}' >&2
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
