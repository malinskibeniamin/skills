# Evals for setup-llm-optimization skill

ENV_SCRIPT="$REPO_ROOT/setup-llm-optimization/scripts/llm-env.sh"
FLAGS_SCRIPT="$REPO_ROOT/setup-llm-optimization/scripts/llm-test-flags.sh"
TRUNCATE_SCRIPT="$REPO_ROOT/setup-llm-optimization/scripts/llm-truncate.sh"
SKILL_DIR="$REPO_ROOT/setup-llm-optimization"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$ENV_SCRIPT" "llm-env.sh is executable"
run_executable_eval "$FLAGS_SCRIPT" "llm-test-flags.sh is executable"
run_executable_eval "$TRUNCATE_SCRIPT" "llm-truncate.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-llm-optimization" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "AI_AGENT" "SKILL.md mentions AI_AGENT"
run_content_eval "$SKILL_DIR/SKILL.md" "CLAUDECODE" "SKILL.md mentions CLAUDECODE"

# ── llm-env.sh ──────────────────────────────────────────────────

CLAUDE_ENV_FILE=$(mktemp)
export CLAUDE_ENV_FILE
"$ENV_SCRIPT"

for var in AI_AGENT CLAUDECODE; do
  if grep -qF "$var" "$CLAUDE_ENV_FILE"; then
    echo "  PASS  llm-env.sh sets $var"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  llm-env.sh missing $var"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: llm-env.sh missing $var"
  fi
done

rm -f "$CLAUDE_ENV_FILE"
unset CLAUDE_ENV_FILE

# ── llm-test-flags.sh ──────────────────────────────────────────

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_input":{"command":"vitest --verbose"}}' \
  2 "block: vitest --verbose" "--verbose"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_input":{"command":"bun test --verbose"}}' \
  2 "block: bun test --verbose" "--verbose"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_input":{"command":"jest --verbose"}}' \
  2 "block: jest --verbose" "--verbose"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_input":{"command":"vitest --run"}}' \
  0 "allow: vitest --run (no verbose)"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_input":{"command":"bun test"}}' \
  0 "allow: bun test (no verbose)"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_input":{"command":"echo hello"}}' \
  0 "allow: unrelated command"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_input":{"command":""}}' \
  0 "allow: empty command"

# ── llm-truncate.sh ────────────────────────────────────────────

# Test with short output (should pass through)
short_result=$(printf 'line %d\n' $(seq 1 50) | jq -Rs .)
run_hook_eval "$TRUNCATE_SCRIPT" \
  "{\"tool_name\":\"Bash\",\"tool_result\":$(echo "$short_result")}" \
  0 "pass through: output under 200 lines"

# Test with long output (should truncate)
long_result=$(printf 'line %d\n' $(seq 1 300) | jq -Rs .)
run_hook_eval "$TRUNCATE_SCRIPT" \
  "{\"tool_name\":\"Bash\",\"tool_result\":$(echo "$long_result")}" \
  0 "truncate: output over 200 lines" "truncated"

# Test with non-Bash tool (should skip)
run_hook_eval "$TRUNCATE_SCRIPT" \
  '{"tool_name":"Read","tool_result":"some content"}' \
  0 "skip: non-Bash tool"

# Test with empty result
run_hook_eval "$TRUNCATE_SCRIPT" \
  '{"tool_name":"Bash","tool_result":""}' \
  0 "skip: empty result"
