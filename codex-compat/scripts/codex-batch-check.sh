#!/bin/bash
set -euo pipefail

# Stop hook for Codex: batch-run all PostToolUse Edit|Write checks on changed files.
# Codex doesn't support Edit|Write matchers, so we run them at Stop instead.

# Find all changed JS/TS files
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
changed_files=$(git diff --name-only HEAD 2>/dev/null | grep -E '\.(js|jsx|ts|tsx|mjs|mts|cjs|cts)$' || true)

# Also check package.json changes (for bundle-guard)
changed_pkg=$(git diff --name-only HEAD 2>/dev/null | grep -E 'package\.json$' || true)

if [ -z "$changed_files" ] && [ -z "$changed_pkg" ]; then
  exit 0
fi

# Collect all PostToolUse hook scripts from .claude/hooks/
hooks_dir="$repo_root/.claude/hooks"
if [ ! -d "$hooks_dir" ]; then
  exit 0
fi

errors=""

# Run each *-check.sh hook on each changed JS/TS file
for file in $changed_files; do
  abs_path="$repo_root/$file"
  [ -f "$abs_path" ] || continue

  for hook in "$hooks_dir"/*-check.sh; do
    [ -x "$hook" ] || continue

    # Simulate a Write tool call — same JSON format the hooks expect
    input="{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$abs_path\"}}"

    hook_stderr=""
    hook_exit=0
    hook_stderr=$(echo "$input" | "$hook" 2>&1 >/dev/null) || hook_exit=$?

    if [ $hook_exit -ne 0 ] && [ -n "$hook_stderr" ]; then
      msg=$(echo "$hook_stderr" | grep -o '"systemMessage":"[^"]*"' | head -1 | sed 's/"systemMessage":"//;s/"$//' || true)
      if [ -n "$msg" ]; then
        hook_name=$(basename "$hook")
        errors="$errors\n[$hook_name] $file: $msg"
      fi
    fi
  done
done

# Run bundle-guard on changed package.json files
for pkg in $changed_pkg; do
  abs_path="$repo_root/$pkg"
  [ -f "$abs_path" ] || continue

  bundle_guard="$hooks_dir/bundle-guard.sh"
  if [ -x "$bundle_guard" ]; then
    input="{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$abs_path\"}}"
    hook_stderr=""
    hook_exit=0
    hook_stderr=$(echo "$input" | "$bundle_guard" 2>&1 >/dev/null) || hook_exit=$?

    if [ $hook_exit -ne 0 ] && [ -n "$hook_stderr" ]; then
      msg=$(echo "$hook_stderr" | grep -o '"systemMessage":"[^"]*"' | head -1 | sed 's/"systemMessage":"//;s/"$//' || true)
      if [ -n "$msg" ]; then
        errors="$errors\n[bundle-guard] $pkg: $msg"
      fi
    fi
  done
done

if [ -n "$errors" ]; then
  truncated=$(printf '%b' "$errors" | head -30)
  escaped=$(printf '%s' "$truncated" | jq -Rs .)
  echo "{\"decision\":\"block\",\"reason\":\"Code quality checks found issues. Fix these before finishing:\\n\"$escaped\"\"}" >&2
  exit 2
fi

exit 0
