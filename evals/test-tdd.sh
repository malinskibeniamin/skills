SKILL_DIR="$REPO_ROOT/tdd"

run_file_eval "$SKILL_DIR/SKILL.md" "SKILL.md exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: tdd" "SKILL.md has correct name"
run_content_eval "$SKILL_DIR/SKILL.md" "Use when" "SKILL.md has trigger phrase"

desc=$(grep '^description:' "$SKILL_DIR/SKILL.md" | sed 's/^description: //' | tr -d '"')
desc_len=${#desc}
if [ $desc_len -le 250 ]; then
  echo "  PASS  description under 250 chars ($desc_len)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  description over 250 chars ($desc_len)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: description over 250 chars ($desc_len)"
fi

line_count=$(wc -l < "$SKILL_DIR/SKILL.md" | tr -d ' ')
if [ "$line_count" -le 100 ]; then
  echo "  PASS  SKILL.md under 100 lines ($line_count)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  SKILL.md over 100 lines ($line_count)"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: SKILL.md over 100 lines ($line_count)"
fi

run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"
run_file_eval "$SKILL_DIR/tests.md" "tests.md exists (good vs bad test philosophy)"
run_content_eval "$SKILL_DIR/SKILL.md" "tests\\.md" "SKILL.md links to tests.md"
run_content_eval "$SKILL_DIR/SKILL.md" "domain glossary" "SKILL.md references project domain glossary"
run_content_eval "$SKILL_DIR/SKILL.md" "ADRs" "SKILL.md references ADRs"
run_content_eval "$SKILL_DIR/SKILL.md" "RED.*GREEN.*REFACTOR" "SKILL.md has TDD cycle"
run_content_eval "$SKILL_DIR/SKILL.md" "language.*platform.*installed dependency|installed dependency.*platform" "GREEN phase prefers existing capabilities"
run_content_eval "$SKILL_DIR/SKILL.md" "paths:" "SKILL.md has paths: for auto-loading"
run_content_eval "$SKILL_DIR/SKILL.md" "## Test seams and anti-patterns" "SKILL.md preserves test seams section"
run_content_eval "$SKILL_DIR/SKILL.md" "No tests at unconfirmed internals" "SKILL.md rejects unconfirmed internal seams"
run_content_eval "$SKILL_DIR/SKILL.md" "independent source of truth" "SKILL.md rejects tautological tests"
run_content_eval "$SKILL_DIR/SKILL.md" "vertical slices" "SKILL.md requires vertical TDD slices"
run_content_eval "$SKILL_DIR/REFERENCE.md" "setTimeout|waitForTimeout" "REFERENCE has condition-based waiting"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Common Agent Excuses" "REFERENCE has rationalization table"
run_content_eval "$SKILL_DIR/REFERENCE.md" "detectAsyncLeaks" "REFERENCE has async leak detection"
run_content_eval "$SKILL_DIR/REFERENCE.md" "pool.*threads" "REFERENCE has pool: threads optimization"
run_content_eval "$SKILL_DIR/REFERENCE.md" "isolate.*false.*Incompatible" "REFERENCE bans isolate: false with reason"
run_content_eval "$SKILL_DIR/REFERENCE.md" "two fields.*independent|independent.*two fields" "REFERENCE tests delayed validation isolation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "test\\('ignores stale async validation results" "REFERENCE has RED stale-validation test"
run_content_eval "$SKILL_DIR/REFERENCE.md" "test\\('clears dependent field state when its parent changes" "REFERENCE has RED dependent-cleanup test"
run_content_eval "$SKILL_DIR/REFERENCE.md" "test\\('renders every validation error" "REFERENCE has RED all-errors test"

# ── Coverage is diagnostic, never a quota ───────────────────────
run_content_eval "$SKILL_DIR/SKILL.md" "Coverage.*never a target|never a target.*Coverage" "SKILL.md rejects coverage targets"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Coverage as Investigation" "REFERENCE treats coverage as investigation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "Never set a percentage target" "REFERENCE rejects percentage targets"

# ── Visual regression test section ──────────────────────────────
run_content_eval "$SKILL_DIR/SKILL.md" "Visual Regression|browser.test" "SKILL.md has visual regression test section"
run_content_eval "$SKILL_DIR/SKILL.md" "@vitest/browser" "SKILL.md mentions vitest browser mode detection"

# ── Performance optimization in REFACTOR step ────────────────────
run_content_eval "$SKILL_DIR/SKILL.md" "500ms|execution time" "SKILL.md has perf optimization in REFACTOR"
run_content_eval "$SKILL_DIR/SKILL.md" "per-keystroke|bulk input" "SKILL.md warns about slow input simulation"
