# Evals for setup-tanstack-router skill

SCRIPT="$REPO_ROOT/.agents/skills/setup-tanstack-router/scripts/tanstack-router-gen.sh"
SKILL_DIR="$REPO_ROOT/.agents/skills/setup-tanstack-router"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "tanstack-router-gen.sh is executable"
run_file_eval "$REPO_ROOT/.claude/skills/setup-tanstack-router" "symlink exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-tanstack-router" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "generate:routes" "SKILL.md mentions generate:routes"
run_content_eval "$SKILL_DIR/SKILL.md" "tsr generate" "SKILL.md mentions tsr generate"

# ── Hook: skip non-Edit/Write ───────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Bash","tool_input":{"command":"echo"}}' \
  0 "skip: Bash tool"

# ── Hook: skip non-route files ──────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/src/components/Button.tsx"}}' \
  0 "skip: non-route file"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":"/tmp/src/utils/helpers.ts"}}' \
  0 "skip: utility file"

# ── Hook: skip non-TS/TSX files in routes ────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Write","tool_input":{"file_path":"/tmp/src/routes/README.md"}}' \
  0 "skip: non-TS file in routes"

# ── Hook: skip empty/missing path ────────────────────────────────

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{"file_path":""}}' \
  0 "skip: empty file_path"

run_hook_eval "$SCRIPT" \
  '{"tool_name":"Edit","tool_input":{}}' \
  0 "skip: no file_path field"

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "/routes/" "hook checks for routes directory"
run_content_eval "$SCRIPT" "bun run generate:routes" "hook uses package.json script"
run_content_eval "$SCRIPT" "suppressOutput" "hook suppresses output"
