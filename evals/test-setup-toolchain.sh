# Evals for setup-toolchain skill
# Tests hook scripts, file structure, and SKILL.md correctness

SCRIPT="$REPO_ROOT/.agents/skills/setup-toolchain/scripts/enforce-toolchain.sh"
SESSION_SCRIPT="$REPO_ROOT/.agents/skills/setup-toolchain/scripts/session-env.sh"
SKILL_DIR="$REPO_ROOT/.agents/skills/setup-toolchain"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "enforce-toolchain.sh is executable"
run_executable_eval "$SESSION_SCRIPT" "session-env.sh is executable"
run_file_eval "$REPO_ROOT/.claude/skills/setup-toolchain" "symlink in .claude/skills exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-toolchain" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "^description:" "SKILL.md has description"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md description has trigger phrase"

# ── npm blocked ─────────────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"npm install lodash"}}' \
  2 "block: npm install" "npm is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"npm run build"}}' \
  2 "block: npm run" "npm is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"npm test"}}' \
  2 "block: npm test" "npm is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"npm ci"}}' \
  2 "block: npm ci" "npm is banned"

# ── npx blocked ─────────────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"npx create-react-app myapp"}}' \
  2 "block: npx" "npx is banned"

# ── tsc blocked ─────────────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"tsc"}}' \
  2 "block: tsc (bare)" "tsc is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"tsc --noEmit"}}' \
  2 "block: tsc --noEmit" "tsc is banned"

# ── tsgo allowed ────────────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"tsgo --noEmit"}}' \
  0 "allow: tsgo --noEmit"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"tsgo"}}' \
  0 "allow: tsgo (bare)"

# ── global install blocked ──────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun add -g typescript"}}' \
  2 "block: bun add -g" "Global package installs are banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun install --global prettier"}}' \
  2 "block: bun install --global" "Global package installs are banned"

# ── --yarn enforcement ──────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun install"}}' \
  2 "block: bun install (no --yarn)" "--yarn"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun add lodash"}}' \
  2 "block: bun add (no --yarn)" "--yarn"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun install --yarn"}}' \
  0 "allow: bun install --yarn"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun add --yarn lodash"}}' \
  0 "allow: bun add --yarn"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun add lodash --yarn"}}' \
  0 "allow: bun add <pkg> --yarn (flag at end)"

# ── bunx for scripted tools blocked ─────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bunx biome check ."}}' \
  2 "block: bunx biome" "package.json script"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bunx ultracite fix"}}' \
  2 "block: bunx ultracite" "package.json script"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bunx react-doctor ."}}' \
  2 "block: bunx react-doctor" "package.json script"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bunx tsr generate"}}' \
  2 "block: bunx tsr" "package.json script"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bunx @tanstack/router-cli generate"}}' \
  2 "block: bunx @tanstack/router-cli" "package.json script"

# ── eslint/prettier blocked ──────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"eslint ."}}' \
  2 "block: eslint" "eslint is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"eslint --fix src/"}}' \
  2 "block: eslint --fix" "eslint is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"prettier --write ."}}' \
  2 "block: prettier" "prettier is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bunx eslint ."}}' \
  2 "block: bunx eslint" "eslint is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bunx prettier --write ."}}' \
  2 "block: bunx prettier" "prettier is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun add eslint --yarn"}}' \
  2 "block: bun add eslint" "Do not install eslint"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun add prettier --yarn"}}' \
  2 "block: bun add prettier" "Do not install"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun add -D eslint prettier --yarn"}}' \
  2 "block: bun add eslint+prettier" "Do not install"

# ── allowed commands ────────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun run build"}}' \
  0 "allow: bun run build"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun test"}}' \
  0 "allow: bun test"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun run lint"}}' \
  0 "allow: bun run lint"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bun run quality:gate"}}' \
  0 "allow: bun run quality:gate"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"echo hello"}}' \
  0 "allow: unrelated command"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"git status"}}' \
  0 "allow: git commands"

# ── chained commands ────────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"echo hello && npm run test"}}' \
  2 "block: npm in chained command" "npm is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"ls; npx something"}}' \
  2 "block: npx after semicolon" "npx is banned"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"cat file || tsc --noEmit"}}' \
  2 "block: tsc after ||" "tsc is banned"

# ── edge cases ──────────────────────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":""}}' \
  0 "allow: empty command"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{}}' \
  0 "allow: no command field"

run_hook_eval "$SCRIPT" \
  '{"tool_input":{"command":"bunx some-other-tool"}}' \
  0 "allow: bunx for non-scripted tools"

# ── session-env.sh ──────────────────────────────────────────────

# Test that session-env.sh writes expected env vars
CLAUDE_ENV_FILE=$(mktemp)
export CLAUDE_ENV_FILE
"$SESSION_SCRIPT"
session_exit=$?

if [ $session_exit -eq 0 ]; then
  echo "  PASS  session-env.sh exits 0"
  PASS=$((PASS + 1))
else
  echo "  FAIL  session-env.sh exits $session_exit (expected 0)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: session-env.sh exits $session_exit"
fi

for var in PKG_MANAGER LINTER TEST_RUNNER; do
  if grep -qF "$var" "$CLAUDE_ENV_FILE"; then
    echo "  PASS  session-env.sh sets $var"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  session-env.sh missing $var"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: session-env.sh missing $var"
  fi
done

rm -f "$CLAUDE_ENV_FILE"
unset CLAUDE_ENV_FILE
