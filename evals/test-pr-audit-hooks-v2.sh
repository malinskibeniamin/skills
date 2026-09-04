# Evals for hooks from PR audit phase 2 (query-pattern, copyright, zustand-subscription, url-state, duplicate-function)

HOOKS_DIR="$REPO_ROOT/.claude/hooks"

# ══════════════════════════════════════════════════════════════════
# query-pattern-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/query-pattern-check.sh" "query-pattern-check.sh exists"
run_executable_eval "$HOOKS_DIR/query-pattern-check.sh" "query-pattern-check.sh is executable"

run_content_eval "$HOOKS_DIR/checks/query-pattern-check.lib.sh" "refetchQueries" "query-pattern detects refetchQueries"
run_content_eval "$HOOKS_DIR/checks/query-pattern-check.lib.sh" "invalidateQueries" "query-pattern suggests invalidateQueries"
run_content_eval "$HOOKS_DIR/checks/query-pattern-check.lib.sh" "await" "query-pattern checks for missing await"
run_content_eval "$HOOKS_DIR/checks/query-pattern-check.lib.sh" "hook_has_escape" "query-pattern respects escape hatch"

# ══════════════════════════════════════════════════════════════════
# copyright-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/copyright-check.sh" "copyright-check.sh exists"
run_executable_eval "$HOOKS_DIR/copyright-check.sh" "copyright-check.sh is executable"

run_content_eval "$HOOKS_DIR/checks/copyright-check.lib.sh" "spdx-license-identifier" "copyright-check catches license headers"
_copyright_tmp=$(mktemp -d)
_copyright_file="$_copyright_tmp/example.ts"

_copyright_pre=$(jq -nc --arg f "$_copyright_file" \
  '{hook_event_name:"PreToolUse",tool_name:"Write",tool_input:{file_path:$f,content:"// SPDX-License-Identifier: MIT\nexport const value = 1;"}}')
run_hook_eval "$HOOKS_DIR/copyright-check.sh" "$_copyright_pre" 2 \
  "copyright-check denies copyright headers before creating files" "Copyright/license header comments are prohibited"

printf 'export const value = 1;\n' > "$_copyright_file"
_copyright_post=$(jq -nc --arg f "$_copyright_file" \
  '{tool_name:"Edit",tool_input:{file_path:$f,old_string:"export const value = 1;",new_string:"// SPDX-License-Identifier: MIT\nexport const value = 1;"}}')
run_hook_eval "$HOOKS_DIR/copyright-check.sh" "$_copyright_post" 2 \
  "copyright-check blocks copyright headers after edits" "Copyright/license header comments are prohibited"

_copyright_clean=$(jq -nc --arg f "$_copyright_file" \
  '{hook_event_name:"PreToolUse",tool_name:"Edit",tool_input:{file_path:$f,old_string:"export const value = 1;",new_string:"export const value = 2;"}}')
run_hook_eval "$HOOKS_DIR/copyright-check.sh" "$_copyright_clean" 0 \
  "copyright-check allows normal edits"
rm -rf "$_copyright_tmp"

if jq -e '.hooks.PreToolUse["Edit|Write"] | index("copyright-check.sh")' \
  "$REPO_ROOT/skill-manifest.json" >/dev/null 2>&1; then
  echo "  PASS  copyright-check denies headers before edit tools run"
  PASS=$((PASS + 1))
else
  echo "  FAIL  copyright-check missing from Edit|Write PreToolUse"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: copyright-check missing from Edit|Write PreToolUse"
fi

# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ══════════════════════════════════════════════════════════════════
# hooks.json wiring
# ══════════════════════════════════════════════════════════════════

run_content_eval "$REPO_ROOT/hooks/hooks.json" "post-tool-batch.sh" "hooks.json has PostToolBatch dispatcher"
run_content_eval "$REPO_ROOT/skill-manifest.json" "query-pattern-check.sh" "edit dispatcher includes query-pattern-check"
run_content_eval "$REPO_ROOT/skill-manifest.json" "copyright-check.sh" "edit dispatcher includes copyright-check"

# ══════════════════════════════════════════════════════════════════
# accessibility-check.sh extensions
# ══════════════════════════════════════════════════════════════════

run_content_eval "$REPO_ROOT/frontend-starter-kit/references/react-doctor/doctor.config.json" "no-aria-invalid-without-description" "React Doctor detects aria-invalid without a description"
run_content_eval "$HOOKS_DIR/checks/accessibility-check.lib.sh" "nested interactive" "accessibility-check detects nested interactives"

# ══════════════════════════════════════════════════════════════════
# ux-copy-check.sh extensions
# ══════════════════════════════════════════════════════════════════

run_content_eval "$HOOKS_DIR/checks/ux-copy-check.lib.sh" "routing policies" "ux-copy-check has glossary terms"
run_content_eval "$HOOKS_DIR/checks/ux-copy-check.lib.sh" "configuration and settings" "ux-copy-check detects redundant phrasing"
