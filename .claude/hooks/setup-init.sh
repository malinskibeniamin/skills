#!/bin/bash
set -eo pipefail
trap 'exit 0' ERR

# Setup (matchers: init, maintenance): one-time environment prep for
# `claude --init-only` / CI `-p --init|--maintenance` runs. Interactive
# sessions never pay for this.
#   init         — install JS dependencies so first-turn Bash commands
#                  (lint, type:check, tests) work without a cold `bun install`.
#   maintenance  — sweep stale hook-session state and oversized metric logs.

input=$(cat 2>/dev/null || echo '{}')
# Runtime payload carries the mode in .trigger ({"trigger":"init"});
# source/matcher kept as defensive fallbacks only.
mode=$(echo "$input" | jq -r '.trigger // .source // .matcher // empty' 2>/dev/null)

case "$mode" in
  init)
    if [ -f "package.json" ] && [ ! -d "node_modules" ] && command -v bun >/dev/null 2>&1; then
      bun install --frozen-lockfile >/dev/null 2>&1 || bun install >/dev/null 2>&1 || true
    fi
    ;;
  maintenance)
    # Appends do not update directory mtime. Keep any session with state
    # touched in the last 24 hours; remove only wholly stale directories.
    for _stale_dir in /tmp/hook-session-*; do
      [ -d "$_stale_dir" ] || continue
      if [ -z "$(find "$_stale_dir" -mmin -1440 2>/dev/null | head -1)" ]; then
        rm -r "$_stale_dir" 2>/dev/null || true
      fi
    done
    # Rotate metric logs past 10MB; keep the newest half by line count.
    for f in "$HOME"/.claude/hook-metrics/*.jsonl; do
      [ -f "$f" ] || continue
      if [ "$(wc -c < "$f" 2>/dev/null | tr -d ' ')" -gt 10485760 ]; then
        _keep=$(($(wc -l < "$f" | tr -d ' ') / 2))
        tail -n "$_keep" "$f" > "$f.tmp" 2>/dev/null && mv "$f.tmp" "$f" 2>/dev/null || rm -f "$f.tmp"
      fi
    done
    ;;
esac

exit 0
