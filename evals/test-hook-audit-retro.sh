# Evals for hook-audit retro extension (session flow analytics).

SKILL="$REPO_ROOT/hook-audit/SKILL.md"

run_file_eval "$SKILL" "hook-audit SKILL.md exists"
DISCLOSED=$(mktemp)
cat "$SKILL" "$REPO_ROOT/hook-audit/REFERENCE.md" > "$DISCLOSED"
SKILL="$DISCLOSED"
trap 'rm -f "$DISCLOSED"' EXIT

run_content_eval "$SKILL" "retro" "description mentions retro / team analytics"
run_content_eval "$SKILL" "Retro metrics" "skill has retro metrics"

# Metrics covered in retro
run_content_eval "$SKILL" "first edit to PR" "retro covers session-to-PR lag"
run_content_eval "$SKILL" "CI first-run pass rate" "retro covers CI first-try pass rate"
run_content_eval "$SKILL" "lifecycle grill marker" "retro covers phases skipped"
run_content_eval "$SKILL" "Review rounds" "retro covers review-round distribution"
run_content_eval "$SKILL" "Human comment.*resolved-thread" "retro covers human-review latency"
run_content_eval "$SKILL" "Active worktrees" "retro covers worktree sprawl"

# Mode flags
run_content_eval "$SKILL" "\\-\\-hooks" "supports --hooks mode"
run_content_eval "$SKILL" "\\-\\-retro" "supports --retro mode"
run_content_eval "$SKILL" "\\-\\-all" "supports --all mode"
