#!/bin/bash
set -eo pipefail

# Verify that skills and hooks are properly installed and up-to-date.
# Run from any consumer repo to check installation health.
#
# Usage:
#   bash verify-install.sh                    # check current repo
#   bash verify-install.sh --remote origin    # also check for updates from remote
#   bash verify-install.sh --json             # machine-readable output
#
# Exit codes:
#   0 = all checks pass
#   1 = issues found (details in output)

REMOTE=""
JSON_MODE=false

for arg in "$@"; do
  case "$arg" in
    --remote) REMOTE="${2:-origin}"; shift ;;
    --json) JSON_MODE=true ;;
  esac
  shift 2>/dev/null || true
done

PASS=0
WARN=0
FAIL=0
ISSUES=""

_pass() { PASS=$((PASS + 1)); $JSON_MODE || echo "  PASS  $1"; }
_warn() { WARN=$((WARN + 1)); ISSUES="$ISSUES\n  WARN  $1"; $JSON_MODE || echo "  WARN  $1"; }
_fail() { FAIL=$((FAIL + 1)); ISSUES="$ISSUES\n  FAIL  $1"; $JSON_MODE || echo "  FAIL  $1"; }

$JSON_MODE || echo "=== Skills & Hooks Installation Verification ==="
$JSON_MODE || echo ""

# ── 1. Basic structure ──────────────────────────────────────────

$JSON_MODE || echo "--- Structure ---"

if [ -d ".claude/hooks" ]; then
  _pass ".claude/hooks/ directory exists"
else
  _fail ".claude/hooks/ directory missing"
fi

if [ -f ".claude/settings.json" ]; then
  _pass ".claude/settings.json exists"
else
  _fail ".claude/settings.json missing — no hooks configured"
fi

if [ -f ".claude/hooks/_hook-lib.sh" ]; then
  _pass "_hook-lib.sh shared library present"
  if [ -x ".claude/hooks/_hook-lib.sh" ] || [ -L ".claude/hooks/_hook-lib.sh" ]; then
    _pass "_hook-lib.sh is executable or symlinked"
  else
    _fail "_hook-lib.sh exists but is not executable"
  fi
else
  _fail "_hook-lib.sh missing — all hooks will fail"
fi

# ── 2. Hook scripts ────────────────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Hook Scripts ---"

EXPECTED_HOOKS=(
  "react-rules-check.sh"
  "tailwind-check.sh"
  "accessibility-check.sh"
  "zustand-check.sh"
  "tanstack-router-check.sh"
  "connect-query-check.sh"
  "react-compiler-check.sh"
  "env-validation-check.sh"
  "bundle-guard.sh"
  "orchestration-guidance.sh"
  "enforce-toolchain.sh"
  "llm-test-flags.sh"
  "conventional-commits-check.sh"
  "llm-truncate.sh"
  "biome-autofix.sh"
  "typecheck-stop.sh"
  "orchestration-stop.sh"
  "violation-summary-stop.sh"
  "session-env.sh"
  "llm-env.sh"
  "user-prompt-context.sh"
  "intent-detect.sh"
  "post-compact-context.sh"
)

installed=0
missing=0
for hook in "${EXPECTED_HOOKS[@]}"; do
  if [ -f ".claude/hooks/$hook" ] || [ -L ".claude/hooks/$hook" ]; then
    if [ -x ".claude/hooks/$hook" ] || [ -L ".claude/hooks/$hook" ]; then
      installed=$((installed + 1))
    else
      _fail "$hook exists but is not executable"
      missing=$((missing + 1))
    fi
  else
    _warn "$hook not installed"
    missing=$((missing + 1))
  fi
done

if [ $missing -eq 0 ]; then
  _pass "All $installed hook scripts installed and executable"
else
  _warn "$installed of ${#EXPECTED_HOOKS[@]} hooks installed ($missing missing)"
fi

# ── 3. Settings.json hook wiring ────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Settings Wiring ---"

if [ -f ".claude/settings.json" ]; then
  # Check for git root resolution pattern
  if grep -q 'git rev-parse --show-toplevel' ".claude/settings.json" 2>/dev/null; then
    _pass "Hook paths use git root resolution (portable)"
  elif grep -q '\.claude/hooks/' ".claude/settings.json" 2>/dev/null; then
    _warn "Hook paths use relative paths — may break from subdirectories. Update to git root resolution pattern."
  fi

  # Count configured hooks
  hook_count=$(grep -c '"command"' ".claude/settings.json" 2>/dev/null || echo "0")
  if [ "$hook_count" -gt 0 ]; then
    _pass "$hook_count hooks configured in settings.json"
  else
    _fail "No hooks configured in settings.json"
  fi

  # Check for key lifecycle events
  for event in "SessionStart" "UserPromptSubmit" "PreToolUse" "PostToolUse" "Stop"; do
    if grep -q "\"$event\"" ".claude/settings.json" 2>/dev/null; then
      _pass "$event event configured"
    else
      _warn "$event event not configured"
    fi
  done
