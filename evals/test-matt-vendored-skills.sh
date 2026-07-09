# Evals for mattpocock/skills vendoring completeness.

VENDORED=(
  ask-ben
  codebase-design
  diagnosing-bugs
  domain-modeling
  grilling
  grilling
  prototype
  resolving-merge-conflicts
  review
  wayfinder
  to-spec
  to-tickets
  wizard
  writing-beats
  writing-great-skills
  writing-fragments
  writing-shape
)

for skill in "${VENDORED[@]}"; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "vendored Matt skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "vendored Matt skill has matching name: $skill"
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\./$skill/" "Claude plugin registers vendored Matt skill: $skill"
done

run_content_eval "$REPO_ROOT/prototype/SKILL.md" "prototype|throwaway|test" "prototype skill keeps prototype intent"
run_content_eval "$REPO_ROOT/to-spec/SKILL.md" "spec.*PRD|PRD.*spec" "to-spec skill keeps spec/PRD bridge"
run_content_eval "$REPO_ROOT/to-spec/SKILL.md" "/to-tickets" "to-spec hands approved specs to to-tickets"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "ticket|blocking edges" "to-tickets skill keeps ticket intent"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "native sub-issue" "to-tickets prefers native sub-issues when available"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "/prototype.*context pointer|context pointer.*/prototype" "to-tickets points to prototype code instead of inlining"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "CONTEXT\.md|ADR" "grilling keeps docs sync intent"

for retired_skill in to-prd to-issues setup-matt-pocock-skills; do
  if [ -e "$REPO_ROOT/$retired_skill/SKILL.md" ]; then
    echo "  FAIL  retired Matt planning skill removed: $retired_skill"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: retired Matt planning skill still exists: $retired_skill"
  else
    echo "  PASS  retired Matt planning skill removed: $retired_skill"
    PASS=$((PASS + 1))
  fi

  if grep -q "\"./$retired_skill/\"" "$REPO_ROOT/.claude-plugin/plugin.json"; then
    echo "  FAIL  retired Matt planning skill absent from Claude plugin: $retired_skill"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: retired Matt planning skill still registered: $retired_skill"
  else
    echo "  PASS  retired Matt planning skill absent from Claude plugin: $retired_skill"
    PASS=$((PASS + 1))
  fi
done

if grep -RInE '/to-prd|/to-issues|to-prd|to-issues' \
  "$REPO_ROOT" \
  --exclude-dir=.git \
  --exclude='CHANGELOG.md' \
  --exclude='*.json' \
  --exclude='test-matt-vendored-skills.sh' \
  --exclude='test-matt-wip-skills.sh' >/dev/null; then
  echo "  FAIL  live docs and skills use to-spec/to-tickets naming"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: live docs still reference to-prd/to-issues"
else
  echo "  PASS  live docs and skills use to-spec/to-tickets naming"
  PASS=$((PASS + 1))
fi

run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/to-spec.*to-tickets|/to-tickets.*to-spec" "ask-ben routes specs to tickets"
run_content_eval "$REPO_ROOT/improve/SKILL.md" "/to-tickets" "improve routes issue publishing through to-tickets"
run_content_eval "$REPO_ROOT/snyk-ux-security/SKILL.md" "/to-tickets" "snyk skill routes security debt through to-tickets"

run_content_eval "$REPO_ROOT/wizard/SKILL.md" "interactive bash wizard|template\\.sh" "wizard builds interactive bash wizards"
run_file_eval "$REPO_ROOT/wizard/template.sh" "wizard template exists"


# Latest Matt vendoring: public research skill and upstream review/TDD/grilling deltas.
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "Do not enact the plan until I confirm" "grilling waits for shared-understanding confirmation"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "If a \*fact\* can be found" "grilling looks up facts instead of asking"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "decisions.*are mine" "grilling leaves decisions to the user"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "pre-agreed seams|confirm.*seams" "TDD tests only agreed seams"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "Tautological" "TDD names tautological tests as anti-pattern"
run_content_eval "$REPO_ROOT/tdd/tests.md" "Expected value.*implementation|known literal" "tests.md prevents tautological expected values"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" "smell baseline" "review carries Fowler smell baseline"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" "Mysterious Name" "review baseline includes Mysterious Name"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" "Speculative Generality" "review baseline includes Speculative Generality"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" "repo standard always wins|repo overrides" "review baseline defers to repo standards"

# Latest Matt vendoring: review orchestrates local review suite.
run_content_eval "$REPO_ROOT/review/SKILL.md" "/visual-review" "review invokes visual-review for user-facing surfaces"
run_content_eval "$REPO_ROOT/review/SKILL.md" "/resilience-review" "review invokes resilience-review for unhappy paths"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Standards.*Spec" "review keeps standards and spec axes"
# review: 8-hat parallel panel (default for PR reviews) + quick/deep modes
run_content_eval "$REPO_ROOT/review/SKILL.md" "Core pass" "review defines the always-on core pass"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Hat panel" "review defaults to the 8-hat panel for PR reviews"
run_content_eval "$REPO_ROOT/review/SKILL.md" "GPT-5\.[56]: independent" "review offers a cross-model independent hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "No silent skips" "review hats skip only with diff evidence"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Deep mode" "review has a deep release-audit mode"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Never invoke /review recursively" "review forbids recursive invocation"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Max 3 findings" "adversarial question stays bounded"
run_content_eval "$REPO_ROOT/review/SKILL.md" "dedupe by root cause" "review dedupes across lanes by root cause"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "Deep-mode review reference" "deep-audit reference exists"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Value gate" "review includes value gate"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Major improvement" "review quantifies major improvement"
run_content_eval "$REPO_ROOT/review/SKILL.md" "value score HIGH" "review scores PR value"
run_content_eval "$REPO_ROOT/review/SKILL.md" "/steelman" "review uses steelman when value is unclear"
run_content_eval "$REPO_ROOT/review/SKILL.md" "low-value" "review filters low-value PRs"

