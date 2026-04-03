#!/bin/bash
set -euo pipefail

# Skip entirely if no redpanda-ui directory exists in the repo
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
if [ ! -d "$repo_root/redpanda-ui" ] && [ ! -d "$repo_root/src/redpanda-ui" ]; then
  exit 0
fi

# Check if any redpanda-ui component files were changed
changed=$(git diff --name-only HEAD 2>/dev/null || true)

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
