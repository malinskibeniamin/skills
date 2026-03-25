#!/bin/bash
set -euo pipefail

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

exit 0
