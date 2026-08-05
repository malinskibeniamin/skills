# Evals for /writing-for-agents document-quality discipline.

SKILL_DIR="$REPO_ROOT/writing-for-agents"
SKILL="$SKILL_DIR/SKILL.md"
MECHANICS="$SKILL_DIR/SKILL-MECHANICS.md"

run_file_eval "$SKILL" "writing-for-agents SKILL.md exists"
run_file_eval "$MECHANICS" "writing-for-agents skill mechanics exist"
run_content_eval "$SKILL" "^name: writing-for-agents" "writing-for-agents has correct name"
if grep -q "^disable-model-invocation:" "$SKILL" 2>/dev/null; then
  echo "  FAIL  writing-for-agents should be model-invoked"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: writing-for-agents should be model-invoked"
else
  echo "  PASS  writing-for-agents is model-invoked"
  PASS=$((PASS + 1))
fi
run_content_eval "$SKILL" "AGENTS\\.md.*CLAUDE\\.md" "writing-for-agents covers agent instruction files"
run_content_eval "$SKILL" "context pointer" "writing-for-agents defines context pointers"
run_content_eval "$SKILL" "[Pp]rogressive disclosure" "writing-for-agents keeps progressive disclosure"
run_content_eval "$SKILL" "Context load|context load" "writing-for-agents controls context cost"
run_content_eval "$SKILL" "no-ops" "writing-for-agents hunts no-ops"
run_content_eval "$SKILL" "Negation" "writing-for-agents keeps the negation failure mode"
run_content_eval "$SKILL" "environment.*source of truth|source of truth.*environment" "writing-for-agents treats the environment as authoritative"
run_content_eval "$SKILL" "cache.*lookup|lookup.*cache" "writing-for-agents only caches expensive lookups"
run_content_eval "$MECHANICS" "Invocation" "skill mechanics define invocation"
run_content_eval "$MECHANICS" "Router skills" "skill mechanics define router skills"

if [ -e "$REPO_ROOT/writing-great-skills" ]; then
  echo "  FAIL  writing-great-skills was removed without an alias"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: stale writing-great-skills directory"
else
  echo "  PASS  writing-great-skills was removed without an alias"
  PASS=$((PASS + 1))
fi
