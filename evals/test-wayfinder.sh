# Evals for /wayfinder skill and tracker operations.

WAYFINDER="$REPO_ROOT/wayfinder/SKILL.md"
GITHUB_TRACKER="$REPO_ROOT/work-automation-kit/templates/issue-tracker-github.md"
GITLAB_TRACKER="$REPO_ROOT/work-automation-kit/templates/issue-tracker-gitlab.md"
LOCAL_TRACKER="$REPO_ROOT/work-automation-kit/templates/issue-tracker-local.md"
SETUP_SKILL="$REPO_ROOT/work-automation-kit/SKILL.md"
ASK_BEN="$REPO_ROOT/ask-ben/SKILL.md"

run_file_eval "$WAYFINDER" "wayfinder SKILL.md exists"
run_content_eval "$WAYFINDER" '^name: wayfinder$' "wayfinder frontmatter name matches directory"
run_content_eval "$WAYFINDER" "map is an .*index" "wayfinder keeps map as an index"
run_content_eval "$WAYFINDER" "Refer to maps and tickets by .*name" "wayfinder uses human-readable names"
run_content_eval "$WAYFINDER" "one 100K-token agent session" "wayfinder sizes tickets to one agent session"
run_content_eval "$WAYFINDER" "Claim.*first write" "wayfinder claims before any work"
run_content_eval "$WAYFINDER" "open, unblocked, unclaimed" "wayfinder frontier is open unblocked unclaimed"
run_content_eval "$WAYFINDER" "do not resolve another ticket" "wayfinder charting does not overrun one ticket"
run_content_eval "$WAYFINDER" "answer is not part of the body|answer isn't part of the body" "wayfinder keeps answers out of ticket body"
run_content_eval "$WAYFINDER" "Assets.*linked.*not pasted|assets.*linked.*not pasted" "wayfinder links assets instead of pasting"
run_content_eval "$WAYFINDER" "Not yet specified excludes.*decided.*ticket.*out of scope" "wayfinder keeps fog distinct from decisions, tickets, and scope boundaries"
run_content_eval "$WAYFINDER" "Recheck your claims first" "wayfinder rechecks claims before handoff frontier"
run_content_eval "$WAYFINDER" "## Destination" "wayfinder map includes destination"
run_content_eval "$WAYFINDER" "Plan, don't do" "wayfinder defaults to planning"
run_content_eval "$WAYFINDER" "Notes.*planning.*not.*authorize implementation|Notes.*do not authorize implementation" "wayfinder Notes cannot authorize implementation"
if grep -qE "override.*Notes|Notes.*override" "$WAYFINDER"; then
  echo "  FAIL  wayfinder still lets Notes override planning-only behavior"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: wayfinder Notes still carry an execution override"
else
  echo "  PASS  wayfinder has no Notes execution override"
  PASS=$((PASS + 1))
fi
run_content_eval "$WAYFINDER" "decision ticket" "wayfinder names its planning unit a decision ticket"
run_content_eval "$WAYFINDER" "primary context" "wayfinder researches inline by default"
run_content_eval "$WAYFINDER" 'explicit.*delegation|invoked `/swarm`' "wayfinder gates parallel research on consent"
run_content_eval "$WAYFINDER" "artifact location" "wayfinder follows the research artifact location"
run_content_eval "$WAYFINDER" "does not invent a root" "wayfinder does not invent research roots or branches"
run_content_eval "$WAYFINDER" "/to-spec.*buildable plan" "wayfinder collapses a clear map through to-spec"
run_content_eval "$ASK_BEN" "huge.*foggy.*/wayfinder.*/to-spec" "ask-ben reserves wayfinder for huge foggy work and hands off to to-spec"
run_content_eval "$WAYFINDER" "Not yet specified" "wayfinder names unspecifiable fog"
run_content_eval "$WAYFINDER" "Out of scope" "wayfinder tracks scoped-out work"
run_content_eval "$WAYFINDER" "If this surfaces no fog" "wayfinder exits when no map needed"
run_content_eval "$WAYFINDER" "HITL.*AFK|AFK.*HITL" "wayfinder marks ticket collaboration mode"
run_content_eval "$WAYFINDER" "AGENTS\\.md.*CLAUDE\\.md|CLAUDE\\.md.*AGENTS\\.md" "wayfinder resolves tracker docs through agent instructions"
run_content_eval "$WAYFINDER" "CLAUDE\\.md.*first|If.*CLAUDE\\.md.*exists.*AGENTS\\.md" "wayfinder defines instruction-file precedence"
run_content_eval "$WAYFINDER" "Issue tracker.*pointer|issue tracker.*pointer" "wayfinder follows the configured tracker pointer"
run_content_eval "$WAYFINDER" "local-markdown fallback" "wayfinder retains a local tracker fallback"
run_content_eval "$WAYFINDER" "native child/sub-issue|native.*child.*sub-issue" "wayfinder attaches every ticket through native hierarchy"
run_content_eval "$WAYFINDER" "verify every ticket appears|verify.*ticket.*child" "wayfinder verifies child attachment"
run_content_eval "$WAYFINDER" "Grilling.*Always invoke.*/grilling.*/domain-modeling" "wayfinder grilling tickets always invoke both skills"

if grep -q 'docs/agents/issue-tracker\.md' "$WAYFINDER"; then
  echo "  FAIL  wayfinder does not hardcode the tracker document path"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: wayfinder still hardcodes docs/agents/issue-tracker.md"
else
  echo "  PASS  wayfinder does not hardcode the tracker document path"
  PASS=$((PASS + 1))
fi

run_content_eval "$GITHUB_TRACKER" "issue_dependencies_summary\.blocked_by" "GitHub wayfinding frontier uses dependency summary"
run_content_eval "$GITHUB_TRACKER" "database id.*not.*#number.*node_id|not.*#number.*node_id" "GitHub blocking uses database id not display ids"
run_content_eval "$GITHUB_TRACKER" "--add-assignee @me" "GitHub wayfinding claims by assignment"
run_content_eval "$GITHUB_TRACKER" "verify every.*ticket.*child|verify.*child.*count" "GitHub wayfinding verifies native sub-issues"
run_content_eval "$GITLAB_TRACKER" "glab api projects/:id/issues/:iid/links" "GitLab wayfinding checks native blocker links"
run_content_eval "$GITLAB_TRACKER" "Premium/Ultimate|free tier" "GitLab wayfinding documents blocking fallback tier"
run_content_eval "$GITLAB_TRACKER" "--assignee @me" "GitLab wayfinding claims by assignment"
run_content_eval "$GITLAB_TRACKER" "native child|native parent" "GitLab wayfinding prefers native hierarchy"
run_content_eval "$LOCAL_TRACKER" "Status: claimed" "local wayfinding supports claimed state"
run_content_eval "$LOCAL_TRACKER" "Status: resolved" "local wayfinding supports resolved state"
run_content_eval "$LOCAL_TRACKER" "Blocked by: NN, NN" "local wayfinding supports blocking convention"
run_content_eval "$SETUP_SKILL" "Wayfinding operations" "work-automation-kit tells agents to configure wayfinding operations"
