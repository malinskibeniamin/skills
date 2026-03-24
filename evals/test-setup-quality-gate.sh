# Evals for setup-quality-gate skill

SCRIPT="$REPO_ROOT/.agents/skills/setup-quality-gate/scripts/typecheck-stop.sh"
SKILL_DIR="$REPO_ROOT/.agents/skills/setup-quality-gate"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "typecheck-stop.sh is executable"
run_file_eval "$REPO_ROOT/.claude/skills/setup-quality-gate" "symlink exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-quality-gate" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "quality:gate" "SKILL.md mentions quality:gate script"
run_content_eval "$SKILL_DIR/SKILL.md" "tsgo" "SKILL.md mentions tsgo"
run_content_eval "$SKILL_DIR/SKILL.md" "GitHub Actions" "SKILL.md mentions CI"

# ── REFERENCE.md content ────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "quality-gate.yml" "REFERENCE has workflow filename"
run_content_eval "$SKILL_DIR/REFERENCE.md" "git diff --exit-code" "REFERENCE has formatting integrity check"
run_content_eval "$SKILL_DIR/REFERENCE.md" "tsgo --noEmit" "REFERENCE has tsgo command"
run_content_eval "$SKILL_DIR/REFERENCE.md" "bun run typecheck" "REFERENCE has typecheck step"
run_content_eval "$SKILL_DIR/REFERENCE.md" "related" "REFERENCE mentions related tests"

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "tsgo" "hook runs tsgo"
run_content_eval "$SCRIPT" "decision.*block" "hook blocks on failure"
run_content_eval "$SCRIPT" "head -30" "hook truncates output"
