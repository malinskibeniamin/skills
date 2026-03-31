#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/_hook-lib.sh"

hook_parse_bash

# Check if this is a git commit command with -m flag
if ! echo "$command" | grep -qE 'git\s+commit\b.*\s+-m\s'; then
  exit 0
fi

# Extract the commit message from -m "..." or -m '...'
msg=""
msg=$(echo "$command" | sed -n 's/.*-m[[:space:]]*"\([^"]*\)".*/\1/p')
if [ -z "$msg" ]; then
  msg=$(echo "$command" | sed -n "s/.*-m[[:space:]]*'\\([^']*\\)'.*/\\1/p")
fi

if [ -z "$msg" ]; then
  # Could not extract message — allow through (might be -m with variable, heredoc, etc.)
  exit 0
fi

# Split into subject line (first line)
subject=$(echo "$msg" | head -1)

# ── Validate type ──────────────────────────────────────────────
valid_types="feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert"

if ! echo "$subject" | grep -qE "^($valid_types)\("; then
  # Check if type is present but without scope
  if echo "$subject" | grep -qE "^($valid_types):"; then
    hook_deny "Commit message missing scope.\nAdd scope in parentheses: type(scope): description."
  fi
  hook_deny "Invalid or missing commit type.\nUse: feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert."
fi

# ── Validate scope ─────────────────────────────────────────────
if ! echo "$subject" | grep -qE "^($valid_types)\([a-z][a-z0-9_-]*\):"; then
  hook_deny "Invalid scope format.\nScope must be lowercase alphanumeric with hyphens/underscores: type(my-scope): desc."
fi

# ── Extract description ────────────────────────────────────────
desc=$(echo "$subject" | sed -E "s/^($valid_types)\([a-z][a-z0-9_-]*\):[[:space:]]*//" )

if [ -z "$desc" ]; then
  hook_deny "Commit message missing description after type(scope):.\nAdd a description: feat(webui): add user profile page."
fi

# ── Validate description: lowercase first letter ──────────────
first_char=$(echo "$desc" | cut -c1)
if echo "$first_char" | grep -qE '[A-Z]'; then
  hook_deny "Commit description must start with a lowercase letter.\nChange the first character to lowercase."
fi

# ── Validate description: no trailing period ───────────────────
if echo "$desc" | grep -qE '\.$'; then
  hook_deny "Commit description must not end with a period.\nRemove the trailing period."
fi

# ── Validate description length (5-72 chars) ──────────────────
desc_len=${#desc}
if [ "$desc_len" -lt 5 ]; then
  hook_deny "Commit description too short ($desc_len chars, minimum 5).\nWrite a more descriptive summary."
fi

if [ "$desc_len" -gt 72 ]; then
  hook_deny "Commit description too long ($desc_len chars, maximum 72).\nShorten it or move details to the commit body."
fi

# ── Suggest body for feat/fix ──────────────────────────────────
body=$(echo "$msg" | tail -n +2 | sed '/^$/d')
commit_type=$(echo "$subject" | sed -E "s/^($valid_types)\(.*/\1/")

if [ -z "$body" ] && { [ "$commit_type" = "feat" ] || [ "$commit_type" = "fix" ]; }; then
  echo "{\"decision\":\"allow\",\"reason\":\"Consider adding a commit body for $commit_type commits to explain context.\"}" >&2
  exit 0
fi

exit 0
