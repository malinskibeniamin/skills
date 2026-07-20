#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# CwdChanged: the session moved to a different directory (/cd, or Claude ran
# cd). Session state captured at SessionStart is now stale in two ways:
#   1. bound-worktree/bound-branch — every hook asserts against these to
#      prevent cross-worktree leakage; without a rebind, all guards in the
#      new tree misfire as "outside bound worktree".
#   2. DISABLE_FRONTEND_HOOKS — computed from the OLD directory's
#      package.json. Refresh via CLAUDE_ENV_FILE (preambles later Bash).

input=$(cat 2>/dev/null || echo '{}')
new_cwd=$(echo "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$new_cwd" ] && [ -d "$new_cwd" ] || exit 0
cd "$new_cwd" 2>/dev/null || exit 0

_session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
[ -d "$_session_dir" ] || exit 0

_root=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -n "$_root" ]; then
  _root=$(cd "$_root" 2>/dev/null && pwd -P 2>/dev/null || echo "$_root")
  echo "$_root" > "$_session_dir/bound-worktree" 2>/dev/null || true
  git branch --show-current > "$_session_dir/bound-branch" 2>/dev/null || true
fi

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  if [ -f "package.json" ] && ! grep -qE '"react"|"react-dom"' package.json 2>/dev/null; then
    echo "export DISABLE_FRONTEND_HOOKS=1" >> "$CLAUDE_ENV_FILE"
  else
    echo "unset DISABLE_FRONTEND_HOOKS" >> "$CLAUDE_ENV_FILE"
  fi
fi

exit 0
