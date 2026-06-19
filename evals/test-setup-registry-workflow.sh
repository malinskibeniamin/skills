# Evals for setup-registry-workflow skill

SCRIPT="$REPO_ROOT/setup-registry-workflow/scripts/registry-check.sh"
SPLIT_SCRIPT="$REPO_ROOT/setup-registry-workflow/scripts/split-file-convention-check.sh"
SKILL_DIR="$REPO_ROOT/setup-registry-workflow"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_executable_eval "$SCRIPT" "registry-check.sh is executable"
run_file_eval "$SPLIT_SCRIPT" "split-file-convention-check.sh exists"
run_executable_eval "$SPLIT_SCRIPT" "split-file-convention-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-registry-workflow" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "registry.json" "SKILL.md mentions registry.json"
run_content_eval "$SKILL_DIR/SKILL.md" "redpanda-ui" "SKILL.md mentions redpanda-ui"
run_content_eval "$SKILL_DIR/SKILL.md" "changelog" "SKILL.md mentions changelog"
run_content_eval "$SKILL_DIR/SKILL.md" "split-file" "SKILL.md mentions split-file convention"

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "redpanda-ui/" "hook checks for redpanda-ui changes"
run_content_eval "$SCRIPT" "registry.json" "hook checks for registry.json update"
run_content_eval "$SCRIPT" "hook_(block|stop_block|stop_finding)|decision.*block|exit 2|stop-findings" "hook blocks when registry not rebuilt"
run_content_eval "$SCRIPT" "CHANGELOG|changeset" "hook reminds about changelog or changeset"
VENDOR_SCRIPT="$REPO_ROOT/.claude/hooks/vendor-file-check.sh"
run_content_eval "$VENDOR_SCRIPT" "redpanda-ui" "vendor hook blocks redpanda-ui edits"

_vendor_tmpdir=$(mktemp -d /tmp/vendor-registry-eval-XXXXXX)
mkdir -p "$_vendor_tmpdir/redpanda-ui"
tmpfile="$_vendor_tmpdir/redpanda-ui/button.tsx"
printf '%s\n' "export const Button = () => null" > "$tmpfile"
_vendor_input=$(printf '{"tool_name":"Edit","tool_input":{"file_path":"%s","old_string":"null","new_string":"undefined"}}' "$tmpfile")
run_hook_eval "$VENDOR_SCRIPT" "$_vendor_input" \
  2 "block: direct redpanda-ui edit" "vendor/registry"
rm -rf "$_vendor_tmpdir"

run_content_eval "$SPLIT_SCRIPT" "\\.page\\.tsx" "split hook allows .page.tsx route pages"
run_content_eval "$SPLIT_SCRIPT" "components/" "split hook steers components to components/"
run_content_eval "$SPLIT_SCRIPT" "parts|dialogs|checklist" "split hook rejects mixed split-file suffixes"

# ── hook-lib.sh: consumer repo upstream warning ──────────────────

HOOKLIB="$REPO_ROOT/shared/hook-lib.sh"
run_content_eval "$HOOKLIB" "components.json.*cli.json" "hook-lib detects consumer repos"
run_content_eval "$HOOKLIB" "UI registry" "hook-lib warns about upstream PR for consumer edits"
run_content_eval "$HOOKLIB" "registry.json" "hook-lib detects registry repo for rebuild reminder"
run_content_eval "$SCRIPT" "hook_session_changed_files" "registry-check uses session-scoped file detection"

# ── Stop hook behavioral test ───────────────────────────────────

# registry-check.sh should exit 0 when no files changed
_reg_tmpdir=$(mktemp -d /tmp/registry-eval-XXXXXX)
cd "$_reg_tmpdir"
git init -q && git commit --allow-empty -m "init" -q
actual_exit=0
"$SCRIPT" > /dev/null 2>&1 || actual_exit=$?
cd "$REPO_ROOT"
rm -rf "$_reg_tmpdir"

# ── Split-file convention behavioral tests ──────────────────────

_split_tmpdir=$(mktemp -d /tmp/split-file-eval-XXXXXX)
mkdir -p "$_split_tmpdir/src/routes" "$_split_tmpdir/src/components/users"

tmpfile="$_split_tmpdir/src/routes/users-parts.tsx"
printf "export function UsersParts() { return <div /> }\n" > "$tmpfile"
run_hook_eval "$SPLIT_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: route split file using -parts suffix" ".page.tsx"

tmpfile="$_split_tmpdir/src/routes/users.dialogs.tsx"
printf "export function UsersDialogs() { return <div /> }\n" > "$tmpfile"
run_hook_eval "$SPLIT_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  2 "block: route split file using .dialogs suffix" "components/"

tmpfile="$_split_tmpdir/src/routes/users.page.tsx"
printf "export function UsersPage() { return <div /> }\n" > "$tmpfile"
run_hook_eval "$SPLIT_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: route page named .page.tsx"

tmpfile="$_split_tmpdir/src/components/users/UsersChecklist.tsx"
printf "export function UsersChecklist() { return <div /> }\n" > "$tmpfile"
run_hook_eval "$SPLIT_SCRIPT" \
  "{\"tool_name\":\"Write\",\"tool_input\":{\"file_path\":\"$tmpfile\"}}" \
  0 "allow: split component under components"

rm -rf "$_split_tmpdir"

if [ "$actual_exit" -eq 0 ]; then
  echo "  PASS  registry-check exits 0 on clean repo (no changes)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  registry-check exits $actual_exit on clean repo (expected 0)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: registry-check exits $actual_exit on clean repo"
fi
