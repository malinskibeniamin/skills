#!/bin/bash
set -euo pipefail

# Stop hook: run biome lint:fix on all changed JS/TS files before Claude finishes.
# Only runs if JS/TS files were actually changed.

# Check if any JS/TS files were changed.
# git diff returns paths relative to repo root; strip the prefix so they're
# relative to cwd (where bun run lint:fix:file executes).
# In monorepos, files outside the current package appear in diff but don't exist
# relative to cwd — filter them out to avoid "file not found" errors.
repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
cwd=$(pwd)
prefix="${cwd#"$repo_root"/}/"
all_changed=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(js|jsx|ts|tsx|mjs|mts|cjs|cts)$' | grep -vE '/(components/ui|redpanda-ui)/' | sed "s|^${prefix}||" || true)

# Filter to files that actually exist (excludes monorepo siblings)
changed_files=""
for f in $all_changed; do
  if [ -f "$f" ]; then
    changed_files="$changed_files $f"
  fi
done
changed_files=$(echo "$changed_files" | xargs)

if [ -z "$changed_files" ]; then
  exit 0
fi

# Run lint:fix on changed files only. Uses lint:fix:file / lint:file which
# do NOT hardcode "." — so biome only scans the listed files, not everything.
# Skip noUnusedImports to avoid deleting imports used elsewhere in the file.
fix_output=""
fix_exit=0
fix_output=$(bun run lint:fix:file -- --skip=lint/correctness/noUnusedImports $changed_files 2>&1) || fix_exit=$?

if [ $fix_exit -ne 0 ]; then
  # Check remaining errors — filter out biome's summary lines to detect real errors
  remaining=""
  remaining=$(bun run lint:file -- --skip=lint/correctness/noUnusedImports $changed_files 2>&1) || true

  # Only block if error file paths reference non-registry files
  # Biome error lines look like: src/file.tsx:10:5 lint/rule  FIXABLE
  error_files=$(echo "$remaining" | grep -E '^\S+\.(tsx?|jsx?):\d+:\d+' | grep -vE '(components/ui|redpanda-ui)/' | grep -v 'internalError/io' || true)
  if [ -n "$error_files" ]; then
    truncated=$(echo "$remaining" | grep -vE '(components/ui|redpanda-ui)/' | head -30)
    escaped=$(echo "$truncated" | jq -Rs .)
    echo "{\"decision\":\"block\",\"reason\":\"Biome found unfixable lint errors. Fix these before finishing:\\n\"$escaped\"\"}" >&2
    exit 2
  fi
fi

exit 0
