# Evals for hooks from PR audit phase 2 (query-pattern, copyright, zustand-subscription, url-state, duplicate-function)

HOOKS_DIR="$REPO_ROOT/.claude/hooks"

# ══════════════════════════════════════════════════════════════════
# query-pattern-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/query-pattern-check.sh" "query-pattern-check.sh exists"
run_executable_eval "$HOOKS_DIR/query-pattern-check.sh" "query-pattern-check.sh is executable"

run_content_eval "$HOOKS_DIR/query-pattern-check.sh" "refetchQueries" "query-pattern detects refetchQueries"
run_content_eval "$HOOKS_DIR/query-pattern-check.sh" "invalidateQueries" "query-pattern suggests invalidateQueries"
run_content_eval "$HOOKS_DIR/query-pattern-check.sh" "await" "query-pattern checks for missing await"
run_content_eval "$HOOKS_DIR/query-pattern-check.sh" "hook_has_escape" "query-pattern respects escape hatch"

# ══════════════════════════════════════════════════════════════════
# copyright-check.sh
# ══════════════════════════════════════════════════════════════════

run_file_eval "$HOOKS_DIR/copyright-check.sh" "copyright-check.sh exists"
run_executable_eval "$HOOKS_DIR/copyright-check.sh" "copyright-check.sh is executable"

run_content_eval "$HOOKS_DIR/copyright-check.sh" "copyright\|license" "copyright-check looks for copyright/license"
run_content_eval "$HOOKS_DIR/copyright-check.sh" "copyright-reminded" "copyright-check uses session marker"
run_content_eval "$HOOKS_DIR/copyright-check.sh" "git show HEAD" "copyright-check only fires on new files"

# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ══════════════════════════════════════════════════════════════════
# ══════════════════════════════════════════════════════════════════


# ══════════════════════════════════════════════════════════════════
# hooks.json wiring
# ══════════════════════════════════════════════════════════════════

run_content_eval "$REPO_ROOT/hooks/hooks.json" "query-pattern-check" "hooks.json has query-pattern-check"
run_content_eval "$REPO_ROOT/hooks/hooks.json" "copyright-check" "hooks.json has copyright-check"

# ══════════════════════════════════════════════════════════════════
# accessibility-check.sh extensions
# ══════════════════════════════════════════════════════════════════

run_content_eval "$HOOKS_DIR/accessibility-check.sh" "aria-invalid" "accessibility-check detects aria-invalid without describedby"
run_content_eval "$HOOKS_DIR/accessibility-check.sh" "nested interactive" "accessibility-check detects nested interactives"

# ══════════════════════════════════════════════════════════════════
# ux-copy-check.sh extensions
# ══════════════════════════════════════════════════════════════════

run_content_eval "$HOOKS_DIR/ux-copy-check.sh" "routing policies" "ux-copy-check has glossary terms"
run_content_eval "$HOOKS_DIR/ux-copy-check.sh" "configuration and settings" "ux-copy-check detects redundant phrasing"
