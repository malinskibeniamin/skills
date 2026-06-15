# Evals for /write-a-skill creation discipline.

SKILL_DIR="$REPO_ROOT/write-a-skill"
SKILL="$SKILL_DIR/SKILL.md"

run_file_eval "$SKILL" "write-a-skill SKILL.md exists"
run_content_eval "$SKILL" "^name: write-a-skill" "write-a-skill has correct name"
run_content_eval "$SKILL" "Use when" "write-a-skill description has trigger phrase"
run_content_eval "$SKILL" "SKILL.md under 100 lines" "write-a-skill preserves line cap"
run_content_eval "$SKILL" "standard library|native platform|already-installed|one-line" "write-a-skill enforces reuse-first skill design"
run_content_eval "$SKILL" "No time-sensitive info" "write-a-skill rejects time-sensitive info"
