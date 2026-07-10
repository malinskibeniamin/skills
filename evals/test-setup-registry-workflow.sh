# Evals for setup-registry-workflow skill

SCRIPT="$REPO_ROOT/registry-workflow/scripts/registry-check.sh"
SPLIT_SCRIPT="$REPO_ROOT/.claude/hooks/tanstack-router-check.sh"
SPLIT_LIB="$REPO_ROOT/.claude/hooks/checks/tanstack-router-check.lib.sh"
SKILL_DIR="$REPO_ROOT/registry-workflow"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_executable_eval "$SCRIPT" "registry-check.sh is executable"
run_file_eval "$SPLIT_SCRIPT" "tanstack-router-check.sh exists"
run_executable_eval "$SPLIT_SCRIPT" "tanstack-router-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: registry-workflow" "SKILL.md has correct name"
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
run_content_eval "$SPLIT_LIB" "\\.page\\.tsx" "split hook allows .page.tsx route pages"
run_content_eval "$SPLIT_LIB" "components/" "split hook steers components to components/"
run_content_eval "$SPLIT_LIB" "parts|dialogs|checklist" "split hook rejects mixed split-file suffixes"

# ── hook-lib.sh: consumer repo upstream warning ──────────────────

# Single owner of the registry-edit warning is vendor-file-check.lib.sh
# (hook_skip_ui_dirs in hook-lib only skips; it no longer emits).
VENDORLIB="$REPO_ROOT/.claude/hooks/checks/vendor-file-check.lib.sh"
run_content_eval "$VENDORLIB" "registry.json" "vendor-file detects registry repo for rebuild reminder"
run_content_eval "$VENDORLIB" "UI REGISTRY" "vendor-file warns about upstream PR for consumer edits"
run_content_eval "$VENDORLIB" "overwritten on next" "vendor-file explains consumer-edit overwrite risk"
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
