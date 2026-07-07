# Evals for Cursor Team Kit /make-pr-easy-to-review vendoring and harness wiring.

SKILL=make-pr-easy-to-review
PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

run_file_eval "$REPO_ROOT/$SKILL/SKILL.md" "make-pr-easy-to-review skill exists"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "^name: $SKILL$" "make-pr-easy-to-review skill has matching name"
run_content_eval "$PLUGIN" "\./$SKILL/" "Claude plugin registers make-pr-easy-to-review"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "reviewability without behavior changes" "make-pr-easy-to-review preserves reviewability intent"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "Only rewrite history when the user asks|agrees to the plan" "make-pr-easy-to-review guards history rewrites"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "Original tree|Current tree" "make-pr-easy-to-review verifies tree identity after rewrite"
run_content_eval "$REPO_ROOT/$SKILL/SKILL.md" "PR description|review notes" "make-pr-easy-to-review prefers reviewer guidance over behavior changes"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/$SKILL" "ask-ben routes make-pr-easy-to-review"
run_content_eval "$REPO_ROOT/README.md" "/$SKILL" "README lists make-pr-easy-to-review"
run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" "/$SKILL" "commit-push-pr routes reviewer guidance through make-pr-easy-to-review"
run_content_eval "$REPO_ROOT/go/SKILL.md" "/$SKILL" "go includes make-pr-easy-to-review in ship flow"
