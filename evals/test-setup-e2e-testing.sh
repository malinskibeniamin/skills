# Evals for setup-e2e-testing skill

SKILL_DIR="$REPO_ROOT/setup-e2e-testing"

# ── File structure ──────────────────────────────────────────────

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"

# ── SKILL.md content ────────────────────────────────────────────

run_content_eval "$SKILL_DIR/SKILL.md" "^name: setup-e2e-testing" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"
run_content_eval "$SKILL_DIR/SKILL.md" "playwright" "SKILL.md mentions Playwright"
run_content_eval "$SKILL_DIR/SKILL.md" "axe-core" "SKILL.md mentions axe-core"
run_content_eval "$SKILL_DIR/SKILL.md" "Testcontainers" "SKILL.md mentions Testcontainers"

# ── REFERENCE.md content ───────────────────────────────────────

run_content_eval "$SKILL_DIR/REFERENCE.md" "data-testid" "REFERENCE.md has test ID conventions"
run_content_eval "$SKILL_DIR/REFERENCE.md" "getByRole" "REFERENCE.md has selector priority"
run_content_eval "$SKILL_DIR/REFERENCE.md" "GenericContainer" "REFERENCE.md has Testcontainers setup"
run_content_eval "$SKILL_DIR/REFERENCE.md" "AxeBuilder" "REFERENCE.md has axe-core patterns"
run_content_eval "$SKILL_DIR/REFERENCE.md" "wcag2aa" "REFERENCE.md has WCAG tags"
run_content_eval "$SKILL_DIR/REFERENCE.md" "hanging-process\|zombie\|teardown" "REFERENCE.md mentions debugging"

# ── Description length ──────────────────────────────────────────

desc=$(grep '^description:' "$SKILL_DIR/SKILL.md" | sed 's/^description: //')
desc_len=${#desc}
if [ $desc_len -le 250 ]; then
  echo "  PASS  description under 250 chars ($desc_len)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  description over 250 chars ($desc_len)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: description over 250 chars ($desc_len)"
fi

# ── Line count ──────────────────────────────────────────────────

line_count=$(wc -l < "$SKILL_DIR/SKILL.md" | tr -d ' ')
if [ "$line_count" -le 100 ]; then
  echo "  PASS  SKILL.md under 100 lines ($line_count)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  SKILL.md over 100 lines ($line_count)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: SKILL.md over 100 lines ($line_count)"
fi
