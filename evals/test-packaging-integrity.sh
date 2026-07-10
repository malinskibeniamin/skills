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
done < <(find "$REPO_ROOT" -name '*.md' -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/deprecated/*' ! -name '*-FORMAT.md')

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

# Executable ownership (issue #48 WS3): the Biome reference config must be
# machine-loadable and actually carry every rule the retirement notes claim --
# asserted against the parsed artifact, not prose.
_pi_cfg=$(awk '/^```jsonc?$/{f=1;next} /^```$/{f=0} f' "$REPO_ROOT/frontend-starter-kit/references/biome/REFERENCE.md" | sed -e 's://[^"]*$::' )
if printf '%s' "$_pi_cfg" | jq -e . >/dev/null 2>&1; then
  echo "  PASS  Biome reference config parses as JSON"
  PASS=$((PASS + 1))
  for _pi_rule in noRestrictedImports noRestrictedElements noProcessEnv; do
    if printf '%s' "$_pi_cfg" | jq -e ".. | objects | select(has(\"$_pi_rule\"))" >/dev/null 2>&1; then
      echo "  PASS  parsed Biome config carries $_pi_rule"
      PASS=$((PASS + 1))
    else
      echo "  FAIL  parsed Biome config missing $_pi_rule"
      FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: Biome config missing $_pi_rule"
    fi
  done
else
  echo "  FAIL  Biome reference config block does not parse as JSON"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: Biome config unparseable"
fi

# Media references (video/img tags and inline paths) must exist -- docs included.
_pi_media_bad=""
while IFS= read -r _pi_ref; do
  [ -e "$REPO_ROOT/$_pi_ref" ] || _pi_media_bad="$_pi_media_bad $_pi_ref"
done < <(grep -rhoE 'docs/screenshots/[a-zA-Z0-9._-]+' "$REPO_ROOT/README.md" "$REPO_ROOT/docs" 2>/dev/null | sort -u)
if [ -n "$_pi_media_bad" ]; then
  echo "  FAIL  referenced media missing:$_pi_media_bad"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: referenced media missing"
else
  echo "  PASS  all referenced docs/screenshots media exist"
  PASS=$((PASS + 1))
fi

# Library mirror integrity: every _hook-lib.sh in an executable location must
# resolve to the ONE authoritative shared/hook-lib.sh (the diverged-mirror bug
# left live hooks calling functions that only existed in shared/).
_pi_lib_bad=""
while IFS= read -r _pi_lib; do
  cmp -s "$_pi_lib" "$REPO_ROOT/shared/hook-lib.sh" || _pi_lib_bad="$_pi_lib_bad $_pi_lib"
done < <(find "$REPO_ROOT/.claude/hooks" "$REPO_ROOT/frontend-starter-kit" "$REPO_ROOT/accessibility" -name '_hook-lib.sh' 2>/dev/null)
if [ -n "$_pi_lib_bad" ]; then
  echo "  FAIL  diverged hook-lib mirrors:$_pi_lib_bad"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: diverged hook-lib mirrors"
else
  echo "  PASS  every _hook-lib.sh resolves to the authoritative shared lib"
  PASS=$((PASS + 1))
fi
