# Evals for the brainstorming -> grilling merge and commit-push -> --no-pr fold (wave 6).

GRILL="$REPO_ROOT/grilling/SKILL.md"

# Merged directories stay dead.
for dead in brainstorming commit-push; do
  if [ -e "$REPO_ROOT/$dead" ]; then
    echo "  FAIL  $dead/ still exists after wave-6 merge"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: $dead/ still exists"
  else
    echo "  PASS  $dead/ removed after wave-6 merge"
    PASS=$((PASS + 1))
  fi
done

# Grilling absorbed brainstorming.
run_content_eval "$GRILL" "brainstorming approaches" "grilling description carries brainstorming trigger words"
run_content_eval "$GRILL" "Explore mode" "grilling has explore mode"
run_content_eval "$GRILL" "2-3 approaches with trade-offs" "explore mode proposes approaches with trade-offs"
run_content_eval "$GRILL" "Challenge variant" "explore mode keeps challenge variant"
run_content_eval "$GRILL" "no production code or implementation until a direction is presented" "hard gate applies to any direction, not design only"
run_content_eval "$GRILL" "/plan-arbiter" "explore mode routes competing plans to plan-arbiter"
run_content_eval "$GRILL" "frontier" "grilling maps the currently answerable frontier"
run_content_eval "$GRILL" "whole frontier" "grilling asks the whole frontier each round"
run_content_eval "$GRILL" "Recompute the frontier" "grilling recomputes after each answer round"
run_content_eval "$GRILL" "fact-finding inline" "fact-finding stays inline without delegation consent"

if grep -q "Ask the questions one at a time" "$GRILL"; then
  echo "  FAIL  grilling still forces one-question-at-a-time interviews"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: grilling still uses one-question-at-a-time"
else
  echo "  PASS  grilling no longer forces one-question-at-a-time interviews"
  PASS=$((PASS + 1))
fi

# commit-push folded into commit-push-pr --no-pr.
CPP="$REPO_ROOT/commit-push-pr/SKILL.md"
run_content_eval "$CPP" "--no-pr" "commit-push-pr documents --no-pr flag"
run_content_eval "$CPP" "--no-pr.*ends after|ends after.*push" "phase 5 stops the PR track under --no-pr"
run_content_eval "$REPO_ROOT/.claude/hooks/lifecycle-stop.sh" "Commit the requested scope" "lifecycle-stop prescribes the surviving commit path"

# No stale invocations of the dead names outside history.
_stale=$(grep -rlnE '`/(brainstorming|commit-push)`' "$REPO_ROOT" --include='*.md' 2>/dev/null | grep -v CHANGELOG | grep -v "$REPO_ROOT/docs/" || true)
if [ -n "$_stale" ]; then
  echo "  FAIL  stale /brainstorming or /commit-push invocation in: $_stale"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: stale merged-skill references"
else
  echo "  PASS  no stale /brainstorming or /commit-push invocations outside history"
  PASS=$((PASS + 1))
fi
