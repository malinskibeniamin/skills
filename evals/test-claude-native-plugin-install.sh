# Evals for native Claude Code plugin install docs plus local skills-dir detection.

README="$REPO_ROOT/README.md"
VERIFY="$REPO_ROOT/scripts/verify-install.sh"

run_content_eval "$README" '/plugin marketplace add malinskibeniamin/skills' "README primary install uses native marketplace add"
run_content_eval "$README" '/plugin install frontend-skills@skills' "README primary install uses native plugin install"
run_content_eval "$README" '/reload-plugins' "README primary install reloads plugins"
run_content_eval "$README" 'Native Claude Code marketplace install\.' "README names marketplace as native Claude install path"
run_content_eval "$README" 'Claude Code `v2\.1\.157\+`' "README explains v2.1.157+ skills-dir behavior"
run_content_eval "$README" 'claude plugin init <name>' "README points skills-dir usage to native plugin init"
run_content_eval "$README" '/plugin update frontend-skills' "README update uses native plugin update"
run_content_eval "$README" '/plugin details frontend-skills' "README verify uses native plugin details"
run_content_eval "$README" 'plugins/cache/skills/frontend-skills' "README optional health check uses managed plugin cache"

primary_install_section=$(
  awk '
    /^## Install$/ { in_section=1 }
    in_section && /^<details>/ { exit }
    in_section { print }
  ' "$README"
)

if printf '%s\n' "$primary_install_section" | grep -qE 'git clone|git -C ~/.claude/skills|~/.claude/skills/frontend-skills/scripts/verify-install\.sh'; then
  echo "  FAIL  primary README install path avoids raw git/skills-dir install"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: primary README install path still uses raw git/skills-dir install"
else
  echo "  PASS  primary README install path avoids raw git/skills-dir install"
  PASS=$((PASS + 1))
fi

run_content_eval "$VERIFY" 'PLUGIN_SOURCE="skills-dir"' "verify-install has skills-dir install source"
run_content_eval "$VERIFY" '~/.claude/skills/frontend-skills' "verify-install documents skills-dir path"
run_content_eval "$VERIFY" 'marketplace-cache' "verify-install supports marketplace cache fallback"

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
  echo "  PASS  verify-install detects native skills-dir plugin root"
  PASS=$((PASS + 1))
else
  echo "  FAIL  verify-install detects native skills-dir plugin root"
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
