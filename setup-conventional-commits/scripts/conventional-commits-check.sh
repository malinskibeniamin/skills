#!/bin/bash
set -euo pipefail

# PreToolUse hook: validate conventional commit format on git commit -m "..."
# Reads stdin JSON with tool_name "Bash" and tool_input.command

input=$(cat)
tool_name=$(echo "$input" | jq -r '.tool_name // empty')

if [ "$tool_name" != "Bash" ]; then
  exit 0
fi

command=$(echo "$input" | jq -r '.tool_input.command // empty')

if [ -z "$command" ]; then
  exit 0
fi

# Check if this is a git commit command with -m flag
if ! echo "$command" | grep -qE 'git\s+commit\b.*\s+-m\s'; then
  exit 0
fi

# Extract the commit message from -m "..." or -m '...'
# Try double quotes first, then single quotes
msg=""
msg=$(echo "$command" | sed -n 's/.*-m[[:space:]]*"\([^"]*\)".*/\1/p')
if [ -z "$msg" ]; then
  msg=$(echo "$command" | sed -n "s/.*-m[[:space:]]*'\\([^']*\\)'.*/\\1/p")
fi

if [ -z "$msg" ]; then
  # Could not extract message — allow through (might be -m with variable, etc.)
  exit 0
fi

# Split into subject line (first line) and body
subject=$(echo "$msg" | head -1)

# ── Validate type ──────────────────────────────────────────────
valid_types="feat|fix|refactor|style|test|docs|chore|perf|ci|build|revert"

if ! echo "$subject" | grep -qE "^($valid_types)\("; then
  # Check if type is present but without scope
  if echo "$subject" | grep -qE "^($valid_types):"; then
    echo "{\"decision\":\"block\",\"reason\":\"Commit message missing scope. Expected format: type(scope): description\\n\\nGot: $subject\\n\\nAdd a scope in parentheses, e.g.: feat(webui): add feature\"}" >&2
    exit 2
  fi
  echo "{\"decision\":\"block\",\"reason\":\"Invalid or missing commit type. Expected format: type(scope): description\\n\\nGot: $subject\\n\\nValid types: feat, fix, refactor, style, test, docs, chore, perf, ci, build, revert\"}" >&2
  exit 2
fi

# ── Validate scope ─────────────────────────────────────────────
if ! echo "$subject" | grep -qE "^($valid_types)\([a-z][a-z0-9_-]*\):"; then
  echo "{\"decision\":\"block\",\"reason\":\"Invalid scope format. Scope must be lowercase alphanumeric (with hyphens/underscores).\\n\\nGot: $subject\\n\\nExample: feat(webui): add feature\"}" >&2
  exit 2
fi

# ── Extract description ────────────────────────────────────────
desc=$(echo "$subject" | sed -E "s/^($valid_types)\([a-z][a-z0-9_-]*\):[[:space:]]*//" )

if [ -z "$desc" ]; then
  echo "{\"decision\":\"block\",\"reason\":\"Commit message missing description after type(scope):\\n\\nGot: $subject\\n\\nAdd a description: feat(webui): add user profile page\"}" >&2
  exit 2
fi

# ── Validate description: lowercase first letter ──────────────
first_char=$(echo "$desc" | cut -c1)
if echo "$first_char" | grep -qE '[A-Z]'; then
  echo "{\"decision\":\"block\",\"reason\":\"Commit description must start with a lowercase letter.\\n\\nGot: $subject\\n\\nFix: $(echo "$subject" | sed -E "s/^(($valid_types)\([a-z][a-z0-9_-]*\):[[:space:]]*)([A-Z])/\1$(echo "$first_char" | tr '[:upper:]' '[:lower:]')/" )\"}" >&2
  exit 2
fi

# ── Validate description: no trailing period ───────────────────
if echo "$desc" | grep -qE '\.$'; then
  echo "{\"decision\":\"block\",\"reason\":\"Commit description must not end with a period.\\n\\nGot: $subject\\n\\nRemove the trailing period.\"}" >&2
  exit 2
fi

# ── Validate description length (5-72 chars) ──────────────────
desc_len=${#desc}
if [ "$desc_len" -lt 5 ]; then
  echo "{\"decision\":\"block\",\"reason\":\"Commit description too short ($desc_len chars). Minimum 5 characters.\\n\\nGot: $subject\"}" >&2
  exit 2
fi

if [ "$desc_len" -gt 72 ]; then
  echo "{\"decision\":\"block\",\"reason\":\"Commit description too long ($desc_len chars). Maximum 72 characters.\\n\\nGot: $subject\\n\\nShorten the description or move details to the commit body.\"}" >&2
  exit 2
fi

# ── Suggest body for feat/fix ──────────────────────────────────
body=$(echo "$msg" | tail -n +2 | sed '/^$/d')
commit_type=$(echo "$subject" | sed -E "s/^($valid_types)\(.*/\1/")

if [ -z "$body" ] && { [ "$commit_type" = "feat" ] || [ "$commit_type" = "fix" ]; }; then
  echo "{\"decision\":\"allow\",\"reason\":\"Valid commit format. Consider adding a body for $commit_type commits to explain the why/context.\"}" >&2
  exit 0
fi

exit 0
