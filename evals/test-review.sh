# Evals for /review skill PR comment workflow.

SKILL_DIR="$REPO_ROOT/review"

run_file_eval "$SKILL_DIR/SKILL.md" "review SKILL.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "post inline PR comments automatically" "review auto-posts PR comments when available"
run_content_eval "$SKILL_DIR/SKILL.md" "user does not need to ask" "review does not require explicit comment request"
run_content_eval "$SKILL_DIR/SKILL.md" "After all hats finish" "review comments after all review hats finish"
run_content_eval "$SKILL_DIR/SKILL.md" "Do not comment during individual hats" "review forbids per-hat real-time comments"
run_content_eval "$SKILL_DIR/SKILL.md" "Do not dump the whole review" "review avoids dumping full review as PR comment"
run_content_eval "$SKILL_DIR/SKILL.md" "P0 bug/blocker.*P1 major.*P2 minor.*P3 patch.*Future follow-up" "review defines priority label mapping"
run_content_eval "$SKILL_DIR/SKILL.md" "Every posted/comment-ready item must include exactly one priority label" "review requires one priority per comment"
run_content_eval "$SKILL_DIR/SKILL.md" "keep P3 and Future items in the summary" "review keeps low-priority items out of inline comments by default"
run_content_eval "$SKILL_DIR/SKILL.md" "What's working" "review summary includes what's working"
run_content_eval "$SKILL_DIR/SKILL.md" "Needs attention" "review summary includes needs attention"
run_content_eval "$SKILL_DIR/SKILL.md" "Follow-ups" "review summary includes follow-ups"
run_content_eval "$SKILL_DIR/SKILL.md" "Comment template: What, Why, Suggested fix, One-shot prompt" "review defines concise PR comment template"
run_content_eval "$SKILL_DIR/SKILL.md" "comment-ready output" "review has fallback when PR comment tooling unavailable"
run_content_eval "$SKILL_DIR/SKILL.md" "Posted: <count> \\| Comment-ready fallback: <count> \\| Skipped as summary-only: <count>" "review reports posted and skipped comment counts"
