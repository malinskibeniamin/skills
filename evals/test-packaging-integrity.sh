# Packaging integrity (issue #48 WS2): no dangling relative links in shipped
# markdown, no broken symlinks, every hook script executable.

_pi_bad=""
while IFS= read -r _pi_file; do
  _pi_dir=$(dirname "$_pi_file")
  while IFS= read -r _pi_target; do
    [ -z "$_pi_target" ] && continue
    case "$_pi_target" in http*|\#*|mailto:*|\<*|link) continue ;; esac
    _pi_clean="${_pi_target%%#*}"
    _pi_clean="${_pi_clean%% *}"
    [ -e "$_pi_dir/$_pi_clean" ] || [ -e "$REPO_ROOT/$_pi_clean" ] || _pi_bad="$_pi_bad $_pi_file->$_pi_clean"
  done < <(grep -oE '\]\(([^)]+)\)' "$_pi_file" 2>/dev/null | sed 's/^](//;s/)$//')
done < <(find "$REPO_ROOT" -name '*.md' -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/docs/*' -not -path '*/deprecated/*' ! -name '*-FORMAT.md')

if [ -n "$_pi_bad" ]; then
  echo "  FAIL  dangling markdown links:$_pi_bad"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: dangling markdown links"
else
  echo "  PASS  no dangling relative links in shipped markdown"
  PASS=$((PASS + 1))
fi

_pi_symbad=$(find "$REPO_ROOT" -type l ! -exec test -e {} \; -print 2>/dev/null | grep -v node_modules || true)
if [ -n "$_pi_symbad" ]; then
  echo "  FAIL  broken symlinks: $_pi_symbad"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: broken symlinks"
else
  echo "  PASS  no broken symlinks"
  PASS=$((PASS + 1))
fi

_pi_noexec=$(find "$REPO_ROOT/.claude/hooks" "$REPO_ROOT/shared" -name '*.sh' ! -perm -u+x 2>/dev/null || true)
if [ -n "$_pi_noexec" ]; then
  echo "  FAIL  non-executable hook scripts: $_pi_noexec"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: non-executable hook scripts"
else
  echo "  PASS  all hook scripts executable"
  PASS=$((PASS + 1))
fi
