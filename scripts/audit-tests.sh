#!/bin/bash
set -euo pipefail

ROOT="${1:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DETECTOR="$SCRIPT_DIR/../.claude/hooks/checks/declarative-metadata-test.lib.sh"

if ! git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: test audit requires a Git worktree: $ROOT" >&2
  exit 1
fi

if [ ! -f "$DETECTOR" ]; then
  echo "ERROR: declarative metadata test detector not found: $DETECTOR" >&2
  exit 1
fi

source "$DETECTOR"

scanned=0
warnings=0

while IFS= read -r -d '' relative_path; do
  declarative_metadata_test_is_candidate "$relative_path" || continue
  file="$ROOT/$relative_path"
  [ -f "$file" ] || continue

  scanned=$((scanned + 1))
  content=$(cat "$file")
  if declarative_metadata_test_detect "$content"; then
    warnings=$((warnings + 1))
    printf 'WARN  %s: declarative metadata assertion; test behavior or enforce the invariant at its owner\n' "$relative_path"
  fi
done < <(git -C "$ROOT" ls-files --cached --others --exclude-standard -z)

printf 'Test audit: scanned %d test file(s), found %d warning(s).\n' "$scanned" "$warnings"
exit 0
