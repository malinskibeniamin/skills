#!/bin/bash
set -eo pipefail

# Escape hatch: when Claude is already responding to a Stop block, do not
# block again -- prevents infinite hostage loops.
_sg_in=$(cat); if printf '%s' "$_sg_in" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then exit 0; fi

# Stop hook: the suppression gate (amplification principle).
# Every tolerated lint/type suppression is a training example an LLM author
# will imitate and spread. This gate blocks the turn when the session added
# more suppressions than it removed, forcing a fix-at-source or an explicit,
# reasoned escape.
#
# Escape: SUPPRESSION_GATE=0 env var, or justify each new suppression with a
# reason on the same line (bare suppressions count; reasoned ones still count
# but the message tells the model which ones it added).

if [ "${SUPPRESSION_GATE:-1}" = "0" ]; then exit 0; fi

_shim="$(dirname "$0")/source-hook-lib.sh"; if [ -f "$_shim" ]; then . "$_shim" 2>/dev/null || true; fi

# Session-scoped: only inspect files this session touched.
if type hook_session_changed_files &>/dev/null; then
  changed_files=$(hook_session_changed_files "ts|tsx|js|jsx")
else
  changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(ts|tsx|js|jsx)$' || true)
fi
[ -z "$changed_files" ] && exit 0

_sg_pattern='biome-ignore|@ts-ignore|@ts-expect-error|eslint-disable|"use no memo"|react-doctor-disable'

_added=0
_removed=0
_added_sample=""
_base=$(git merge-base origin/main HEAD 2>/dev/null || git rev-parse HEAD 2>/dev/null || true)
while IFS= read -r f; do
  [ -z "$f" ] && continue
  [ -f "$f" ] || continue
  _diff=$(git diff "$_base" -- "$f" 2>/dev/null || true)
  [ -z "$_diff" ] && continue
  _a=$(printf '%s\n' "$_diff" | grep -cE "^\+[^+].*($_sg_pattern)" || true)
  _r=$(printf '%s\n' "$_diff" | grep -cE "^-[^-].*($_sg_pattern)" || true)
  _added=$((_added + ${_a:-0}))
  _removed=$((_removed + ${_r:-0}))
  if [ "${_a:-0}" -gt 0 ] && [ -z "$_added_sample" ]; then
    _added_sample=$(printf '%s\n' "$_diff" | grep -E "^\+[^+].*($_sg_pattern)" | head -3 | sed "s|^+|$f: |")
  fi
done <<EOF
$changed_files
EOF

if [ "$_added" -le "$_removed" ]; then exit 0; fi

_net=$((_added - _removed))
_msg="Suppression gate: this session added ${_added} lint/type suppressions and removed ${_removed} (net +${_net}).
${_added_sample}
Every tolerated suppression is a pattern the next LLM session will imitate and spread. Fix the violation at source instead. If a suppression is genuinely required, keep it minimal with a reason on the same line and rerun with SUPPRESSION_GATE=0."

if type hook_block &>/dev/null; then
  hook_block "$_msg" "suppression-gate"
else
  _escaped=$(printf '%s' "$_msg" | jq -Rs .)
  echo "{\"suppressOutput\":true,\"systemMessage\":$_escaped}" >&2
  exit 2
fi
