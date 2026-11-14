# Evals for scripts/skills-browser.sh (Vercel agent-browser wrapper).

SCRIPT="$REPO_ROOT/scripts/skills-browser.sh"

run_file_eval "$SCRIPT" "skills-browser.sh exists"
run_executable_eval "$SCRIPT" "skills-browser.sh executable"
run_content_eval "$SCRIPT" "agent-browser" "wraps agent-browser CLI"
run_content_eval "$SCRIPT" "brew install" "prints brew install hint"
run_content_eval "$SCRIPT" "cargo install" "prints cargo install hint"
run_content_eval "$SCRIPT" "dogfood/SKILL.md" "points to the current browser/data policy owner"
run_content_eval "$SCRIPT" "BLOCKED" "missing CLI remains a verification blocker"

# Exits 127 if agent-browser missing (script does not pretend to work).
# Force a clean PATH so the test runs the same way whether or not the
# dev has agent-browser installed locally.
_ec=0
PATH=/usr/bin:/bin "$SCRIPT" navigate https://example.com >/dev/null 2>&1 || _ec=$?
if [ "$_ec" -eq 127 ]; then
  echo "  PASS  exits 127 when agent-browser missing"
  PASS=$((PASS + 1))
else
  echo "  FAIL  exit was $_ec, expected 127"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: skills-browser 127 exit"
fi

# The wrapper stays available; /go states the observable browser outcome instead of a tool chain.
run_content_eval "$REPO_ROOT/shared/delivery-workflow.md" "real user or public entrypoint" \
  "/go smoke-tests material changes at the real entrypoint"

# Forward CLI arguments unchanged; preserve failure instead of faking success.
_browser_tmp=$(mktemp -d)
cat > "$_browser_tmp/agent-browser" <<'EOF'
#!/bin/bash
printf '%s\0' "$@" > "$SKILLS_BROWSER_ARGS"
exit "${SKILLS_BROWSER_EXIT:-0}"
EOF
chmod +x "$_browser_tmp/agent-browser"
printf '%s\0' --session 'eval isolated' flow run search --param 'q=hello world' \
  --fields title,price --limit 3 > "$_browser_tmp/expected"
_ec=0
PATH="$_browser_tmp:/usr/bin:/bin" SKILLS_BROWSER_ARGS="$_browser_tmp/actual" \
  SKILLS_BROWSER_EXIT=23 "$SCRIPT" --session 'eval isolated' flow run search \
  --param 'q=hello world' --fields title,price --limit 3 || _ec=$?
if [ "$_ec" -eq 23 ] && cmp -s "$_browser_tmp/expected" "$_browser_tmp/actual"; then
  echo "  PASS  forwards saved-flow arguments and failure status unchanged"
  PASS=$((PASS + 1))
else
  echo "  FAIL  wrapper changed saved-flow arguments or failure status (exit=$_ec)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: skills-browser pass-through"
fi
rm -rf "$_browser_tmp"
