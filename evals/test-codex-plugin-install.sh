# Real Codex CLI integration test. CI sets CODEX_PLUGIN_INSTALL_REQUIRED=1
# after installing the pinned CLI; local runs skip when Codex is unavailable.

_codex_install_test="$REPO_ROOT/scripts/test-codex-plugin-install.sh"
_codex_install_bin="${CODEX_BIN:-$(command -v codex 2>/dev/null || true)}"

if [ -z "$_codex_install_bin" ]; then
  if [ "${CODEX_PLUGIN_INSTALL_REQUIRED:-0}" = "1" ]; then
    echo "  FAIL  Codex CLI is required for plugin installation testing"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: Codex CLI missing for plugin installation test"
  else
    echo "  SKIP  Codex plugin installation test (Codex CLI unavailable)"
    SKIP=$((SKIP + 1))
  fi
elif [ ! -x "$_codex_install_test" ]; then
  echo "  FAIL  Codex plugin installation test is executable"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: missing executable scripts/test-codex-plugin-install.sh"
elif CODEX_BIN="$_codex_install_bin" "$_codex_install_test"; then
  echo "  PASS  Codex installs the local frontend-skills plugin"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Codex installs the local frontend-skills plugin"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Codex plugin installation integration test"
fi
