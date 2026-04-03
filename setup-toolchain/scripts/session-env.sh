#!/bin/bash
set -euo pipefail

# ── Frontend project detection ───────────────────────────────────
# These skills are for React/TypeScript frontend projects.
# Warn if installed in the wrong directory (backend, Go, root of monorepo).

if [ ! -f "package.json" ]; then
  echo '{"hookSpecificOutput":{"additionalContext":"WARNING: No package.json found. These skills are designed for frontend projects with React + TypeScript. If this is a monorepo, install in the frontend app directory (e.g., apps/web-ui/)."}}' >&2
fi

if [ -f "package.json" ] && ! grep -qE '"react"|"react-dom"' package.json 2>/dev/null; then
  echo '{"hookSpecificOutput":{"additionalContext":"WARNING: No React dependency in package.json. These skills are optimized for React/TypeScript projects. Some hooks may not be relevant here."}}' >&2
fi

# Set environment variables for LLM-friendly defaults
echo "export PKG_MANAGER=bun" >> "$CLAUDE_ENV_FILE"
echo "export LINTER=biome" >> "$CLAUDE_ENV_FILE"
echo "export TEST_RUNNER=vitest" >> "$CLAUDE_ENV_FILE"

# Prevent OOM on large test suites, builds, and type checks
echo "export NODE_OPTIONS=--max-old-space-size=8192" >> "$CLAUDE_ENV_FILE"

# Clean up stale session directories from previous sessions (safe: /tmp/ only, specific prefix)
find /tmp -maxdepth 1 -name "claude-session-*" -type d -mmin +60 -exec rm -r {} + 2>/dev/null || true

exit 0
