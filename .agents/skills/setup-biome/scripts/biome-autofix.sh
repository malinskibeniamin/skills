#!/bin/bash
set -euo pipefail

# Stop hook: run biome lint:fix on all changed JS/TS files before Claude finishes.
# Only runs if JS/TS files were actually changed.

# Check if any JS/TS files were changed
changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(js|jsx|ts|tsx|mjs|mts|cjs|cts)$' || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Run lint:fix on changed files (skipping noUnusedImports to avoid deleting
# imports that are used elsewhere in the file)
fix_output=""
fix_exit=0
fix_output=$(bun run lint:fix -- --skip=lint/correctness/noUnusedImports $changed_files 2>&1) || fix_exit=$?

if [ $fix_exit -ne 0 ]; then
  # Check remaining errors
  remaining=""
  remaining=$(bun run lint -- --skip=lint/correctness/noUnusedImports $changed_files 2>&1) || true

  if [ -n "$remaining" ]; then
    truncated=$(echo "$remaining" | head -30)
    escaped=$(echo "$truncated" | jq -Rs .)
    echo "{\"decision\":\"block\",\"reason\":\"Biome found unfixable lint errors. Fix these before finishing:\\n\"$escaped\"\"}" >&2
    exit 2
  fi
fi

exit 0
