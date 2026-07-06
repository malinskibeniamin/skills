# Evals for Cursor Team Kit /weekly-review vendoring and harness wiring.

SKILL=weekly-review
PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

run_file_eval "$REPO_ROOT/$SKILL/SKILL.md" "weekly-review skill exists"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "^name: $SKILL$" "weekly-review skill has matching name"
run_content_eval "$PLUGIN" "\./$SKILL/" "Claude plugin registers weekly-review"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "last 7-10 days|weekly recap" "weekly-review uses weekly commit window"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "bug fixes.*tech debt.*net-new|bugfix / tech debt / net-new" "weekly-review classifies work"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/$SKILL" "ask-ben routes weekly-review"
run_content_eval "$REPO_ROOT/README.md" "/$SKILL" "README lists weekly-review"
