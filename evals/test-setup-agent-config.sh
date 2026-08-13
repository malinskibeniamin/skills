# Evals for setup-agent-config skill

ENV_SCRIPT="$REPO_ROOT/frontend-starter-kit/references/agent-config/scripts/llm-env.sh"
FLAGS_SCRIPT="$REPO_ROOT/frontend-starter-kit/references/agent-config/scripts/llm-test-flags.sh"
TRUNCATE_SCRIPT="$REPO_ROOT/frontend-starter-kit/references/agent-config/scripts/llm-truncate.sh"
SKILL_DIR="$REPO_ROOT/frontend-starter-kit/references/agent-config"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/README.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$ENV_SCRIPT" "llm-env.sh is executable"
run_executable_eval "$FLAGS_SCRIPT" "llm-test-flags.sh is executable"
run_executable_eval "$TRUNCATE_SCRIPT" "llm-truncate.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/README.md" "AI_AGENT" "SKILL.md mentions AI_AGENT"
run_content_eval "$SKILL_DIR/README.md" "CLAUDECODE" "SKILL.md mentions CLAUDECODE"
run_content_eval "$SKILL_DIR/README.md" "NODE_OPTIONS" "SKILL.md mentions NODE_OPTIONS"
run_content_eval "$SKILL_DIR/README.md" "pool=threads" "SKILL.md mentions pool=threads"
run_content_eval "$SKILL_DIR/README.md" "Rstest" "SKILL.md documents Rstest optimization"

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

# ── Rewrite: strip --verbose via updatedInput (exit 0, not 2) ──

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"vitest --verbose"}}' \
  0 "rewrite: vitest --verbose → strip verbose" "updatedInput"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun test --verbose"}}' \
  0 "rewrite: bun test --verbose → strip verbose" "updatedInput"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"rstest run --reporters=verbose"}}' \
  0 "rewrite: Rstest verbose reporter → md" "--reporters=md"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"jest --verbose"}}' \
  0 "skip: Jest is outside the configured stack"

# ── Suggestions: vitest without flags gets additionalContext ────

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"vitest --run"}}' \
  0 "suggest: vitest --run (no verbose)" "pool=threads"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"bun test"}}' \
  0 "suggest: bun test" "bail"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"rstest run"}}' \
  0 "suggest: Rstest run" "--bail=1"

# ── No modification: flags already present ──────────────────────

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"vitest --pool=threads --bail=5 --teardownTimeout=10000"}}' \
  0 "skip: all flags already present"

# ── No modification: unrelated commands ─────────────────────────

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo hello"}}' \
  0 "skip: unrelated command"

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":""}}' \
  0 "skip: empty command"

# ── Skip: non-Bash tool ────────────────────────────────────────

run_hook_eval "$FLAGS_SCRIPT" \
  '{"tool_name":"Read","tool_input":{"file_path":"foo.ts"}}' \
  0 "skip: non-Bash tool"

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
