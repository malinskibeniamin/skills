#!/bin/bash
set -euo pipefail

# Set environment variables for LLM-friendly defaults
echo "export PKG_MANAGER=bun" >> "$CLAUDE_ENV_FILE"
echo "export LINTER=biome" >> "$CLAUDE_ENV_FILE"
echo "export TEST_RUNNER=vitest" >> "$CLAUDE_ENV_FILE"

# Prevent OOM on large test suites, builds, and type checks
echo "export NODE_OPTIONS=--max-old-space-size=8192" >> "$CLAUDE_ENV_FILE"

# Clean up stale session directories from previous sessions (safe: /tmp/ only, specific prefix)
find /tmp -maxdepth 1 -name "claude-session-*" -type d -mmin +60 -exec rm -r {} + 2>/dev/null || true

exit 0
