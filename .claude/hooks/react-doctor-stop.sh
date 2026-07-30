#!/bin/bash
set -eo pipefail

# Escape hatch: when Claude is already responding to a Stop block, do not
# block again -- prevents infinite hostage loops (audit cluster 1).
_sha_in=$(cat); if printf '%s' "$_sha_in" | jq -e '.stop_hook_active == true' >/dev/null 2>&1; then exit 0; fi


# Source hook-lib for session-scoped file tracking
_shim="$(dirname "$0")/source-hook-lib.sh"; if [ -f "$_shim" ]; then . "$_shim" 2>/dev/null || true; fi

# Session-scoped: only check files this session touched.
# Includes .ts: transferred rules (tanstack-query, state-and-effects) fire in plain
# TypeScript files too -- a QueryClient created in a .ts module must still be scanned.
if type hook_session_changed_files &>/dev/null; then
  changed_files=$(hook_session_changed_files "tsx?|jsx")
else
  changed_files=$(
    {
      git diff --name-only HEAD 2>/dev/null
      git ls-files --others --exclude-standard 2>/dev/null
    } | sort -u | grep -E '\.(tsx?|jsx)$' || true
  )
fi

if [ -z "$changed_files" ]; then
  exit 0
fi

# Skip if project doesn't have a doctor script
if [ ! -f "package.json" ] || ! jq -e '.scripts["doctor"]' package.json >/dev/null 2>&1; then
  exit 0
fi

# React Doctor owns diagnostic activation, severity, and CI-surface filtering.
# The wrapper only selects the changed-file scope and translates a failing
# command into the harness Stop protocol.
output=""
exit_code=0
output=$(bun run doctor -- --scope changed --include-untracked --blocking error --no-score 2>&1) || exit_code=$?

# No downgrade-to-allow: doctor errors are blocking findings. If React Doctor cannot
# complete, fix the code, config, or toolchain before continuing.

# Block on errors (non-zero exit)
if [ $exit_code -ne 0 ]; then
  truncated=$(echo "$output" | head -40)
  hook_stop_finding "$(printf "React Doctor found blocking errors. Fix before continuing:\n%s" "$truncated")"
  hook_stop_enforce
fi

hook_stop_enforce
