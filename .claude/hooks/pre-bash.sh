#!/bin/bash
set -uo pipefail

# PreToolUse(Bash) dispatcher: one process decides which guards can possibly
# fire before spawning any of them. Each child costs ~25-125ms (hook-lib init);
# an innocent `ls` used to pay all seven. Now the dispatcher extracts the
# command once and spawns only children whose trigger union matches -- the
# innocent path is one jq call.
#
# Contract: children run in order; first deny (exit 2) wins -- its output is
# forwarded and the batch stops; otherwise all stderr (nudges) is forwarded
# and the LAST non-empty stdout wins (rtk-rewrite runs last so its rewritten
# input survives).
#
# When adding a rule to a child, extend its trigger union here -- the
# differential evals catch a union that goes stale (deny stops firing).

_input=$(cat)
_dir="$(cd "$(dirname "$0")" && pwd)"
_cmd=$(printf '%s' "$_input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$_cmd" ] && exit 0

# hook script -> trigger union (ERE). Child is spawned only when it matches.
_hooks=(
  "enforce-toolchain.sh|npm|npx|yarn|pnpm|tsc|eslint|prettier|bun|rm|sleep|git|cat <<"
  "llm-test-flags.sh|vitest|playwright|bun (run )?test|jest|--watch"
  "conventional-commits-check.sh|git commit|git.*-m"
  "branch-safety-check.sh|git (commit|push|checkout|switch|worktree|branch)"
  "snyk-project-create-guard.sh|snyk"
  "bash-verbose-guard.sh|git commit|gh |rtk|curl|wget|taskw|bun run|--json|--jq"
  "rtk-rewrite.sh|git|gh |cargo|go |bun|vitest|npm|pnpm"
)

_stdout_final=""
for _entry in "${_hooks[@]}"; do
  _h="${_entry%%|*}"
  _union="${_entry#*|}"
  [ -x "$_dir/$_h" ] || continue
  printf '%s' "$_cmd" | grep -qE "$_union" || continue
  _out=""; _err=""; _code=0
  _out=$(printf '%s' "$_input" | "$_dir/$_h" 2>/tmp/pre-bash-err.$$) || _code=$?
  _err=$(cat /tmp/pre-bash-err.$$ 2>/dev/null || true)
  command rm -f /tmp/pre-bash-err.$$ 2>/dev/null || true
  if [ "$_code" -eq 2 ]; then
    [ -n "$_err" ] && printf '%s\n' "$_err" >&2
    [ -n "$_out" ] && printf '%s\n' "$_out"
    exit 2
  fi
  [ -n "$_err" ] && printf '%s\n' "$_err" >&2
  [ -n "$_out" ] && _stdout_final="$_out"
done

[ -n "$_stdout_final" ] && printf '%s\n' "$_stdout_final"
exit 0
