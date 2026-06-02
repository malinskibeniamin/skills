# Evals for Claude Code v2.1.157+ skills-directory plugin install.

README="$REPO_ROOT/README.md"
VERIFY="$REPO_ROOT/scripts/verify-install.sh"

run_content_eval "$README" 'Claude Code `v2\.1\.157\+`' "README declares Claude Code v2.1.157+ requirement"
run_content_eval "$README" 'git clone https://github\.com/malinskibeniamin/skills\.git ~/.claude/skills/frontend-skills' "README primary install clones into ~/.claude/skills"
run_content_eval "$README" 'No marketplace\. No install cache\. Claude auto-loads it as `frontend-skills@skills-dir`\.' "README says marketplace is not needed for primary Claude install"
run_content_eval "$README" 'git -C ~/.claude/skills/frontend-skills pull --ff-only' "README update uses git pull, not plugin force install"
run_content_eval "$README" 'bash ~/.claude/skills/frontend-skills/scripts/verify-install\.sh' "README verify uses skills-dir script path"
run_content_eval "$README" 'Legacy marketplace install \(Claude Code before v2\.1\.157\)' "README keeps marketplace flow only as legacy fallback"

primary_install_section=$(
  awk '
    /^## Install$/ { in_section=1 }
    in_section && /Legacy marketplace install/ { exit }
    in_section { print }
  ' "$README"
)

if printf '%s\n' "$primary_install_section" | grep -qE '/plugin (marketplace add|install frontend-skills)'; then
  echo "  FAIL  primary README install path does not require marketplace commands"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: primary README install path still uses marketplace commands"
else
  echo "  PASS  primary README install path does not require marketplace commands"
  PASS=$((PASS + 1))
fi

run_content_eval "$VERIFY" "PLUGIN_SOURCE=\"skills-dir\"" "verify-install has skills-dir install source"
run_content_eval "$VERIFY" "~/.claude/skills/frontend-skills" "verify-install documents skills-dir path"
run_content_eval "$VERIFY" "marketplace-cache" "verify-install still supports marketplace cache fallback"

tmp_home=$(mktemp -d)
dest="$tmp_home/.claude/skills/frontend-skills"
mkdir -p "$dest"
if command -v rsync >/dev/null 2>&1; then
  rsync -a --exclude=.git "$REPO_ROOT"/ "$dest"/
else
  cp -R "$REPO_ROOT"/. "$dest"/
  rm -rf "$dest/.git"
fi

skills_dir_exit=0
skills_dir_output=$(HOME="$tmp_home" bash "$dest/scripts/verify-install.sh" 2>&1) || skills_dir_exit=$?
rm -rf "$tmp_home"

if [ "$skills_dir_exit" -eq 0 ] && printf '%s\n' "$skills_dir_output" | grep -q -- "--- Install Mode: plugin (skills-dir) ---"; then
  echo "  PASS  verify-install detects ~/.claude/skills plugin install"
  PASS=$((PASS + 1))
else
  echo "  FAIL  verify-install detects ~/.claude/skills plugin install"
  echo "$skills_dir_output" | sed 's/^/        /'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: verify-install did not detect skills-dir install"
fi

source_tree_exit=0
source_tree_output=$(bash "$VERIFY" 2>&1) || source_tree_exit=$?
if [ "$source_tree_exit" -eq 0 ] && printf '%s\n' "$source_tree_output" | grep -q -- "--- Install Mode: plugin (source-tree) ---"; then
  echo "  PASS  verify-install detects source-tree plugin root"
  PASS=$((PASS + 1))
else
  echo "  FAIL  verify-install detects source-tree plugin root"
  echo "$source_tree_output" | sed 's/^/        /'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: verify-install did not detect source-tree plugin root"
fi
