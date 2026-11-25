#!/bin/bash

# Fast cross-host Antigravity health and schema contract gate for evals/run.sh.
# Full bundle build + ACP/IDE protocol replay runs via `bun run test:antigravity`
# in its dedicated CI step to avoid duplicating 90s bundle builds inside evals/run.sh.

run_file_eval "$REPO_ROOT/GEMINI.md" "root GEMINI.md host rules exist"
run_file_eval "$REPO_ROOT/config/antigravity-model-routing.json" "Antigravity model routing config exists"
run_file_eval "$REPO_ROOT/plugins/frontend-skills-antigravity/rules/AGENTS.md" "Antigravity plugin rules/AGENTS.md exists"
run_file_eval "$REPO_ROOT/plugins/frontend-skills-antigravity/assets/logo.svg" "Antigravity plugin logo exists"

if bun run "$REPO_ROOT/scripts/harness-health.ts" --check >/dev/null 2>&1; then
  echo "  PASS  Cross-host harness health checks pass"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Cross-host harness health checks failed (run: bun run harness:health --check)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Cross-host harness health checks"
fi
