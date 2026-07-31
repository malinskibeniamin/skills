# AGENTS.md is now GENERATED from CLAUDE.md + .agents/codex-appendix.md.
if bash "$REPO_ROOT/scripts/generate-agents-md.sh" --check >/dev/null 2>&1; then
  echo "  PASS  AGENTS.md matches generated output (single source: CLAUDE.md)"
  PASS=$((PASS + 1))
else
  echo "  FAIL  AGENTS.md drifted from generated output -- run scripts/generate-agents-md.sh --apply"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: AGENTS.md generation drift"
fi

# Routing is data, not duplicated subjective prose.
ROUTING="$REPO_ROOT/config/model-routing.json"
run_file_eval "$ROUTING" "model routing source exists"
run_content_eval "$REPO_ROOT/CLAUDE.md" "config/model-routing.json" \
  "ambient rules point to the routing source"
run_content_eval "$REPO_ROOT/AGENTS.md" "config/model-routing.json" \
  "generated Codex rules point to the routing source"

for query in \
  '.policy == "quality-first"' \
  '.quality_first.default.model == "gpt-5.6-sol"' \
  '.selection.single_owner == true' \
  '.selection.cross_family_review_for_non_trivial_pr == false'; do
  if jq -e "$query" "$ROUTING" >/dev/null; then
    echo "  PASS  routing contract: $query"
    PASS=$((PASS + 1))
  else
    echo "  FAIL  routing contract: $query"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: routing contract: $query"
  fi
done

if grep -qE '[0-9]+/[0-9]+/[0-9]+|intelligence > taste > cost' \
  "$REPO_ROOT/CLAUDE.md" "$REPO_ROOT/AGENTS.md"; then
  echo "  FAIL  subjective model rankings returned to ambient context"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: ambient subjective model rankings"
else
  echo "  PASS  ambient context omits subjective model rankings"
  PASS=$((PASS + 1))
fi
