# Evals for setup-registry-workflow skill

SCRIPT="$REPO_ROOT/.agents/skills/setup-registry-workflow/scripts/registry-check.sh"
SKILL_DIR="$REPO_ROOT/.agents/skills/setup-registry-workflow"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "registry-check.sh is executable"
run_file_eval "$REPO_ROOT/.claude/skills/setup-registry-workflow" "symlink exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-registry-workflow" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "registry.json" "SKILL.md mentions registry.json"
run_content_eval "$SKILL_DIR/SKILL.md" "redpanda-ui" "SKILL.md mentions redpanda-ui"
run_content_eval "$SKILL_DIR/SKILL.md" "changelog" "SKILL.md mentions changelog"

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "redpanda-ui/" "hook checks for redpanda-ui changes"
run_content_eval "$SCRIPT" "registry.json" "hook checks for registry.json update"
run_content_eval "$SCRIPT" "decision.*block" "hook blocks when registry not rebuilt"
run_content_eval "$SCRIPT" "CHANGELOG" "hook reminds about changelog"
