# Evals for work-automation-kit meta-skill

SKILL_DIR="$REPO_ROOT/work-automation-kit"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: work-automation-kit" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "to-spec" "references to-spec (mattpocock)"
run_content_eval "$SKILL_DIR/SKILL.md" "brainstorming" "references brainstorming (owned)"
run_content_eval "$SKILL_DIR/SKILL.md" "to-tickets" "references to-tickets (mattpocock)"
run_content_eval "$SKILL_DIR/SKILL.md" "visual-plan.*visual-recap.*plan-arbiter.*agent-watchdog.*read-the-damn-docs" "references Builder planning and review helpers"
run_content_eval "$SKILL_DIR/SKILL.md" "quick-recap.*stay-within-limits.*efficient-frontier" "references Builder status and orchestration helpers"
run_content_eval "$SKILL_DIR/SKILL.md" "bunx skills@latest add" "uses bunx (not npx) to install"
