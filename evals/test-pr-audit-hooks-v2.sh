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

run_content_eval "$HOOKS_DIR/checks/copyright-check.lib.sh" "copyright\|license" "copyright-check looks for copyright/license"
run_content_eval "$HOOKS_DIR/checks/copyright-check.lib.sh" "copyright-reminded" "copyright-check uses session marker"
run_content_eval "$HOOKS_DIR/checks/copyright-check.lib.sh" "git show HEAD" "copyright-check only fires on new files"

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
