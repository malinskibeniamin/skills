#!/bin/bash
set -eo pipefail

# Only run in repos that ARE the UI registry (have registry.json at root)
# Consumer repos that USE registry components don't need this check —
# the orchestration-guidance.sh registry sync nudge handles consumers
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [ ! -f "$repo_root/registry.json" ]; then
  exit 0
fi

# Source hook-lib for session-scoped file tracking
source "$(dirname "$0")/source-hook-lib.sh" 2>/dev/null || true

# Session-scoped: only check files this session touched
if type hook_session_changed_files &>/dev/null; then
  changed=$(hook_session_changed_files)
else
  changed=$(git diff --name-only HEAD 2>/dev/null || true)
fi

if [ -z "$changed" ]; then
  exit 0
fi

ui_changed=$(echo "$changed" | grep -E 'redpanda-ui/' || true)

if [ -z "$ui_changed" ]; then
  exit 0
fi

# Check if registry.json was also updated
registry_changed=$(echo "$changed" | grep -F 'registry.json' || true)

if [ -z "$registry_changed" ]; then
  echo '{"decision":"block","reason":"You modified redpanda-ui components but did not rebuild registry.json.\n\n1. Run the registry build command (e.g., bun run build:registry)\n2. Update CHANGELOG.md with the changes\n3. Then finish your response."}' >&2
  exit 2
fi

# Check if CHANGELOG.md was also updated
changelog_changed=$(echo "$changed" | grep -iE 'CHANGELOG' || true)

if [ -z "$changelog_changed" ]; then
  echo '{"decision":"block","reason":"You modified redpanda-ui components and rebuilt registry.json, but CHANGELOG.md was not updated.\n\nAdd a changelog entry describing what changed in the component(s)."}' >&2
  exit 2
fi

exit 0
