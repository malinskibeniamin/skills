#!/bin/bash
set -eo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

# PostToolUseFailure: categorize tool failure, suggest remediation.
# Replaces the "PostToolUse Bash + check exit code" pattern.

input=$(cat 2>/dev/null || echo '{}')
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)
command=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null | tr '\n' ' ')

[ "$tool" = "Bash" ] || exit 0
[ -n "$command" ] || exit 0

# Claude failure events carry a top-level error, not tool_response. Codex maps
# this hook to PostToolUse for both outcomes, so require a nonzero result there.
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)
interrupted=$(printf '%s' "$input" | jq -r '.is_interrupt // false' 2>/dev/null)
[ "$interrupted" != "true" ] || exit 0
stderr=$(printf '%s' "$input" | jq -r '
  (.error // .tool_response.stderr // .tool_result.stderr // "")
  | select(type == "string") | .[:500]
' 2>/dev/null)
if [ "$event" = "PostToolUseFailure" ]; then
  exit_code="unknown"
  if [[ "$stderr" =~ ^Exit\ code\ ([0-9]+)($|[[:space:]]) ]]; then
    exit_code="${BASH_REMATCH[1]}"
  fi
else
  exit_code=$(printf '%s' "$input" | jq -r '.tool_response.exit_code // .tool_result.exit_code // empty' 2>/dev/null)
  [[ "$exit_code" =~ ^[0-9]+$ ]] && [[ "$exit_code" =~ [1-9] ]] || exit 0
fi

_hint=""
_rule="tool-failure"

case "$command" in
  *"bun install"*|*"bun add"*)
    _rule="bun-install-fail"
    if echo "$stderr" | grep -qiE 'enotfound|timeout|econnreset'; then
      _hint="Network issue installing deps. Check connection, retry."
    elif echo "$stderr" | grep -qiE 'permission|EACCES'; then
      _hint="Permission issue. Check bun cache dir ownership."
    elif echo "$stderr" | grep -qiE 'not found|404|no matching version'; then
      _hint="Package/version not found. Verify name + version in package.json."
    else
      _hint="bun install failed. Read stderr — likely peer dep conflict or registry issue."
    fi
    ;;
  *"tsgo"*|*"type:check"*|*"tsc"*|*"tsrs"*)
    _rule="typecheck-fail"
    _hint="Type errors. Fix with type guards/generics/schema — no as any, no @ts-ignore."
    ;;
  *"vitest"*|*"bun test"*|*"test"*)
    _rule="test-fail"
    _hint="Test fail. Read output, fix assertion. If pre-existing failure, note it — don't silence."
    ;;
  *"biome"*|*"lint"*)
    _rule="lint-fail"
    _hint="Lint fail. Run bun run lint:fix for auto-fixes; manually resolve rest."
    ;;
  *"playwright"*|*"e2e"*)
    _rule="e2e-fail"
    _hint="E2E fail. Check screenshot/trace in test-results/. Verify baseURL reachable."
    ;;
  *"gh "*)
    _rule="gh-fail"
    _hint="gh CLI failed. Check auth (gh auth status), permissions on repo, or rate limit."
    ;;
  *)
    if [ "$exit_code" = "127" ]; then
      _rule="command-not-found"
      _hint="Command not found. Check PATH or install missing tool."
    else
      _rule="generic-fail"
      _hint="Command failed (exit $exit_code). Read the tool error for root cause."
    fi
    ;;
esac

# Track consecutive failures of same rule
_fail_file="$_hook_session_dir/consecutive-failures"
printf '%s\n' "$_rule" >> "$_fail_file" 2>/dev/null || true
_recent=$(tail -3 "$_fail_file" 2>/dev/null | sort -u | wc -l | tr -d ' ')
if [ "$(tail -3 "$_fail_file" 2>/dev/null | sort -u | head -1)" = "$_rule" ] && [ "$(tail -3 "$_fail_file" 2>/dev/null | wc -l | tr -d ' ')" = "3" ] && [ "$_recent" = "1" ]; then
  _hint="$_hint [3rd consecutive $_rule — stop retrying. Different approach needed.]"
fi

_hook_log_entry "info" "$_rule" post-tool-failure
echo "{\"suppressOutput\":true,\"systemMessage\":\"[tool-fail:$_rule] $_hint\"}"

exit 0
