# Evals for redpanda-frontend-kit meta-skill

SKILL_DIR="$REPO_ROOT/redpanda-frontend-kit"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: redpanda-frontend-kit" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "frontend-starter-kit" "references frontend-starter-kit"
run_content_eval "$SKILL_DIR/SKILL.md" "setup-react-rules" "references setup-react-rules"
run_content_eval "$SKILL_DIR/SKILL.md" "setup-react-doctor" "references setup-react-doctor"
run_content_eval "$SKILL_DIR/SKILL.md" "setup-tanstack-router" "references setup-tanstack-router"

# ── All referenced skills exist ──────────────────────────────────

for dep_skill in frontend-starter-kit setup-react-rules setup-react-doctor setup-tanstack-router; do
  run_file_eval "$REPO_ROOT/$dep_skill/SKILL.md" "dependency: $dep_skill exists"
done
