# Evals for setup-react-doctor skill

SCRIPT="$REPO_ROOT/.agents/skills/setup-react-doctor/scripts/react-doctor-stop.sh"
SKILL_DIR="$REPO_ROOT/.agents/skills/setup-react-doctor"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_executable_eval "$SCRIPT" "react-doctor-stop.sh is executable"
run_file_eval "$REPO_ROOT/.claude/skills/setup-react-doctor" "symlink exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-react-doctor" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "react-doctor" "SKILL.md mentions react-doctor"
run_content_eval "$SKILL_DIR/SKILL.md" "redpanda-ui" "SKILL.md mentions redpanda-ui exclusion"
run_content_eval "$SKILL_DIR/SKILL.md" "react-doctor.config.json" "SKILL.md mentions config file"

# ── REFERENCE content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "bun run doctor" "REFERENCE uses package.json script"
run_content_eval "$SKILL_DIR/REFERENCE.md" "--diff" "REFERENCE uses diff mode"
run_content_eval "$SKILL_DIR/REFERENCE.md" "--score" "REFERENCE uses score mode"
run_content_eval "$SKILL_DIR/REFERENCE.md" "decision.*block" "REFERENCE blocks on failure"

# ── Hook script content ─────────────────────────────────────────

run_content_eval "$SCRIPT" "bun run doctor" "hook uses package.json script (not bunx)"
run_content_eval "$SCRIPT" "git diff --name-only" "hook checks for changed files"
run_content_eval "$SCRIPT" "tsx|jsx" "hook filters React files"
