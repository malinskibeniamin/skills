# Public instruction-contract checks, not proof of autonomous agent behavior.
# General packaging/proxy parity belongs to test-packaging-integrity.sh.

SKILL="$REPO_ROOT/full-send/SKILL.md"
FLOW="$REPO_ROOT/shared/delivery-workflow.md"

run_file_eval "$SKILL" "full-send skill exists"
run_content_eval "$SKILL" '^name: full-send$' "full-send has its requested public name"
run_content_eval "$SKILL" 'explicit.*full send|explicit.*full-send' \
  "full-send requires an explicit delivery request"
run_content_eval "$SKILL" 'earlier stop|Earlier stop' \
  "full-send preserves narrower user endpoints"
run_content_eval "$FLOW" 'head SHA.*base|HEAD.*base' \
  "full-send binds verification to head and base"
run_content_eval "$FLOW" 'required.*reviews|reviews.*required' \
  "full-send respects repository review requirements"
run_content_eval "$FLOW" 'missing.*not.*green|Missing.*not.*green' \
  "full-send does not confuse missing CI with passing CI"
run_content_eval "$FLOW" 'final verification|Final verification' \
  "full-send owns the last verification pass"
run_content_eval "$FLOW" 'merge.md' \
  "full-send uses the protected authorized-merge contract"
run_content_eval "$FLOW" 'merged.*queued|queued.*merged' \
  "full-send distinguishes confirmed merge from queue admission"
run_content_eval "$FLOW" 'external blocker|externally blocked' \
  "full-send has a genuine blocked endpoint"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"\./full-send/"' \
  "full-send is available through the shipped Claude plugin"
