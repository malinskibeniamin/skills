#!/bin/bash
set -euo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"
if [ ! -f "$_lib" ]; then
  _lib="$(cd "$(dirname "$0")/../.." 2>/dev/null && pwd)/shared/hook-lib.sh"
fi
source "$_lib"

hook_parse_edit_write
hook_filter_extensions "ts|tsx"
hook_skip_generated
hook_skip_tests

case "$file_path" in
  */routes/*|*.page.tsx) ;;
  *) exit 0 ;;
esac

if [ "${ROUTE_SIBLING_TEST:-1}" = "0" ]; then
  exit 0
fi

repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
dir=$(dirname "$file_path")
base=$(basename "$file_path")
stem="${base%.*}"
short_stem="$stem"
case "$short_stem" in
  *.page) short_stem="${short_stem%.page}" ;;
esac

_tests=()
_add_test() {
  local candidate="$1" existing
  [ -f "$candidate" ] || return 0
  for existing in "${_tests[@]:-}"; do
    [ "$existing" = "$candidate" ] && return 0
  done
  _tests+=("$candidate")
}

for name in "$stem" "$short_stem"; do
  [ -z "$name" ] && continue
  for suffix in browser.test.tsx browser.test.ts integration.test.tsx integration.test.ts; do
    _add_test "$dir/$name.$suffix"
  done
done

# Route directories often have one page plus one route file. If exact basename
# matching misses that convention, run the single sibling browser/integration
# test rather than falling back to the whole suite.
if [ "${#_tests[@]}" -eq 0 ]; then
  while IFS= read -r candidate; do
    _add_test "$candidate"
  done < <(find "$dir" -maxdepth 1 -type f \( -name '*.browser.test.tsx' -o -name '*.browser.test.ts' -o -name '*.integration.test.tsx' -o -name '*.integration.test.ts' \) 2>/dev/null | sort)
  if [ "${#_tests[@]}" -gt 1 ]; then
    exit 0
  fi
fi

[ "${#_tests[@]}" -eq 0 ] && exit 0

if [ -x "$repo_root/node_modules/.bin/vitest" ]; then
  _cmd=("$repo_root/node_modules/.bin/vitest" run)
elif command -v vitest >/dev/null 2>&1; then
  _cmd=(vitest run)
elif command -v bun >/dev/null 2>&1; then
  _cmd=(bun vitest --run)
else
  rel_tests=$(printf '%s ' "${_tests[@]}" | sed "s#$repo_root/##g")
  hook_warn "Sibling route test exists but no vitest/bun runner found. Run: vitest run $rel_tests" "route-sibling-test-no-runner"
fi

_run_with_timeout() {
  if command -v timeout >/dev/null 2>&1; then
    timeout 120 "$@"
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout 120 "$@"
  else
    "$@"
  fi
}

_output=""
_exit=0
_output=$(_run_with_timeout "${_cmd[@]}" "${_tests[@]}" 2>&1) || _exit=$?

if [ "$_exit" -ne 0 ]; then
  rel_file="${file_path#"$repo_root"/}"
  rel_tests=$(printf '%s ' "${_tests[@]}" | sed "s#$repo_root/##g")
  summary=$(printf '%s' "$_output" | tail -40 | tr '\n' ' ' | sed "s/[\"\\\\]/'/g; s/\`/'/g" | cut -c1-1200)
  hook_block "Sibling route test failed for $rel_file. Tests: $rel_tests. Output: $summary" "route-sibling-test"
fi

exit 0
