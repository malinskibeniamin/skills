#!/bin/bash
set -euo pipefail

# Stop hook: run biome lint:fix on all changed JS/TS files before Claude finishes.
# Only runs if JS/TS files were actually changed.

# Check if any JS/TS files were changed.
# git diff returns paths relative to repo root; strip the prefix so they're
# relative to cwd (where bun run lint:fix executes).
repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
cwd=$(pwd)
prefix="${cwd#"$repo_root"/}/"
changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(js|jsx|ts|tsx|mjs|mts|cjs|cts)$' | grep -v '/redpanda-ui/' | sed "s|^${prefix}||" || true)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Run lint:fix on changed files (skipping noUnusedImports to avoid deleting
# imports that are used elsewhere in the file)
fix_output=""
fix_exit=0
fix_output=$(bun run lint:fix -- --skip=lint/correctness/noUnusedImports $changed_files 2>&1) || fix_exit=$?

if [ $fix_exit -ne 0 ]; then
  # Check remaining errors — filter out biome's summary lines to detect real errors
  remaining=""
  remaining=$(bun run lint -- --skip=lint/correctness/noUnusedImports $changed_files 2>&1) || true

  # Only block if error file paths reference non-registry files
  # Biome error lines look like: src/file.tsx:10:5 lint/rule  FIXABLE
  error_files=$(echo "$remaining" | grep -E '^\S+\.(tsx?|jsx?):\d+:\d+' | grep -v 'redpanda-ui/' || true)
  if [ -n "$error_files" ]; then
    truncated=$(echo "$remaining" | grep -v 'redpanda-ui/' | head -30)
    escaped=$(echo "$truncated" | jq -Rs .)
    echo "{\"decision\":\"block\",\"reason\":\"Biome found unfixable lint errors. Fix these before finishing:\\n\"$escaped\"\"}" >&2
    exit 2
  fi
fi

exit 0
