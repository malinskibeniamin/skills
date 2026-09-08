# Public harness instructions and executable PR-entrypoint reminder.

for command in 'gh pr create --fill' 'gh pr edit 12 --body-file /tmp/body.md' 'gh pr reopen 12' 'gh pr ready 12' 'gh stack submit --auto' 'gh --repo org/repo pr create --fill' 'git push origin feature' 'env GH_HOST=github.com gh pr create --draft'; do
  input=$(jq -nc --arg command "$command" '{tool_name:"Bash",tool_input:{command:$command}}')
  run_hook_eval "$REPO_ROOT/.claude/hooks/pre-bash.sh" "$input" 0 \
    "PR evidence reminder: $command" '[pr-evidence]'
done

# Successful hooks must return model-visible additionalContext; stderr alone is
# debug output on some hosts. A later RTK rewrite must survive alongside it.
fixture=$(mktemp -d)
cp "$REPO_ROOT/.claude/hooks/pre-bash.sh" "$REPO_ROOT/.claude/hooks/pr-evidence-nudge.sh" "$fixture/"
cat > "$fixture/rtk-rewrite.sh" <<'EOF'
#!/bin/bash
cat >/dev/null
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":"rtk proxy gh pr create --fill"},"additionalContext":"rewrite context"}}'
EOF
chmod +x "$fixture/rtk-rewrite.sh"
input='{"tool_name":"Bash","tool_input":{"command":"gh pr create --fill"}}'
output=$(printf '%s' "$input" | "$fixture/pre-bash.sh" 2>/dev/null)
if printf '%s' "$output" | jq -e '.hookSpecificOutput | (.additionalContext | contains("[pr-evidence]") and contains("rewrite context")) and (.updatedInput.command == "rtk proxy gh pr create --fill")' >/dev/null 2>&1; then
  echo '  PASS  model-visible PR reminder composes with command rewrite'
  PASS=$((PASS + 1))
else
  echo '  FAIL  PR reminder lost from model context or clobbered rewrite'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: PR reminder and command rewrite composition"
fi
rm -f "$fixture/rtk-rewrite.sh"
cat > "$fixture/enforce-toolchain.sh" <<'EOF'
#!/bin/bash
cat >/dev/null
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","updatedInput":{"command":"git push --quiet"}}}'
EOF
chmod +x "$fixture/enforce-toolchain.sh"
input='{"tool_name":"Bash","tool_input":{"command":"git push"}}'
output=$(printf '%s' "$input" | "$fixture/pre-bash.sh" 2>/dev/null)
if printf '%s' "$output" | jq -e '.hookSpecificOutput | (.additionalContext | contains("[pr-evidence]")) and (.updatedInput.command == "git push --quiet")' >/dev/null 2>&1; then
  echo '  PASS  reminder preserves an earlier rewrite when RTK is absent'
  PASS=$((PASS + 1))
else
  echo '  FAIL  reminder clobbered an earlier rewrite without RTK'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: earlier rewrite lost without RTK"
fi
rm -f "$fixture/pre-bash.sh" "$fixture/pr-evidence-nudge.sh" "$fixture/enforce-toolchain.sh"
rmdir "$fixture"

for command in 'gh pr view 12' 'gh pr checks 12' 'gh issue create' 'gh stack view --json' 'git status --short'; do
  input=$(jq -nc --arg command "$command" '{tool_name:"Bash",tool_input:{command:$command}}')
  output=$(printf '%s' "$input" | "$REPO_ROOT/.claude/hooks/pre-bash.sh" 2>&1)
  if printf '%s' "$output" | grep -qF '[pr-evidence]'; then
    echo "  FAIL  read-only/unrelated command nudged: $command"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: unrelated PR evidence reminder: $command"
  else
    echo "  PASS  no PR evidence reminder: $command"
    PASS=$((PASS + 1))
  fi
done

run_content_eval "$REPO_ROOT/commit-push-pr/SKILL.md" 'Every PR.*quantify-impact' \
  'every PR automatically assesses impact'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'No size threshold' \
  'tiny visible changes require evidence'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'shared.*consumers' \
  'shared UI changes expand the affected surface inventory'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'without snapshot-update' \
  'accepted baselines must pass a normal visual test run'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'Local paths.*not.*reviewer' \
  'local files cannot substitute for reviewer-visible images'
run_content_eval "$REPO_ROOT/commit-push-pr/REFERENCE.md" 'Re-read.*body' \
  'publication verifies the actual PR body'
run_content_eval "$REPO_ROOT/visual-review/SKILL.md" 'merge-base' \
  'visual review includes committed changes rather than only HEAD worktree edits'
run_content_eval "$REPO_ROOT/tdd/SKILL.md" 'copy.*styles.*layout' \
  'visual regression includes small static changes'
