# Evals for Cursor Team Kit /what-did-i-get-done vendoring and harness wiring.

SKILL=what-did-i-get-done
PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

run_file_eval "$REPO_ROOT/$SKILL/SKILL.md" "Cursor commit-summary skill exists"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "^name: $SKILL$" "Cursor commit-summary skill has matching name"
run_content_eval "$PLUGIN" "\./$SKILL/" "Claude plugin registers Cursor commit-summary skill"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "authored git commits|commits authored by the current git user email" "skill summarizes authored commits by time range"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/$SKILL" "ask-ben routes commit-summary skill"
run_content_eval "$REPO_ROOT/README.md" "/$SKILL" "README lists commit-summary skill"
