# Executable PR-entrypoint routing and context composition.

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

# Completion must inspect the hosted PR body, not just print a reminder.
visual_root=$(mktemp -d)
visual_repo="$visual_root/repo"
visual_sid="pr-visual-eval-$$"
visual_session="/tmp/hook-session-$visual_sid"
trap 'rm -rf "$visual_root" "$visual_session"' EXIT
mkdir -p "$visual_root/bin" "$visual_session"
git init --bare -q "$visual_root/origin.git"
git init -q -b main "$visual_repo"
git -C "$visual_repo" config user.email eval@example.com
git -C "$visual_repo" config user.name Eval
printf 'syntax = "proto3";\n' > "$visual_repo/api.proto"
git -C "$visual_repo" add api.proto
git -C "$visual_repo" commit -qm base
git -C "$visual_repo" remote add origin "$visual_root/origin.git"
git -C "$visual_repo" push -qu origin main
git -C "$visual_repo" checkout -qb feature/api-contract
printf 'message Result { string value = 1; }\n' >> "$visual_repo/api.proto"
git -C "$visual_repo" commit -qam change
git -C "$visual_repo" push -qu origin feature/api-contract
: > "$visual_session/dirty-files-baseline"
cat > "$visual_root/bin/gh" <<'GH'
#!/bin/bash
case "$1 $2" in
  'pr list') printf '17\n' ;;
  'pr view') cat "$VISUAL_BODY" ;;
  *) exit 1 ;;
esac
GH
chmod +x "$visual_root/bin/gh"
export VISUAL_BODY="$visual_root/body.md"
visual_input=$(jq -nc --arg sid "$visual_sid" \
  '{session_id:$sid,last_assistant_message:"Intent: explain the contract | Impact: reviewable change\n🟢 done — PR published"}')
pushd "$visual_repo" >/dev/null
printf 'pr\n' > "$visual_session/task-endpoint"
export PATH="$visual_root/bin:$PATH"

printf 'Adds the result contract.\n\n- Testing: compatibility passes.\n' > "$VISUAL_BODY"
CLAUDE_SESSION_ID="$visual_sid" run_hook_eval "$REPO_ROOT/.claude/hooks/lifecycle-stop.sh" \
  "$visual_input" 2 'backend PR without visuals cannot complete' 'visual evidence'

for body in \
  $'```mermaid\nsequenceDiagram\n  Browser->>API: Read result\n  API-->>Browser: Result.value\n```' \
  $'```mermaid\n---\ntitle: Contract flow\n---\nflowchart LR\n  Browser-->API\n```' \
  $'```mermaid\nflowchart LR; Browser-->API\n```' \
  $'~~~mermaid\r\nflowchart LR\r\n  Browser-->API\r\n~~~\r\n' \
  '![Contract diagram](https://example.com/contract.png)' \
  '<video src="https://example.com/flow.mp4" controls></video>' \
  'https://github.com/user-attachments/assets/1234' \
  'Visual evidence: not applicable — formatting only; contract and behavior unchanged.'; do
  printf '%s\n' "$body" > "$VISUAL_BODY"
  CLAUDE_SESSION_ID="$visual_sid" run_hook_eval "$REPO_ROOT/.claude/hooks/lifecycle-stop.sh" \
    "$visual_input" 0 "hosted evidence or explicit scoped exception permits completion: ${body:0:45}"
done

for body in \
  'Architecture preview unavailable: browser missing.' \
  '![Diagram](/tmp/architecture.png)' \
  $'```mermaid\n```' \
  $'```mermaid\nsequenceDiagram\n```' \
  $'```mermaid\nflowchart LR\n A-->B' \
  $'```markdown\n![Example](https://example.com/example.png)\n```' \
  '<!-- ![Hidden](https://example.com/hidden.png) -->' \
  'Visual evidence: not applicable —'; do
  printf '%s\n' "$body" > "$VISUAL_BODY"
  CLAUDE_SESSION_ID="$visual_sid" run_hook_eval "$REPO_ROOT/.claude/hooks/lifecycle-stop.sh" \
    "$visual_input" 2 "missing, local, empty or hidden evidence is rejected: ${body:0:45}" 'visual evidence'
done

printf 'ship\n' > "$visual_session/task-endpoint"
CLAUDE_SESSION_ID="$visual_sid" run_hook_eval "$REPO_ROOT/.claude/hooks/lifecycle-stop.sh" \
  "$visual_input" 2 'ship endpoint retains the same visual requirement' 'visual evidence'
rm "$VISUAL_BODY"
CLAUDE_SESSION_ID="$visual_sid" run_hook_eval "$REPO_ROOT/.claude/hooks/lifecycle-stop.sh" \
  "$visual_input" 2 'unreadable hosted body cannot pass evidence verification' 'Cannot read'
printf 'push\n' > "$visual_session/task-endpoint"
CLAUDE_SESSION_ID="$visual_sid" run_hook_eval "$REPO_ROOT/.claude/hooks/lifecycle-stop.sh" \
  "$visual_input" 0 'push-only endpoint needs no PR or diagram'
popd >/dev/null
