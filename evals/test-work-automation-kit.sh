# Evals for work-automation-kit meta-skill

SKILL_DIR="$REPO_ROOT/work-automation-kit"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: work-automation-kit" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "write-a-prd" "references write-a-prd"
run_content_eval "$SKILL_DIR/SKILL.md" "prd-to-plan" "references prd-to-plan"
run_content_eval "$SKILL_DIR/SKILL.md" "prd-to-issues" "references prd-to-issues"
run_content_eval "$SKILL_DIR/SKILL.md" "triage-issue" "references triage-issue"
run_content_eval "$SKILL_DIR/SKILL.md" "bunx skills@latest add" "uses bunx (not npx) to install"
