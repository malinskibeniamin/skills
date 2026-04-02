#!/bin/bash
set -euo pipefail

# Set environment variables for LLM-friendly defaults
echo "export PKG_MANAGER=bun" >> "$CLAUDE_ENV_FILE"
echo "export LINTER=biome" >> "$CLAUDE_ENV_FILE"
echo "export TEST_RUNNER=vitest" >> "$CLAUDE_ENV_FILE"

# Prevent OOM on large test suites, builds, and type checks
echo "export NODE_OPTIONS=--max-old-space-size=8192" >> "$CLAUDE_ENV_FILE"

# Clean up stale session files from previous sessions
rm -f /tmp/claude-hook-violations-* /tmp/claude-session-files-* /tmp/claude-last-stop-* /tmp/claude-review-requested-* 2>/dev/null || true

exit 0
