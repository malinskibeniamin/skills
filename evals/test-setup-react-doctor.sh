# Evals for setup-react-doctor skill

SCRIPT="$REPO_ROOT/frontend-starter-kit/references/react-doctor/scripts/react-doctor-stop.sh"
SKILL_DIR="$REPO_ROOT/frontend-starter-kit/references/react-doctor"
CONFIG="$SKILL_DIR/doctor.config.json"
DESIGN_RULES="$SKILL_DIR/design-rules-0.9.2.txt"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/README.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_file_eval "$CONFIG" "doctor.config.json exists"
run_file_eval "$DESIGN_RULES" "released design-rule inventory exists"
run_executable_eval "$SCRIPT" "react-doctor-stop.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/README.md" "react-doctor" "SKILL.md mentions react-doctor"
run_content_eval "$SKILL_DIR/README.md" "biome-overlapping" "SKILL.md mentions biome-overlapping rules"
run_content_eval "$SKILL_DIR/README.md" "react-doctor@0\\.9\\.2" "SKILL.md pins the released npm version"
run_content_eval "$SKILL_DIR/README.md" "doctor.config.json" "SKILL.md mentions config file"
run_content_eval "$SKILL_DIR/README.md" "doctor:full" "SKILL.md provides an advisory full-project scan"

# ── REFERENCE content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "--scope changed" "REFERENCE documents changed scope"
run_content_eval "$SKILL_DIR/REFERENCE.md" "--blocking warning" "REFERENCE documents the strict diagnostic gate"
run_content_eval "$SKILL_DIR/REFERENCE.md" "--no-score" "REFERENCE disables score telemetry"
run_content_eval "$SCRIPT" "bun run doctor" "script uses package.json script"
run_content_eval "$SCRIPT" "hook_(block|stop_block|stop_finding)|decision.*block|exit 2" "script blocks on failure"

# ── Config contract ──────────────────────────────────────────────

run_content_eval "$CONFIG" '"scope": "changed"' "config scans changed diagnostics"
run_content_eval "$CONFIG" '"blocking": "warning"' "config blocks warning diagnostics"
run_content_eval "$CONFIG" '"noScore": true' "config disables score telemetry"
run_content_eval "$CONFIG" '"warnings": true' "config keeps warning diagnostics visible"
run_content_eval "$CONFIG" '"share": false' "config disables shared reports"
run_content_eval "$CONFIG" '"respectInlineDisables": false' "config audits inline suppressions"
run_content_eval "$CONFIG" '"deadCode": true' "config enables whole-project dead-code analysis"
run_content_eval "$CONFIG" '"react-native"' "config excludes the inapplicable React Native family"
run_content_eval "$CONFIG" '"react-doctor/no-outline-none": "error"' "config opts in to outline enforcement"
run_content_eval "$CONFIG" '"react-doctor/no-disabled-zoom": "error"' "config opts in to zoom enforcement"
run_content_eval "$CONFIG" '"react-doctor/no-aria-invalid-without-description": "error"' "config owns invalid-control descriptions"
run_content_eval "$CONFIG" '"includeTags"' "config promotes the complete design family to CI"
run_content_eval "$CONFIG" '"react-doctor/no-danger": "warn"' "config owns dangerous React HTML sinks"
run_content_eval "$CONFIG" '"react-doctor/prefer-function-component": "warn"' "config owns class-component guidance"
run_content_eval "$CONFIG" '"react-doctor/no-clone-element": "warn"' "config owns cloneElement guidance"
run_content_eval "$CONFIG" '"react-doctor/no-cramped-container-padding": "warn"' "config enables contextual design diagnostics"
run_content_eval "$CONFIG" '"react-doctor/no-common-root-font": "warn"' "config enables brand-sensitive design diagnostics"
run_content_eval "$CONFIG" '"react-doctor/ink-prefer-use-paste": "off"' "config explicitly disables terminal-only opt-ins"

_rd_config_errors="config missing"
if [ -f "$CONFIG" ] && [ -f "$DESIGN_RULES" ]; then
  _rd_config_errors=$(jq -r '
    select(
      .blocking != "warning"
      or .warnings != true
      or .share != false
      or .respectInlineDisables != false
      or (.ignore.tags | index("react-native")) == null
      or (.surfaces.ciFailure.includeTags | index("design")) == null
      or (.surfaces.prComment.includeTags | index("design")) == null
      or (.surfaces.score.includeTags | index("design")) == null
      or ([.rules[] | select(. == "off")] | length) != 11
      or (.rules | length) != 183
    )
    | "strict config contract mismatch"
  ' "$CONFIG" 2>/dev/null || echo "invalid config")

  while IFS= read -r _rd_rule; do
    [ -n "$_rd_rule" ] || continue
    _rd_severity=$(jq -r --arg rule "$_rd_rule" '.rules[$rule] // "missing"' "$CONFIG")
    if [ "$_rd_severity" = "missing" ] || [ "$_rd_severity" = "off" ]; then
      _rd_config_errors="${_rd_config_errors}${_rd_config_errors:+
}${_rd_rule}: ${_rd_severity}"
    fi
  done < "$DESIGN_RULES"

  _rd_design_count=$(grep -c '^react-doctor/' "$DESIGN_RULES" || true)
  if [ "$_rd_design_count" -ne 112 ]; then
    _rd_config_errors="${_rd_config_errors}${_rd_config_errors:+
}released design inventory has ${_rd_design_count} rules, expected 112"
  fi