# Latest Matt vendoring: wayfinder.
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "map is an .*index" "wayfinder map is an index"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Refer to maps and tickets by .*name" "wayfinder refers by name"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Claim.*assigning" "wayfinder claims by assignment"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "native blocking" "wayfinder prefers native blocking"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Never resolve more than one ticket per session" "wayfinder resolves one ticket per session"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "## Destination" "wayfinder names the destination"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Plan, don't do" "wayfinder is planning-first"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Not yet specified" "wayfinder separates not-yet-specified fog"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Out of scope" "wayfinder tracks out-of-scope work separately"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "If this surfaces no fog" "wayfinder exits early when no map is needed"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "HITL.*AFK|AFK.*HITL" "wayfinder separates HITL and AFK tickets"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-github.md" "Wayfinding operations" "GitHub tracker template includes wayfinding operations"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-gitlab.md" "Wayfinding operations" "GitLab tracker template includes wayfinding operations"
run_content_eval "$REPO_ROOT/work-automation-kit/templates/issue-tracker-local.md" "Wayfinding operations" "local tracker template includes wayfinding operations"

# Matt v1.1.0 sync: research skill (restored on owner request).
run_file_eval "$REPO_ROOT/research/SKILL.md" "research SKILL.md exists"
run_content_eval "$REPO_ROOT/research/SKILL.md" "background agent" "research delegates to a background agent"
run_content_eval "$REPO_ROOT/research/SKILL.md" "primary sources" "research targets primary sources"
run_content_eval "$REPO_ROOT/research/SKILL.md" "citing each claim" "research cites every claim"
run_content_eval "$REPO_ROOT/research/SKILL.md" "read-the-damn-docs" "research routes inline lookups elsewhere"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"./research/"' "plugin.json registers research"

# Matt v1.1.0 sync: triage treats external PRs as issues with attached code.
run_content_eval "$REPO_ROOT/triage/SKILL.md" "PR is an issue with attached code" "triage covers external PRs as issues"
run_content_eval "$REPO_ROOT/triage/SKILL.md" "\[PR\].*\[issue\]" "triage tags discovery lines PR vs issue"
run_content_eval "$REPO_ROOT/triage/SKILL.md" "redundancy" "triage runs redundancy check against codebase"
run_content_eval "$REPO_ROOT/triage/SKILL.md" "Verify the claim" "triage verifies claims (bug repro / PR diff)"
run_content_eval "$REPO_ROOT/triage/SKILL.md" "already implemented" "triage has already-implemented wontfix branch"

# Latest Matt vendoring: teach workspace (restored on owner request, PR #46).
run_file_eval "$REPO_ROOT/teach/SKILL.md" "teach SKILL.md exists"
run_file_eval "$REPO_ROOT/teach/MISSION-FORMAT.md" "teach mission format exists"
run_file_eval "$REPO_ROOT/teach/LEARNING-RECORD-FORMAT.md" "teach learning-record format exists"
run_file_eval "$REPO_ROOT/teach/GLOSSARY-FORMAT.md" "teach glossary format exists"
run_file_eval "$REPO_ROOT/teach/RESOURCES-FORMAT.md" "teach resources format exists"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "disable-model-invocation: true" "teach is slash-only (zero description tax)"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "lessons/.*html|learning-records|NOTES.md" "teach keeps stateful workspace files"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "citations|trusted resources" "teach grounds lessons in trusted resources"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "feedback loop|interactive" "teach requires interactive feedback loops"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "storage strength.*retrieval.*spacing.*interleaving" "teach optimizes for durable retention"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "same number of words.*formatting" "teach prevents quiz answer tells"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "reference docs.*HTML anchors" "teach links lessons and references"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "primary source" "teach recommends one primary source per lesson"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "mission changes.*MISSION.md.*learning record" "teach records mission shifts"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "./assets/|Assets" "teach reuses assets before inlining"

# Latest Matt vendoring: improve-codebase-architecture richer report flow.
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "HTML report|architecture-review" "ICA writes HTML architecture report"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "Top recommendation" "ICA report includes top recommendation"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "/codebase-design" "ICA links shared codebase-design skill"
run_file_eval "$REPO_ROOT/improve-codebase-architecture/HTML-REPORT.md" "ICA HTML report reference exists"
run_file_eval "$REPO_ROOT/codebase-design/DESIGN-IT-TWICE.md" "codebase-design interface design reference exists"

# Latest Matt vendoring: writing-great-skills negation failure mode.
run_content_eval "$REPO_ROOT/writing-great-skills/SKILL.md" "Negation" "writing-great-skills names negation failure mode"
run_content_eval "$REPO_ROOT/writing-great-skills/GLOSSARY.md" "### Negation" "writing-great-skills glossary defines negation"
run_content_eval "$REPO_ROOT/writing-great-skills/GLOSSARY.md" "prompt the \*\*positive\*\*" "writing-great-skills cures negation with positive prompt"
