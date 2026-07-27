# Evals for /deslop liability gate.

SKILL_DIR="$REPO_ROOT/deslop"
SKILL="$SKILL_DIR/SKILL.md"
REF="$SKILL_DIR/REFERENCE.md"

run_file_eval "$SKILL" "deslop skill exists"
run_content_eval "$SKILL" "Fallback, not lifecycle" "deslop is a fallback, not a mandatory pass"
run_content_eval "$SKILL" "Advocate for less is more" "deslop explicitly advocates less is more"
run_content_eval "$SKILL" "semantic density" "deslop optimizes semantic density"
run_content_eval "$SKILL" "negative LOC is not the goal" "deslop rejects code golf metrics"
run_content_eval "$SKILL" "demonstrated scale" "deslop rejects speculative scale machinery"
run_content_eval "$SKILL" "required behavior.*clarifying the domain.*credible risk" "deslop has evidence-based admission gate"
run_content_eval "$SKILL" "standard library|native platform|already-installed|smallest clear" "deslop checks existing capabilities before custom code"
run_content_eval "$SKILL" "RED.*GREEN eval evidence" "deslop preserves eval evidence for harness changes"
run_content_eval "$SKILL" "NEEDS_CHANGES" "deslop can block avoidable surface area"
run_content_eval "$SKILL" "REFERENCE.md" "deslop links reference"
run_content_eval "$REF" "Surface-area budget" "deslop reference defines surface-area budget"
run_content_eval "$REF" "Required behavior|Domain clarity|Credible risk" "deslop reference defines keep rules"
run_content_eval "$REF" "standard library|native platform|smallest clear" "deslop reference documents reuse-first ladder"

# intent-detect no longer injects CODE-LIABILITY/REUSE-FIRST blobs — those
# rules live in CLAUDE.md and are enforced by deslop + reviewer agents
# (2026-07 audit: injection budget, no CLAUDE.md duplication).
run_content_eval "$REPO_ROOT/agents/self-reviewer.md" "Less Code, More Meaning|semantic density" "self-reviewer audits semantic density"
run_content_eval "$REPO_ROOT/agents/self-reviewer.md" "standard library|native platform|already-installed" "self-reviewer audits reuse-first alternatives"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "Less Code, More Meaning|semantic density" "code-reviewer audits semantic density"
run_content_eval "$REPO_ROOT/agents/code-reviewer.md" "standard library|native platform|already-installed" "code-reviewer audits reuse-first alternatives"
run_content_eval "$REPO_ROOT/ETHOS.md" "Less Code, More Meaning" "ETHOS records less-is-more principle"

if jq -e '.skills[] | select(. == "./deslop/")' "$REPO_ROOT/.claude-plugin/plugin.json" >/dev/null 2>&1; then
  echo "  PASS  Claude plugin registers deslop"
  PASS=$((PASS + 1))
else
  echo "  FAIL  Claude plugin registers deslop"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Claude plugin registers deslop"
fi

if jq -e '.skills[] | select(. == "./simplify/")' "$REPO_ROOT/.claude-plugin/plugin.json" >/dev/null 2>&1; then
  echo "  FAIL  Claude plugin does not register simplify shim"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: Claude plugin still registers simplify shim"
else
  echo "  PASS  Claude plugin does not register simplify shim"
  PASS=$((PASS + 1))
fi
