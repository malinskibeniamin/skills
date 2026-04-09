#!/bin/bash
set -eo pipefail

# Stop hook: run biome lint:fix on all changed JS/TS files before Claude finishes.
# Only runs if JS/TS files were actually changed.

# Source hook-lib for session-scoped file tracking
source "$(dirname "$0")/../../shared/hook-lib.sh" 2>/dev/null || true

# git diff returns paths relative to repo root; strip the prefix so they're
# relative to cwd (where bun run lint:fix:file executes).
repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
cwd=$(pwd)
prefix="${cwd#"$repo_root"/}/"
# Skip component library directories (same pattern as shared/hook-lib.sh hook_skip_ui_dirs)
if [ -z "${UI_LIB_DIRS:-}" ]; then
  _ui_dirs="components/ui"
  [ -d "$repo_root/redpanda-ui" ] && _ui_dirs="$_ui_dirs|redpanda-ui"
  [ -d "$repo_root/src/ui" ] && _ui_dirs="$_ui_dirs|src/ui"
  [ -d "$repo_root/packages/ui" ] && _ui_dirs="$_ui_dirs|packages/ui"
else
  _ui_dirs="$UI_LIB_DIRS"
fi

# Session-scoped: only check files THIS session touched
if type hook_session_changed_files &>/dev/null; then
  all_changed=$(hook_session_changed_files "js|jsx|ts|tsx|mjs|mts|cjs|cts" | grep -vE "/($_ui_dirs)/" | sed "s|^${prefix}||" || true)
else
  all_changed=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(js|jsx|ts|tsx|mjs|mts|cjs|cts)$' | grep -vE "/($_ui_dirs)/" | sed "s|^${prefix}||" || true)
fi

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

# Skip if project doesn't have biome lint scripts
if [ ! -f "package.json" ] || ! jq -e '.scripts["lint:file"]' package.json >/dev/null 2>&1; then
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
  error_files=$(echo "$remaining" | grep -E '^\S+\.(tsx?|jsx?):\d+:\d+' | grep -vE "/($_ui_dirs)/" | grep -v 'internalError/io' || true)
  if [ -n "$error_files" ]; then
    # Track consecutive failures — downgrade to warn after 3 to avoid infinite loops
    _session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
    mkdir -p "$_session_dir" 2>/dev/null || true
    _biome_fail_counter="$_session_dir/biome-fail-count"
    _biome_fail_count=0
    if [ -f "$_biome_fail_counter" ]; then
      _biome_fail_count=$(cat "$_biome_fail_counter" 2>/dev/null || echo "0")
    fi
    _biome_fail_count=$((_biome_fail_count + 1))
    echo "$_biome_fail_count" > "$_biome_fail_counter"

    truncated=$(echo "$remaining" | grep -vE "/($_ui_dirs)/" | head -30)
    escaped=$(echo "$truncated" | jq -Rs .)

    if [ "$_biome_fail_count" -ge 3 ]; then
      echo "{\"decision\":\"allow\",\"reason\":\"Biome errors still present after $_biome_fail_count attempts (may be pre-existing). Allowing finish:\\n\"$escaped\"\"}" >&2
      exit 0
    fi

    echo "{\"decision\":\"block\",\"reason\":\"Biome found unfixable lint errors. Fix these before finishing:\\n\"$escaped\"\"}" >&2
    exit 2
  fi
fi

exit 0
