# Evals for codex-compat skill

SCRIPT="$REPO_ROOT/codex-compat/scripts/codex-batch-check.sh"
SKILL_DIR="$REPO_ROOT/codex-compat"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "codex-batch-check.sh is executable"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: codex-compat" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "^description:" "SKILL.md has description"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "Codex" "SKILL.md mentions Codex"
run_content_eval "$SKILL_DIR/SKILL.md" "AGENTS.md" "SKILL.md mentions AGENTS.md"
run_content_eval "$SKILL_DIR/SKILL.md" "Stop" "SKILL.md mentions Stop hook"

# ── REFERENCE.md content ────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "codex-batch-check" "REFERENCE has batch checker"
run_content_eval "$SKILL_DIR/REFERENCE.md" ".codex/hooks.json" "REFERENCE has hooks.json template"
run_content_eval "$SKILL_DIR/REFERENCE.md" "AGENTS.md" "REFERENCE has AGENTS.md template"
run_content_eval "$SKILL_DIR/REFERENCE.md" "PreToolUse" "REFERENCE maps PreToolUse hooks"
run_content_eval "$SKILL_DIR/REFERENCE.md" "SessionStart" "REFERENCE maps SessionStart hooks"
run_content_eval "$SKILL_DIR/REFERENCE.md" "git diff --name-only" "REFERENCE uses git diff for changed files"
run_content_eval "$SKILL_DIR/REFERENCE.md" "tool_name.*Write" "REFERENCE simulates Write tool JSON"

# ── Hook script content checks ──────────────────────────────────

run_content_eval "$SCRIPT" "git diff --name-only" "hook gets changed files"
run_content_eval "$SCRIPT" ".claude/hooks" "hook delegates to claude hooks dir"
run_content_eval "$SCRIPT" "check.sh" "hook runs *-check.sh scripts"
run_content_eval "$SCRIPT" "bundle-guard" "hook runs bundle-guard on package.json"
run_content_eval "$SCRIPT" "tool_name.*Write" "hook simulates Write tool input"
run_content_eval "$SCRIPT" "decision.*block" "hook blocks on failures"
run_content_eval "$SCRIPT" "systemMessage" "hook reads systemMessage from output"
