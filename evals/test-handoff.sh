# Evals for /handoff skill.

run_file_eval "$REPO_ROOT/handoff/SKILL.md" "handoff skill exists"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "name: handoff" "handoff frontmatter name"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "mktemp -t handoff-XXXXXX.md" "handoff uses mktemp path"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" 'handoff_file=\$\(mktemp' "handoff creates a temp artifact"
if grep -qE 'cat .*handoff_file.*>/dev/null' "$REPO_ROOT/handoff/SKILL.md"; then
  echo "  FAIL  handoff performs a no-op temp-file read"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: handoff performs a no-op temp-file read"
else
  echo "  PASS  handoff has no no-op temp-file read"
  PASS=$((PASS + 1))
fi
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "Do not duplicate artifacts" "handoff avoids artifact duplication"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "[Rr]edact.*sensitive|secrets.*personal data" "handoff redacts sensitive information"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" "Suggested skills" "handoff suggests next skills"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\./handoff/" "handoff registered in Claude plugin skills"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/handoff" "generated catalog documents handoff"
