#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"
if [ ! -f "$_lib" ]; then
  _lib="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)/shared/hook-lib.sh"
fi
source "$_lib"

hook_parse_edit_write
hook_filter_extensions "tsx"
hook_skip_generated
hook_skip_tests

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
rel_file="${file_path#"$repo_root"/}"

# Only new structural files. Existing-file edits are covered by related tests
# and route-sibling-test-check.sh.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  if git show "HEAD:$rel_file" >/dev/null 2>&1; then
    exit 0
  fi
fi

base=$(basename "$file_path")
file_content=$(cat "$file_path" 2>/dev/null || true)
_is_structural=false
_structural_kind="component"

case "$base" in
  *.page.tsx)
    _is_structural=true
    _structural_kind="page"
    ;;
esac

if [ "$_is_structural" = false ] && echo "$file_path" | grep -qE '/components/'; then
  if echo "$file_content" | grep -qE '(^|[[:space:]])(export[[:space:]]+)?(function|const)[[:space:]]+[A-Z][A-Za-z0-9_]*|export[[:space:]]+default[[:space:]]+function[[:space:]]+[A-Z]'; then
    _is_structural=true
    _structural_kind="component"
  fi
fi

[ "$_is_structural" = false ] && exit 0

dir=$(dirname "$file_path")
stem="${base%.*}"
short_stem="$stem"
case "$short_stem" in
  *.page) short_stem="${short_stem%.page}" ;;
esac

_has_test=false
for name in "$stem" "$short_stem"; do
  [ -z "$name" ] && continue
  for suffix in test.tsx test.ts integration.test.tsx integration.test.ts browser.test.tsx browser.test.ts spec.tsx spec.ts; do
    if [ -f "$dir/$name.$suffix" ] || [ -f "$dir/__tests__/$name.$suffix" ]; then
      _has_test=true
      break 2
    fi
  done
done

[ "$_has_test" = true ] && exit 0

_marker="$_hook_session_dir/structural-test-${rel_file//[^A-Za-z0-9_.-]/_}"
[ -f "$_marker" ] && exit 0
touch "$_marker" 2>/dev/null || true

hook_warn "Structural refactor without test: new $_structural_kind $rel_file needs an accompanying sibling test (.test, .integration.test, or .browser.test)." "structural-test-nudge"
