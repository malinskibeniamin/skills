# The real supported-runtime path is exercised by bun run test:mods in CI.
# Stub only the unavailable older CLI; it must never reach an install command.
_mods_version_root="$(mktemp -d "${TMPDIR:-/tmp}/skills-mods-version.XXXXXX")"
trap 'rm -rf -- "$_mods_version_root"' EXIT
cat >"$_mods_version_root/claude" <<'CLI'
#!/bin/bash
if [ "$1" = --version ]; then
  printf '%s (Claude Code)\n' "$MODS_TEST_VERSION"
else
  touch "$MODS_TEST_COMMAND_MARKER"
  exit 1
fi
CLI
chmod +x "$_mods_version_root/claude"

for _mods_version in 2.1.286 invalid; do
  _mods_exit=0
  _mods_output="$(
    CLAUDE_BIN="$_mods_version_root/claude" MODS_TEST_VERSION="$_mods_version" \
      MODS_TEST_COMMAND_MARKER="$_mods_version_root/installed" \
      bash "$REPO_ROOT/scripts/test-claude-plugin-install.sh" frontend-skills-mods 2>&1
  )" || _mods_exit=$?
  if [ "$_mods_exit" -eq 1 ] &&
    [[ "$_mods_output" == *"requires Claude Code 2.1.287 or later"* ]] &&
    [ ! -e "$_mods_version_root/installed" ]; then
    echo "  PASS  mods refuse $_mods_version before validation or installation"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  mods refuse $_mods_version before validation or installation"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: mods version preflight for $_mods_version"
  fi
done

# A CLI override may name a binary on PATH, not only an absolute file.
_mods_exit=0
_mods_output="$(
  PATH="$_mods_version_root:$PATH" CLAUDE_BIN=claude MODS_TEST_VERSION=2.1.287 \
    MODS_TEST_COMMAND_MARKER="$_mods_version_root/validated" \
    bash "$REPO_ROOT/scripts/test-claude-plugin-install.sh" frontend-skills 2>&1
)" || _mods_exit=$?
if [ "$_mods_exit" -eq 1 ] && [ -e "$_mods_version_root/validated" ]; then
  echo "  PASS  plugin installer resolves a CLI from PATH before validation"
  PASS=$((PASS + 1))
else
  echo "  FAIL  plugin installer resolves a CLI from PATH before validation"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: mods CLI path resolution"
fi