fi
if [ -z "$_rd_config_errors" ]; then
  echo "  PASS  strict config activates all 112 design rules and 728 applicable catalog rules"
  PASS=$((PASS + 1))
else
  echo "  FAIL  strict rule activation is incomplete: $_rd_config_errors"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: strict rule activation is incomplete"
fi

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "bun run doctor" "hook uses package.json script (not bunx)"
run_content_eval "$SCRIPT" "git diff --name-only" "hook checks for changed files"
run_content_eval "$SCRIPT" "tsx|jsx" "hook filters React files"
run_content_eval "$SCRIPT" "scripts.*doctor" "hook skips when doctor script missing"
run_content_eval "$SCRIPT" "blocking diagnostics" "hook treats doctor warnings and errors as blocking findings"
run_content_eval "$SCRIPT" "No downgrade-to-allow" "hook does not downgrade repeated failures to allow"
run_content_eval "$SCRIPT" "hook_session_changed_files" "hook uses session-scoped file detection"
run_content_eval "$SCRIPT" "--scope changed" "hook uses the current changed-scope flag"
run_content_eval "$SCRIPT" "--include-untracked" "hook includes new files"
run_content_eval "$SCRIPT" "--blocking warning" "hook delegates strict warning blocking to React Doctor"
run_content_eval "$SCRIPT" "--no-score" "hook avoids score-only output and telemetry"

if grep -qE -- '--diff|--score([^a-z-]|$)|ratchet baseline|_transferred_hits' "$SCRIPT"; then
  echo "  FAIL  hook still parses deprecated diff or score output"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: hook still parses deprecated diff or score output"
else
  echo "  PASS  hook no longer parses deprecated diff or score output"
  PASS=$((PASS + 1))
fi

# ── Stop hook behavioral test ───────────────────────────────────

# react-doctor-stop.sh should exit 0 when no React files changed
_rd_tmpdir=$(mktemp -d /tmp/react-doctor-eval-XXXXXX)
cd "$_rd_tmpdir"
git init -q && git commit --allow-empty -m "init" -q
actual_exit=0
"$SCRIPT" > /dev/null 2>&1 || actual_exit=$?
cd "$REPO_ROOT"
rm -rf "$_rd_tmpdir"

if [ "$actual_exit" -eq 0 ]; then
  echo "  PASS  react-doctor-stop exits 0 on clean repo (no changed React files)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  react-doctor-stop exits $actual_exit on clean repo (expected 0)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: react-doctor-stop exits $actual_exit on clean repo"
fi

# The runnable hook must pass the complete changed-file gate to the package
# script. A fake bun binary records the public CLI boundary without requiring
# React Doctor itself in this repository.
_rd_tmpdir=$(mktemp -d /tmp/react-doctor-eval-XXXXXX)
mkdir -p "$_rd_tmpdir/bin"
cp "$SCRIPT" "$_rd_tmpdir/react-doctor-stop.sh"
cat > "$_rd_tmpdir/bin/bun" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" > "$RD_ARGS_FILE"
exit 0
EOF
chmod +x "$_rd_tmpdir/bin/bun"
cd "$_rd_tmpdir"
git init -q
printf '{"scripts":{"doctor":"react-doctor ."}}\n' > package.json
printf 'export function App() { return <main />; }\n' > App.tsx
git add package.json App.tsx
git -c user.name="React Doctor Eval" -c user.email="react-doctor-eval@example.com" commit -m "fixture" -q
printf 'export function NewPanel() { return <aside />; }\n' > NewPanel.tsx
RD_ARGS_FILE="$_rd_tmpdir/doctor-args" PATH="$_rd_tmpdir/bin:$PATH" "$_rd_tmpdir/react-doctor-stop.sh" >/dev/null 2>&1 || true
cd "$REPO_ROOT"

if grep -qF -- "run doctor -- --scope changed --include-untracked --blocking warning --no-score" "$_rd_tmpdir/doctor-args" 2>/dev/null; then
  echo "  PASS  react-doctor-stop invokes the diagnostic CLI contract for an untracked React file"
  PASS=$((PASS + 1))
else
  echo "  FAIL  react-doctor-stop did not invoke the expected diagnostic CLI contract for an untracked React file"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: react-doctor-stop did not invoke the expected diagnostic CLI contract for an untracked React file"
fi
rm -rf "$_rd_tmpdir"
