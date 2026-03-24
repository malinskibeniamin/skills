# Evals for frontend-starter-kit meta-skill

SKILL_DIR="$REPO_ROOT/.agents/skills/frontend-starter-kit"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$REPO_ROOT/.claude/skills/frontend-starter-kit" "symlink exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: frontend-starter-kit" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "setup-toolchain" "references setup-toolchain"
run_content_eval "$SKILL_DIR/SKILL.md" "setup-biome" "references setup-biome"
run_content_eval "$SKILL_DIR/SKILL.md" "setup-quality-gate" "references setup-quality-gate"
run_content_eval "$SKILL_DIR/SKILL.md" "setup-llm-optimization" "references setup-llm-optimization"
run_content_eval "$SKILL_DIR/SKILL.md" "setup-react-compiler" "references setup-react-compiler"

# ── All referenced skills exist ──────────────────────────────────

for dep_skill in setup-toolchain setup-biome setup-quality-gate setup-llm-optimization setup-react-compiler; do
  run_file_eval "$REPO_ROOT/.agents/skills/$dep_skill/SKILL.md" "dependency: $dep_skill exists"
done
