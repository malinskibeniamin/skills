# Evals for the standalone architecture-deepening skill.

SKILL_DIR="$REPO_ROOT/improve-codebase-architecture"

run_file_eval "$SKILL_DIR/SKILL.md" "architecture skill exists"
run_file_eval "$SKILL_DIR/HTML-REPORT.md" "architecture HTML report reference exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "architecture lenses reference exists"
run_content_eval "$SKILL_DIR/SKILL.md" "^name: improve-codebase-architecture$" "architecture skill has matching name"
run_content_eval "$SKILL_DIR/SKILL.md" "disable-model-invocation: true" "architecture skill remains explicitly invoked"
run_content_eval "$SKILL_DIR/SKILL.md" "author: Matt Pocock" "architecture skill preserves Matt Pocock provenance"
run_content_eval "$SKILL_DIR/SKILL.md" "/codebase-design" "architecture skill uses shared architecture vocabulary"
run_content_eval "$SKILL_DIR/SKILL.md" "\[REFERENCE.md\]" "architecture skill discloses detailed lenses"
run_content_eval "$SKILL_DIR/SKILL.md" "class(es)? of errors|error class" "architecture skill targets error classes"
run_content_eval "$SKILL_DIR/SKILL.md" "[Ss]tructural invariant" "architecture skill makes invariants explicit"
run_content_eval "$SKILL_DIR/SKILL.md" "single source of truth|one source of truth" "architecture skill detects parallel bookkeeping"
run_content_eval "$SKILL_DIR/SKILL.md" "[Ii]nvalid states.*(impossible|unrepresentable)" "architecture skill prefers impossible invalid states"
run_content_eval "$SKILL_DIR/SKILL.md" "data ownership|state transitions|dependency graph|call graph" "architecture skill maps structural evidence"
run_content_eval "$SKILL_DIR/SKILL.md" "[Dd]eletion test" "architecture skill applies the deletion test"
run_content_eval "$SKILL_DIR/SKILL.md" "proposed invariant|target invariant" "architecture candidates state the invariant gained"
run_content_eval "$SKILL_DIR/SKILL.md" "regression test.*not.*architecture|tests.*verify.*design" "architecture skill does not substitute tests for design"
run_content_eval "$SKILL_DIR/SKILL.md" "HTML report|architecture-review" "architecture skill writes a visual report"
run_content_eval "$SKILL_DIR/SKILL.md" "Top recommendation" "architecture report includes top recommendation"
run_content_eval "$SKILL_DIR/SKILL.md" "/grilling" "architecture skill grills the chosen candidate"
run_content_eval "$SKILL_DIR/SKILL.md" "inline by default|delegation.*explicit" "architecture exploration respects delegation consent"
run_content_eval "$SKILL_DIR/SKILL.md" "generic audit|/improve" "architecture skill routes generic audits to shadcn improve"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\./improve-codebase-architecture/" "Claude plugin registers architecture skill"

if grep -qE '/improve architecture|references/architecture-report' "$REPO_ROOT/improve/SKILL.md"; then
  echo "  FAIL  shadcn improve still owns architecture mode"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: shadcn improve still owns architecture mode"
else
  echo "  PASS  shadcn improve no longer owns architecture mode"
  PASS=$((PASS + 1))
fi

if [ -e "$REPO_ROOT/improve/references/architecture-report.md" ]; then
  echo "  FAIL  architecture report remains coupled to shadcn improve"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: architecture report remains coupled to shadcn improve"
else
  echo "  PASS  architecture report is owned by architecture skill"
  PASS=$((PASS + 1))
fi
