# Evals for react-compiler reference (React Doctor-delegated; hook retired)

SKILL_DIR="$REPO_ROOT/frontend-starter-kit/references/react-compiler"

run_file_eval "$SKILL_DIR/README.md" "README.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"

run_content_eval "$SKILL_DIR/README.md" "rsbuild" "README mentions rsbuild"
run_content_eval "$SKILL_DIR/README.md" "React Doctor" "README routes enforcement to React Doctor"
run_content_eval "$SKILL_DIR/REFERENCE.md" "react-compiler-no-manual-memoization" "REFERENCE names the owning React Doctor rule"
run_content_eval "$SKILL_DIR/REFERENCE.md" "was retired" "REFERENCE records the hook retirement"

# The hook must stay dead in every install surface.
for _p in ".claude/hooks/react-compiler-check.sh" ".claude/hooks/checks/react-compiler-check.lib.sh" "frontend-starter-kit/references/react-compiler/scripts/react-compiler-check.sh"; do
  if [ -e "$REPO_ROOT/$_p" ]; then
    echo "  FAIL  $_p resurrected — React Doctor owns compiler-pattern rules"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $_p resurrected"
  else
    echo "  PASS  $_p stays retired"
    PASS=$((PASS + 1))
  fi
done

# React Doctor reference records the full ownership map.
RD_REF="$REPO_ROOT/frontend-starter-kit/references/react-doctor/REFERENCE.md"
run_content_eval "$RD_REF" "react-compiler-check \(all 3 rules\)" "react-doctor reference owns the compiler rules"
run_content_eval "$RD_REF" "Pin the react-doctor version" "react-doctor reference mandates version pinning"
