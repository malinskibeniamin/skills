#!/bin/bash
set -eo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

# PostToolUse Bash: warnings in passing test/lint/type output are hard errors.
# "Green != done". Scan stdout+stderr of vitest/rstest/playwright/tsc/biome/bun test
# exit-zero runs for curated warning patterns. Warnings are errors: block and
# force source remediation before calling the run clean.
#
# No env bypass. No allow comment. Fix the warning at source.

input=$(cat 2>/dev/null || echo '{}')
tool=$(echo "$input" | jq -r '.tool_name // empty' 2>/dev/null)
[ "$tool" = "Bash" ] || exit 0

command=$(echo "$input" | jq -r '.tool_input.command // empty' 2>/dev/null | tr '\n' ' ')
[ -n "$command" ] || exit 0

exit_code=$(echo "$input" | jq -r '.tool_response.exit_code // .tool_result.exit_code // 0' 2>/dev/null)
[ "$exit_code" = "0" ] || exit 0

# Gate: only scan when the command actually RUNS a test/lint/type tool.
# The tool must appear as a command word (start of command or after ;|&,
# or as a bun/bunx/npx subcommand) — never as a substring of a path,
# config filename, grep pattern, or loop variable. `cat vitest.config.ts`,
# `ls hooks | grep lint`, and `for f in *test*` must NOT match.
if ! printf '%s\n' "$command" | grep -qE \
  '(^|[;&|][[:space:]]*)(vitest|rstest|playwright|tsgo|tsc|biome)([[:space:]]|$)|(^|[;&|][[:space:]]*)(bun|bunx|npx)[[:space:]]+(run[[:space:]]+)?(vitest|rstest|playwright|tsgo|tsc|biome|test([[:space:]]|$)|[a-z:-]*(test|lint|type:check)[a-z:-]*([[:space:]]|$))'; then
  exit 0
fi

stdout=$(echo "$input" | jq -r '.tool_response.stdout // .tool_result.stdout // empty' 2>/dev/null)
stderr=$(echo "$input" | jq -r '.tool_response.stderr // .tool_result.stderr // empty' 2>/dev/null)
output="${stdout}
${stderr}"
[ -n "${output// /}" ] || exit 0

# Curated pattern → label map. Each line: "regex||label"
_findings=""
_kind=""

_scan() {
  local re="$1" label="$2"
  local hits
  hits=$(printf '%s' "$output" | grep -nE "$re" 2>/dev/null | head -3 || true)
  if [ -n "$hits" ]; then
    _kind="$label"
    _findings="${_findings}${label}: $(printf '%s' "$hits" | head -1 | cut -c1-160)
"
  fi
}

# Node runtime warnings
_scan '\(node:[0-9]+\) [A-Z][a-zA-Z]*Warning' 'node-runtime-warning'
_scan 'DeprecationWarning:' 'deprecation'
_scan 'ExperimentalWarning:' 'experimental-api'
_scan 'MaxListenersExceededWarning|PossibleEventEmitterMemoryLeak' 'memory-leak'
_scan 'UnhandledPromiseRejection|Unhandled promise rejection|Unhandled Rejection' 'unhandled-rejection'
_scan 'UnhandledError|Unhandled Errors' 'unhandled-error'

# React warnings (dev-mode)
_scan 'Warning: An update to .* inside a test was not wrapped in act' 'react-act'
_scan 'Warning: ReactDOM\.render|Warning: ReactDOMTestUtils' 'react-legacy-api'
_scan 'Warning: Each child in a list should have a unique "key"' 'react-missing-key'
_scan 'Warning: validateDOMNesting' 'react-dom-nesting'
_scan 'Warning: Failed prop type' 'react-prop-type'
_scan 'Warning: Cannot update a component .* while rendering' 'react-bad-setstate'
_scan 'Warning: Received .* for a non-boolean attribute' 'react-bad-attr'

# Vitest / test-runner signals
_scan '^\s*stderr \| ' 'stderr-during-test'
_scan 'Tests skipped\s*[0-9]+' 'skipped-tests'
_scan '\[vitest\].*warn' 'vitest-warn'

# Playwright
_scan 'playwright.*warning|Test ended with interrupted' 'playwright-warn'

# Generic lint/formatter warning lines. Avoid "0 warnings" summaries.
_scan '(^|[^0-9A-Za-z])(WARNING|[Ww]arning):' 'generic-warning'
_scan '(^|[^0-9A-Za-z])(WARN|[Ww]arn)(ed|ing)?(:|[[:space:]])' 'generic-warn'

# TypeScript suppression (green run that still contained a silenced error)
_scan '@ts-expect-error' 'ts-expect-error'
_scan '@ts-ignore' 'ts-ignore'

if [ -z "$_findings" ]; then
  _hook_log_entry "info" "no-warnings" test-warning-check
  exit 0
fi

# Streak tracking per kind — 3rd consecutive same-kind escalates
_streak_file="$_hook_session_dir/warning-streak"
_last_kind=$(cat "$_streak_file" 2>/dev/null | head -1 || true)
_streak=$(cat "$_streak_file" 2>/dev/null | tail -1 2>/dev/null | tr -d '[:space:]' || true)
[ -z "$_streak" ] && _streak=0
if [ "$_kind" = "$_last_kind" ]; then
  _streak=$((_streak + 1))
else
  _streak=1
fi
printf '%s\n%s\n' "$_kind" "$_streak" > "$_streak_file" 2>/dev/null || true

# Compact message; reporters already markdown-lean
_sample=$(printf '%s' "$_findings" | head -5)
_msg="Warnings are errors (${_kind}). Green run is not clean:
$_sample
Fix the warning at source before retrying the test."

if [ "$_streak" -ge 3 ]; then
  _msg="${_msg}
[${_streak}x same warning — STOP rerunning. Read ALL, fix at source, then one clean run.]"
fi

_hook_log_entry "block" "$_kind" test-warning-check
hook_block "$_msg" "test-warning-check"