fi

# ── 4. Codex compatibility (optional) ──────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Codex Compatibility ---"

if [ -f ".codex/hooks.json" ]; then
  _pass ".codex/hooks.json exists"
  if [ -f ".codex/hooks/codex-batch-check.sh" ] || [ -L ".codex/hooks/codex-batch-check.sh" ]; then
    _pass "codex-batch-check.sh installed"
  else
    _warn "codex-batch-check.sh missing — Codex Stop hook won't run Edit|Write checks"
  fi
else
  _warn ".codex/hooks.json not found — Codex hooks not configured (install codex-compat skill)"
fi

if [ -f "AGENTS.md" ]; then
  _pass "AGENTS.md exists"
else
  _warn "AGENTS.md not found — Codex soft guidance not configured"
fi

# ── 5. Dependencies ─────────────────────────────────────────────

$JSON_MODE || echo ""
$JSON_MODE || echo "--- Dependencies ---"

if command -v jq &>/dev/null; then
  _pass "jq available (required by hook-lib.sh)"
else
  _fail "jq not installed — hooks will fail. Install: brew install jq"
fi

if command -v bun &>/dev/null; then
  _pass "bun available"
else
  _warn "bun not found — toolchain hooks expect bun as package manager"
fi

if [ -f "package.json" ]; then
  _pass "package.json found (frontend project)"
  if grep -q '"react"' package.json 2>/dev/null; then
    _pass "React dependency found"
  else
    _warn "No React dependency — some hooks may not be relevant"
  fi
else
  _warn "No package.json — hooks are designed for frontend projects"
fi

# ── 6. Version check (optional, with --remote) ─────────────────

if [ -n "$REMOTE" ]; then
  $JSON_MODE || echo ""
  $JSON_MODE || echo "--- Version Check (remote: $REMOTE) ---"

  # Check if any hook is a symlink pointing to a skills repo
  skills_repo=""
  for hook in ".claude/hooks/react-rules-check.sh" ".claude/hooks/enforce-toolchain.sh"; do
    if [ -L "$hook" ]; then
      target=$(readlink "$hook" 2>/dev/null || true)
      if echo "$target" | grep -q "skills"; then
        skills_repo=$(echo "$target" | sed 's|/setup-.*||;s|/shared/.*||')
        break
      fi
    fi
  done

  if [ -n "$skills_repo" ] && [ -d "$skills_repo/.git" ]; then
    local_hash=$(cd "$skills_repo" && git rev-parse HEAD 2>/dev/null || echo "unknown")
    remote_hash=$(cd "$skills_repo" && git ls-remote "$REMOTE" HEAD 2>/dev/null | cut -f1 || echo "unknown")

    if [ "$local_hash" = "unknown" ] || [ "$remote_hash" = "unknown" ]; then
      _warn "Could not check version — git remote unreachable"
    elif [ "$local_hash" = "$remote_hash" ]; then
      _pass "Skills repo is up-to-date (${local_hash:0:7})"
    else
      local_date=$(cd "$skills_repo" && git log -1 --format=%ci HEAD 2>/dev/null || echo "unknown")
      remote_date=$(cd "$skills_repo" && git log -1 --format=%ci "$REMOTE/main" 2>/dev/null || echo "unknown")
      _warn "Skills repo is behind remote. Local: ${local_hash:0:7} ($local_date) Remote: ${remote_hash:0:7}"
      _warn "Run: cd $skills_repo && git pull"
    fi
  else
    _warn "Could not locate skills source repo — hooks may be copies (not symlinks)"
  fi
fi

# ── Summary ─────────────────────────────────────────────────────

$JSON_MODE || echo ""

if $JSON_MODE; then
  echo "{\"pass\":$PASS,\"warn\":$WARN,\"fail\":$FAIL}"
else
  echo "=== Summary: $PASS passed, $WARN warnings, $FAIL failures ==="
  if [ $FAIL -gt 0 ]; then
    echo ""
    echo "Failures require action — hooks may not work correctly."
  elif [ $WARN -gt 0 ]; then
    echo ""
    echo "Warnings are non-critical but may affect coverage."
  else
    echo ""
    echo "All checks passed. Installation is healthy."
  fi
fi

[ $FAIL -eq 0 ]
