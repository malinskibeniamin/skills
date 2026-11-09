#!/bin/bash
set -eo pipefail
_lib="$(dirname "$0")/_hook-lib.sh"; if [ -f "$_lib" ]; then source "$_lib"; else _m="${TMPDIR:-/tmp}/frontend-skills-broken.${CLAUDE_SESSION_ID:-fs}"; [ -f "$_m" ] || { echo "[frontend-skills] _hook-lib.sh unavailable - run: /plugin install frontend-skills --force" >&2; touch "$_m" 2>/dev/null; }; exit 0; fi

# Both result events share outcome parsing and session state. The PostToolUse
# wrapper passes --success-only so Codex's mapped failure hook counts each call once.

hook_parse_bash
input="$_hook_input"
command=$(printf '%s' "$command" | tr '\n' ' ')
_fail_file="$_hook_session_dir/consecutive-failures"

# Claude failure events carry a top-level error, not tool_response. Codex maps
# this hook to PostToolUse for both outcomes, so require a nonzero result there.
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null)
interrupted=$(printf '%s' "$input" | jq -r '
  def result: (.tool_response // .tool_result);
  [.is_interrupt, (result | if type == "object" then .interrupted else false end)]
  | any(. == true)
' 2>/dev/null)
[ "$interrupted" != "true" ] || exit 0
stderr=$(printf '%s' "$input" | jq -r '
  (.error // ((.tool_response // .tool_result)
    | if type == "object" then .stderr else "" end) // "")
  | select(type == "string") | .[:500]
' 2>/dev/null)
if [ "$event" = "PostToolUseFailure" ]; then
  exit_code="unknown"
  if [[ "$stderr" =~ ^Exit\ code\ ([0-9]+)($|[[:space:]]) ]]; then
    exit_code="${BASH_REMATCH[1]}"
  fi
elif [ "$event" = "PostToolUse" ]; then
  exit_code=$(printf '%s' "$input" | jq -r '
    (.tool_response // .tool_result)
    | if type == "object" then .exit_code // empty else empty end
  ' 2>/dev/null)
  if [ -z "$exit_code" ]; then
    # Claude success results have no exit code. Unknown/unstructured results
    # provide no outcome evidence and must not clear a known failure streak.
    printf '%s' "$input" | jq -e '
      (.tool_response // .tool_result)
      | type == "object" and (.stdout | type == "string")
        and (.stderr | type == "string") and .interrupted == false
    ' >/dev/null 2>&1 || exit 0
    exit_code=0
  fi
  [[ "$exit_code" =~ ^[0-9]+$ ]] || exit 0
  if ! [[ "$exit_code" =~ [1-9] ]]; then
    rm -f "$_fail_file"
    exit 0
  fi
else
  exit 0
fi
[ "${1:-}" != "--success-only" ] || exit 0

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

# Keep only a fingerprint and bounded count, never command/output contents.
# Changed diagnostics are new evidence even when their failure category is the same.
_signature=$(printf '%s' "$input" | jq -c --arg command "$command" --arg code "$exit_code" --arg rule "$_rule" '
  [$command, $code, $rule, .error, ((.tool_response // .tool_result)
    | if type == "object" then [.stdout, .stderr] else . end)]
' | cksum | awk '{print $1 ":" $2}')
_previous=""
_count=0
if [ -f "$_fail_file" ]; then
  read -r _previous _count < "$_fail_file" || true
fi
if [ "$_signature" = "$_previous" ] && [[ "$_count" =~ ^[1-4]$ ]]; then
  [ "$_count" -ge 4 ] || _count=$((_count + 1))
else
  _count=1
fi
_state_tmp=$(mktemp "$_fail_file.XXXXXX")
printf '%s %s\n' "$_signature" "$_count" > "$_state_tmp"
mv -f "$_state_tmp" "$_fail_file"
_hook_log_entry "info" "$_rule" post-tool-failure
case "$_count" in
  1) ;;
  3) _hint="$_hint [3rd consecutive $_rule with unchanged command/output — try a different hypothesis.]" ;;
  *) exit 0 ;;
esac
echo "{\"suppressOutput\":true,\"systemMessage\":\"[tool-fail:$_rule] $_hint\"}"

exit 0
