# Evals for test-guardian skill

SKILL_DIR="$REPO_ROOT/.agents/skills/test-guardian"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_file_eval "$REPO_ROOT/.claude/skills/test-guardian" "symlink exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: test-guardian" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "detectAsyncLeaks|detectOpenHandles" "SKILL.md mentions leak detection"
run_content_eval "$SKILL_DIR/SKILL.md" "Vitest" "SKILL.md mentions Vitest"
run_content_eval "$SKILL_DIR/SKILL.md" "Jest" "SKILL.md mentions Jest"

# ── REFERENCE content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "AI_AGENT" "REFERENCE mentions AI_AGENT"
run_content_eval "$SKILL_DIR/REFERENCE.md" "CLAUDECODE" "REFERENCE mentions CLAUDECODE"
run_content_eval "$SKILL_DIR/REFERENCE.md" "happy-dom" "REFERENCE mentions happy-dom optimization"
run_content_eval "$SKILL_DIR/REFERENCE.md" "cpu-prof" "REFERENCE mentions CPU profiling"
run_content_eval "$SKILL_DIR/REFERENCE.md" "detectAsyncLeaks|detectOpenHandles" "REFERENCE documents leak detection"
