# Evals for verify-install script behavior.

SCRIPT="$REPO_ROOT/scripts/verify-install.sh"
run_file_eval "$SCRIPT" "verify-install.sh exists"
run_content_eval "$SCRIPT" "skills are slash commands" "verify treats skills as slash commands"
run_content_eval "$SCRIPT" "package.json not checked in plugin cache" "verify skips package.json warning in plugin mode"

# Regression: no warning for command-less skill-only plugin installs.
if grep -q '_warn "No slash commands found"' "$SCRIPT"; then
  echo "  FAIL  verify-install does not warn for missing legacy slash commands"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: verify-install warns for missing legacy slash commands"
else
  echo "  PASS  verify-install does not warn for missing legacy slash commands"
  PASS=$((PASS + 1))
fi
