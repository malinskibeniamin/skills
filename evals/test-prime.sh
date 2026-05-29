# Evals for /prime startup-orientation skill

SKILL_DIR="$REPO_ROOT/prime"
SCRIPT="$SKILL_DIR/scripts/prime-context.sh"

run_file_eval "$SKILL_DIR/SKILL.md" "prime SKILL.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: prime" "prime has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "startup brief" "prime describes startup brief"
run_content_eval "$SKILL_DIR/SKILL.md" "new chat" "prime triggers on new chat"
run_content_eval "$SKILL_DIR/SKILL.md" "Do not expose modes" "prime has one adaptive surface"
run_content_eval "$SKILL_DIR/SKILL.md" "scripts/prime-context.sh" "prime uses deterministic scout script"
run_content_eval "$SKILL_DIR/SKILL.md" "[Rr]ead only the highest-signal files" "prime lets agent choose next reads"

run_file_eval "$SKILL_DIR/REFERENCE.md" "prime REFERENCE.md exists"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Output contract" "prime reference defines output contract"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Do not paste full CLAUDE.md or AGENTS.md" "prime reference prevents instruction-file pollution"
run_content_eval "$SKILL_DIR/REFERENCE.md" "SessionStart" "prime reference documents hook option"
run_content_eval "$SKILL_DIR/REFERENCE.md" "UserPromptSubmit" "prime reference documents self-invoked option"

run_file_eval "$SCRIPT" "prime scout script exists"
run_executable_eval "$SCRIPT" "prime scout script executable"
run_content_eval "$SCRIPT" "Prime Scout" "prime scout emits title"
run_content_eval "$SCRIPT" "Candidate next reads" "prime scout suggests next reads"
run_content_eval "$SCRIPT" "CLAUDE.md" "prime scout considers CLAUDE.md"
run_content_eval "$SCRIPT" "AGENTS.md" "prime scout considers AGENTS.md"
run_content_eval "$SCRIPT" "gh pr view" "prime scout can detect current PR"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\"./prime/\"" "prime registered in Claude plugin skills"

if [ -x "$SCRIPT" ]; then
  out=$("$SCRIPT" 2>/dev/null || true)
  if echo "$out" | grep -q "# Prime Scout" && echo "$out" | grep -q "## Work state" && echo "$out" | grep -q "## Candidate next reads"; then
    echo "  PASS  prime scout prints required sections"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  prime scout missing required sections"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: prime scout missing required sections"
  fi

  if [ "$(printf '%s' "$out" | wc -c | tr -d ' ')" -lt 12000 ]; then
    echo "  PASS  prime scout output bounded"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  prime scout output too large"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: prime scout output too large"
  fi
fi
