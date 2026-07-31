# Evals for react-compiler reference (React Doctor-delegated; hook retired)

SKILL_DIR="$REPO_ROOT/frontend-starter-kit/references/react-compiler"

run_file_eval "$SKILL_DIR/README.md" "README.md exists"
run_file_eval "$SKILL_DIR/REFERENCE.md" "REFERENCE.md exists"

run_content_eval "$SKILL_DIR/README.md" "rsbuild" "README mentions rsbuild"
run_content_eval "$SKILL_DIR/README.md" "React Doctor" "README routes enforcement to React Doctor"
run_content_eval "$SKILL_DIR/REFERENCE.md" "react-compiler-no-manual-memoization" "REFERENCE names the owning React Doctor rule"
run_content_eval "$SKILL_DIR/REFERENCE.md" "was retired" "REFERENCE records the hook retirement"
run_content_eval "$SKILL_DIR/REFERENCE.md" "remain correct" \
  "manual memoization never carries application correctness"
run_content_eval "$SKILL_DIR/REFERENCE.md" "discards the cache" \
  "manual memoization documents React cache invalidation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "directly from.*react" \
  "compiler-sensitive hooks keep their recognized import source"
run_content_eval "$SKILL_DIR/REFERENCE.md" "does not require.*use no memo" \
  "manual memoization does not opt the component out of compilation"
run_content_eval "$SKILL_DIR/REFERENCE.md" "file-scoped" \
  "proven manual memoization uses a narrow React Doctor exception"

if grep -qE \
  'correctness-critical referential stability|referential stability for \*\*correctness\*\*' \
  "$SKILL_DIR/REFERENCE.md"; then
  echo "  FAIL  REFERENCE still treats memoization as a correctness guarantee"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: REFERENCE still treats memoization as a correctness guarantee"
else
  echo "  PASS  REFERENCE keeps memoization optimization-only"
  PASS=$((PASS + 1))
fi

AUTO_EVAL="$REPO_ROOT/agent-evals/evals/setup-react-compiler/EVAL.ts"
run_content_eval "$AUTO_EVAL" "expect\(hasUseNoMemo\)\.toBe\(false\)" \
  "ordinary compiler eval rejects use-no-memo workarounds"

IDENTITY_EVAL="$REPO_ROOT/agent-evals/evals/react-compiler-manual-identity"
run_file_eval "$IDENTITY_EVAL/PROMPT.md" "manual identity eval prompt exists"
run_file_eval "$IDENTITY_EVAL/EVAL.ts" "manual identity eval assertions exist"
run_content_eval "$IDENTITY_EVAL/PROMPT.md" "remain correct" \
  "manual identity eval preserves correctness without the cache"
run_content_eval "$IDENTITY_EVAL/EVAL.ts" "from.*react" \
  "manual identity eval requires a compiler-recognized import"
run_content_eval "$IDENTITY_EVAL/EVAL.ts" "use no memo" \
  "manual identity eval keeps the component compiled"

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
run_content_eval "$RD_REF" "react-compiler-no-manual-memoization" "react-doctor reference owns the compiler rules"
run_content_eval "$RD_REF" "pinned npm release" "react-doctor reference mandates version pinning"
