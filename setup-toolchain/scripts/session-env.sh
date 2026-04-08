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
# Clean up stale session directories from both harnesses
find /tmp -maxdepth 1 -name "hook-session-*" -type d -mmin +60 -exec rm -r {} + 2>/dev/null || true

# ── Capture typecheck baseline (background, no latency) ──────────
# Used by typecheck-stop.sh to distinguish pre-existing errors from
# errors introduced by this session. Runs in background so SessionStart
# returns immediately.
_session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
mkdir -p "$_session_dir" 2>/dev/null || true
if [ -f "package.json" ] && jq -e '.scripts["type:check"]' package.json >/dev/null 2>&1; then
  (bun run type:check 2>&1 | grep -E '^.+\.(ts|tsx)\([0-9]+,' | sort > "$_session_dir/typecheck-baseline" 2>/dev/null || touch "$_session_dir/typecheck-baseline") &
fi

exit 0
