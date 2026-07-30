# Evals for setup-react-doctor skill

SCRIPT="$REPO_ROOT/frontend-starter-kit/references/react-doctor/scripts/react-doctor-stop.sh"
SKILL_DIR="$REPO_ROOT/frontend-starter-kit/references/react-doctor"
CONFIG="$SKILL_DIR/doctor.config.json"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/README.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_file_eval "$CONFIG" "doctor.config.json exists"
run_executable_eval "$SCRIPT" "react-doctor-stop.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/README.md" "react-doctor" "SKILL.md mentions react-doctor"
run_content_eval "$SKILL_DIR/README.md" "biome-overlapping" "SKILL.md mentions biome-overlapping rules"
run_content_eval "$SKILL_DIR/README.md" "react-doctor@0\\.9\\.2" "SKILL.md pins the released npm version"
run_content_eval "$SKILL_DIR/README.md" "doctor.config.json" "SKILL.md mentions config file"

# ── REFERENCE content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "--scope changed" "REFERENCE documents changed scope"
run_content_eval "$SKILL_DIR/REFERENCE.md" "--blocking error" "REFERENCE documents the diagnostic gate"
run_content_eval "$SKILL_DIR/REFERENCE.md" "--no-score" "REFERENCE disables score telemetry"
run_content_eval "$SCRIPT" "bun run doctor" "script uses package.json script"
run_content_eval "$SCRIPT" "hook_(block|stop_block|stop_finding)|decision.*block|exit 2" "script blocks on failure"

# ── Config contract ──────────────────────────────────────────────

run_content_eval "$CONFIG" '"scope": "changed"' "config scans changed diagnostics"
run_content_eval "$CONFIG" '"blocking": "error"' "config blocks error diagnostics"
run_content_eval "$CONFIG" '"noScore": true' "config disables score telemetry"
run_content_eval "$CONFIG" '"react-doctor/no-outline-none": "error"' "config opts in to outline enforcement"
run_content_eval "$CONFIG" '"react-doctor/no-disabled-zoom": "error"' "config opts in to zoom enforcement"
run_content_eval "$CONFIG" '"react-doctor/no-aria-invalid-without-description": "error"' "config owns invalid-control descriptions"
run_content_eval "$CONFIG" '"includeRules"' "config promotes blocking design rules to CI"

_rd_config_errors="config missing"
if [ -f "$CONFIG" ]; then
  _rd_config_errors=$(jq -r '
  [
    "react-doctor/no-disabled-zoom",
    "react-doctor/no-focus-in-animation-completion-handler",
    "react-doctor/no-hover-only-reveal",
    "react-doctor/no-invisible-focus-control",
    "react-doctor/no-low-contrast-inline-style",
    "react-doctor/no-outline-none",
    "react-doctor/no-pointer-disabled-enabled-control",
    "react-doctor/no-smooth-scroll-without-reduced-motion",
    "react-doctor/no-undersized-icon-button",
    "react-doctor/no-clipped-overlay",
    "react-doctor/no-fixed-inside-transformed-ancestor",
    "react-doctor/no-inert-sticky-position",
    "react-doctor/no-deprecated-tailwind-class",
    "react-doctor/no-dynamic-tailwind-class-fragment",
    "react-doctor/no-full-viewport-width",
    "react-doctor/no-layout-shifting-interaction-state",
    "react-doctor/no-mixed-animation-owners",
    "react-doctor/no-repeated-placeholder-navigation",
    "react-doctor/no-svg-currentcolor-with-fill-class",
    "react-doctor/prefer-dvh-over-vh",
    "react-doctor/styled-components-duplicate-css-property-in-block",
    "react-doctor/no-img-without-dimensions",
    "react-doctor/no-layout-transition-inline",
    "react-doctor/no-tailwind-layout-transition"
  ]
  | map(select(. as $rule | $config.rules[$rule] != "error"
    or ($config.surfaces.ciFailure.includeRules | index($rule)) == null))
  | .[]
' --argjson config "$(cat "$CONFIG")" "$CONFIG" 2>/dev/null || echo "invalid config")
fi
if [ -z "$_rd_config_errors" ]; then
  echo "  PASS  every blocking design rule is enabled and reaches the CI surface"
  PASS=$((PASS + 1))
else
  echo "  FAIL  blocking design rules missing from config or CI surface: $_rd_config_errors"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: blocking design rules missing from config or CI surface"
fi

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "bun run doctor" "hook uses package.json script (not bunx)"
run_content_eval "$SCRIPT" "git diff --name-only" "hook checks for changed files"
run_content_eval "$SCRIPT" "tsx|jsx" "hook filters React files"
run_content_eval "$SCRIPT" "scripts.*doctor" "hook skips when doctor script missing"
run_content_eval "$SCRIPT" "blocking errors" "hook treats doctor errors as blocking findings"
run_content_eval "$SCRIPT" "No downgrade-to-allow" "hook does not downgrade repeated failures to allow"
run_content_eval "$SCRIPT" "hook_session_changed_files" "hook uses session-scoped file detection"
run_content_eval "$SCRIPT" "--scope changed" "hook uses the current changed-scope flag"
run_content_eval "$SCRIPT" "--include-untracked" "hook includes new files"
run_content_eval "$SCRIPT" "--blocking error" "hook delegates blocking to React Doctor"
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

if grep -qF -- "run doctor -- --scope changed --include-untracked --blocking error --no-score" "$_rd_tmpdir/doctor-args" 2>/dev/null; then
  echo "  PASS  react-doctor-stop invokes the diagnostic CLI contract for an untracked React file"
  PASS=$((PASS + 1))
else
  echo "  FAIL  react-doctor-stop did not invoke the expected diagnostic CLI contract for an untracked React file"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: react-doctor-stop did not invoke the expected diagnostic CLI contract for an untracked React file"
fi
rm -rf "$_rd_tmpdir"
