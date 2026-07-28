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
# Union matching is on NORMALIZED text: backslash escapes (r\m) and quote
# splitting (r"m") are classic guard evasion; argv still resolves to rm.
_cmd_norm=$(printf '%s' "$_cmd" | tr -d "\\\\\"'")

# hook script -> trigger union (ERE). Child is spawned only when it matches.
_hooks=(
  "enforce-toolchain.sh|npm|npx|yarn|pnpm|tsgo|eslint|prettier|bun|rm|sleep|git|cat <<|killall|pkill|osascript"
  "llm-test-flags.sh|vitest|playwright|bun (run )?test|jest|--watch"
  "conventional-commits-check.sh|git commit|git.*-m"
  "branch-safety-check.sh|git (commit|push|checkout|switch|worktree|branch)"
  # snyk stays dispatcher-routed: a standalone `if: "Bash(snyk *)"` entry
  # missed bunx/npx/env-prefixed invocations and curl calls to api.snyk.io
  # (PR 72 review). The union below covers every shape the guard accepts.
  "snyk-project-create-guard.sh|snyk"
  "bash-verbose-guard.sh|git commit|gh |curl|wget|taskw|bun run|--json|--jq"
  "rtk-rewrite.sh|git|gh |cargo|go |bun|vitest|npm|pnpm"
)

_stdout_final=""
for _entry in "${_hooks[@]}"; do
  _h="${_entry%%|*}"
  _union="${_entry#*|}"
  [ -x "$_dir/$_h" ] || continue
  printf '%s' "$_cmd_norm" | grep -qE "$_union" || continue
  # Children write stderr straight through (no temp file: an unwritable /tmp
  # must never silently disable guards). Deny = exit 2. A child emitting
  # updatedInput rewrites the command for every LATER child, so rewrites
  # compose instead of last-stdout-wins clobbering earlier ones.
  _out=""; _code=0
  _out=$(printf '%s' "$_input" | "$_dir/$_h") || _code=$?
  if [ "$_code" -eq 2 ]; then
    [ -n "$_out" ] && printf '%s\n' "$_out"
    exit 2
  fi
  if [ -n "$_out" ]; then
    _stdout_final="$_out"
    _upd=$(printf '%s' "$_out" | jq -r '.hookSpecificOutput.updatedInput.command // empty' 2>/dev/null || true)
    if [ -n "$_upd" ]; then
      _cmd="$_upd"
      _cmd_norm=$(printf '%s' "$_cmd" | tr -d "\\\\\"'")
      _input=$(printf '%s' "$_input" | jq -c --arg c "$_upd" '.tool_input.command = $c' 2>/dev/null || printf '%s' "$_input")
    fi
  fi
done

[ -n "$_stdout_final" ] && printf '%s\n' "$_stdout_final"
exit 0
