#!/bin/bash
set -euo pipefail

# ── Frontend project detection ───────────────────────────────────
# These skills are for React/TypeScript frontend projects.
# Warn if installed in the wrong directory (backend, Go, root of monorepo).

if [ ! -f "package.json" ]; then
  echo '{"hookSpecificOutput":{"additionalContext":"WARNING: No package.json. Skills need React+TS frontend. Monorepo? Install in app dir (apps/web-ui/)."}}' >&2
fi

if [ -f "package.json" ] && ! grep -qE '"react"|"react-dom"' package.json 2>/dev/null; then
  echo '{"hookSpecificOutput":{"additionalContext":"WARNING: No React in package.json. Some hooks may not apply."}}' >&2
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

# ── Session directory for state tracking ──────────────────────────
_session_dir="/tmp/hook-session-${CLAUDE_SESSION_ID:-${CODEX_SESSION_ID:-$$}}"
mkdir -p "$_session_dir" 2>/dev/null || true

# ── Capture dirty-files baseline (which files are already uncommitted) ──
# Used by Stop hooks to exclude files dirty before this session started.
git diff --name-only HEAD > "$_session_dir/dirty-files-baseline" 2>/dev/null || touch "$_session_dir/dirty-files-baseline"

# ── Capture typecheck baseline (background, no latency) ──────────
# Used by typecheck-stop.sh to distinguish pre-existing errors from
# errors introduced by this session. Runs in background so SessionStart
# returns immediately.
if [ -f "package.json" ] && jq -e '.scripts["type:check"]' package.json >/dev/null 2>&1; then
  (bun run type:check 2>&1 | grep -E '^.+\.(ts|tsx)\([0-9]+,' | sort > "$_session_dir/typecheck-baseline" 2>/dev/null || touch "$_session_dir/typecheck-baseline") &
fi

# ── Capture test timing baseline (background, no latency) ────────
# Used by test-perf-stop.sh to detect test performance changes.
# Runs each vitest config found at project root, extracts per-test
# fullName and duration (ms) via JSON reporter.
_vitest_configs=$(find . -maxdepth 1 -name 'vitest.config.*' 2>/dev/null | head -5)
if [ -n "$_vitest_configs" ] && command -v jq >/dev/null 2>&1; then
  (
    : > "$_session_dir/test-timing-baseline.tsv"
    for cfg in $_vitest_configs; do
      bun vitest --run --reporter=json --config "$cfg" 2>/dev/null \
        | jq -r '.testResults[]?.assertionResults[]? | [.fullName, (.duration // 0 | tostring)] | @tsv' \
        >> "$_session_dir/test-timing-baseline.tsv" 2>/dev/null || true
    done
  ) &
fi

exit 0
