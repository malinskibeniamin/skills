# Behavioral coverage for candidate-facing agent-eval prompt blinding.

CHECKER="$REPO_ROOT/agent-evals/check-prompt-blinding.ts"

run_file_eval "$CHECKER" "agent-eval prompt blinding checker exists"
run_content_eval "$REPO_ROOT/writing-for-agents/SKILL.md" \
  'organic request|organic task' \
  "agent-writing guidance keeps candidate prompts organic"
run_content_eval "$REPO_ROOT/agent-evals/package.json" \
  '"eval": "bun run check:prompts &&' \
  "default paid eval command runs the blinding preflight"
run_content_eval "$REPO_ROOT/agent-evals/context-ablation/run.sh" \
  'check-prompt-blinding.ts' \
  "context ablation runs the blinding preflight"

fixture_root=$(mktemp -d)
mkdir -p "$fixture_root/empty" "$fixture_root/organic/nested" "$fixture_root/leak"
cat > "$fixture_root/organic/nested/PROMPT.md" <<'EOF'
# Task

Fix the checkout race and run the supplied verification commands.
EOF

organic_output=""
if organic_output=$(bun "$CHECKER" "$fixture_root/organic" 2>&1) \
  && printf '%s\n' "$organic_output" | grep -q 'Prompt blinding passed (1 prompt)'; then
  echo "  PASS  organically worded nested prompts pass with singular output"
  PASS=$((PASS + 1))
else
  echo "  FAIL  organically worded nested prompts pass with singular output"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: organic prompt rejected or reported with incorrect grammar"
fi

empty_output=""
if empty_output=$(bun "$CHECKER" "$fixture_root/empty" 2>&1); then
  echo "  FAIL  an empty prompt set cannot pass"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: empty prompt set passed"
elif printf '%s\n' "$empty_output" | grep -q 'No candidate-facing PROMPT.md files found'; then
  echo "  PASS  an empty prompt set cannot pass"
  PASS=$((PASS + 1))
else
  echo "  FAIL  empty prompt failure explains the missing contract"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: empty prompt failure was unclear"
fi

cat > "$fixture_root/leak/PROMPT.md" <<'EOF'
# Task

The hidden grader scores whether the candidate model follows the rubric.
EOF

leak_output=""
if leak_output=$(bun "$CHECKER" "$fixture_root/leak" 2>&1); then
  echo "  FAIL  evaluator-aware prompts are rejected"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: evaluator-aware prompt accepted"
elif printf '%s\n' "$leak_output" | grep -q 'PROMPT.md:3'; then
  echo "  PASS  evaluator-aware prompts are rejected with locations"
  PASS=$((PASS + 1))
else
  echo "  FAIL  evaluator-aware rejection names the prompt location"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: prompt rejection omitted location"
fi

if bun "$CHECKER" "$REPO_ROOT/agent-evals/evals" >/dev/null 2>&1; then
  echo "  PASS  repository agent-eval prompts stay evaluator-blind"
  PASS=$((PASS + 1))
else
  echo "  FAIL  repository agent-eval prompts stay evaluator-blind"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: repository prompt leaks evaluator context"
fi

rm -rf "$fixture_root"
