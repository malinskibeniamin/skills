# Evals for mattpocock/skills vendoring completeness.

VENDORED=(
  edit-article
  git-guardrails-claude-code
  ask-ben
  codebase-design
  diagnosing-bugs
  domain-modeling
  grill-with-docs
  grilling
  implement
  migrate-to-shoehorn
  obsidian-vault
  prototype
  resolving-merge-conflicts
  research
  review
  wayfinder
  claude-handoff
  loop-me
  scaffold-exercises
  setup-matt-pocock-skills
  setup-pre-commit
  teach
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
run_content_eval "$REPO_ROOT/grill-with-docs/SKILL.md" "CONTEXT\.md|ADR" "grill-with-docs keeps docs sync intent"

for retired_skill in to-prd to-issues; do
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
run_content_eval "$REPO_ROOT/claude-handoff/SKILL.md" "claude --bg --name" "claude-handoff launches named background agent"
run_content_eval "$REPO_ROOT/loop-me/SKILL.md" "workflows/\\*\\.md|workflow specs" "loop-me writes workflow specs"


# Latest Matt vendoring: public research skill and upstream review/TDD/grilling deltas.
run_content_eval "$REPO_ROOT/research/SKILL.md" "primary sources" "research prioritizes primary sources"
run_content_eval "$REPO_ROOT/research/SKILL.md" "Markdown file" "research writes cited markdown artifact"
run_content_eval "$REPO_ROOT/research/SKILL.md" "where the repo already keeps" "research follows repo note conventions"
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
run_content_eval "$REPO_ROOT/review/SKILL.md" "/thermo-nuclear-code-quality-review" "review escalates to thermo nuclear review when release-blocking depth needed"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Standards.*Spec" "review keeps standards and spec axes"
run_content_eval "$REPO_ROOT/review/SKILL.md" "regular-review-hat" "review launches regular review hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "visual-review-hat" "review launches visual review hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "resilience-review-hat" "review launches resilience review hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "security-privacy-triage-hat" "review launches security privacy triage hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "adversarial-review-hat" "review launches adversarial review hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "test-perf-review-hat" "review launches test and perf review hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "thermo-nuclear-review-hat" "review launches thermo nuclear review hat"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Spawn all review hats" "review fans out all review hats"
run_content_eval "$REPO_ROOT/review/SKILL.md" "/swarm" "review prefers swarm orchestration when available"
run_content_eval "$REPO_ROOT/review/SKILL.md" "If /swarm is unavailable" "review falls back when swarm unavailable"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Subagents: ponytail-review-hat:.*thermo-nuclear-review-hat" "review output reports priority-ordered hat coverage"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Each hat emits" "review requires consistent hat output schema"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Max 3 findings" "adversarial hat stays lightweight"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Dedupe across hats by root cause" "review dedupes across hats"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Do not recursively invoke /review" "review guards against recursive thermo fan-out"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Review priority hierarchy" "review defines priority hierarchy"
run_content_eval "$REPO_ROOT/review/SKILL.md" "1\. Ponytail review" "review prioritizes ponytail first"
run_content_eval "$REPO_ROOT/review/SKILL.md" "2\\. Thermo nuclear review" "review prioritizes thermo nuclear second after ponytail"
run_content_eval "$REPO_ROOT/review/SKILL.md" "3\\. Resilience review" "review prioritizes resilience third"
run_content_eval "$REPO_ROOT/review/SKILL.md" "4\\. Regular review" "review prioritizes regular fourth"
run_content_eval "$REPO_ROOT/review/SKILL.md" "5\\. Adversarial review" "review prioritizes adversarial fifth"
run_content_eval "$REPO_ROOT/review/SKILL.md" "6\\. Visual review" "review prioritizes visual sixth"
run_content_eval "$REPO_ROOT/review/SKILL.md" "7\\. Test/perf review" "review prioritizes test perf seventh"
run_content_eval "$REPO_ROOT/review/SKILL.md" "No silent skips" "review forbids silent skipped hats"
run_content_eval "$REPO_ROOT/review/SKILL.md" "If unsure, run the review" "review runs instead of skipping on uncertainty"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Thermo nuclear is fail-open" "review fail-opens thermo nuclear"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Never skip due to time" "review forbids time-based skip"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Never invoke /review recursively" "regular review avoids recursion"
run_content_eval "$REPO_ROOT/review/SKILL.md" "PR value gate" "review includes PR value gate"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Major improvement" "review quantifies major improvement"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Value score: HIGH\\|MEDIUM\\|LOW\\|NONE" "review scores PR value"
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
run_content_eval "$REPO_ROOT/setup-matt-pocock-skills/issue-tracker-github.md" "Wayfinding operations" "GitHub tracker template includes wayfinding operations"
run_content_eval "$REPO_ROOT/setup-matt-pocock-skills/issue-tracker-gitlab.md" "Wayfinding operations" "GitLab tracker template includes wayfinding operations"
run_content_eval "$REPO_ROOT/setup-matt-pocock-skills/issue-tracker-local.md" "Wayfinding operations" "local tracker template includes wayfinding operations"

# Latest Matt vendoring: teach workspace.
run_file_eval "$REPO_ROOT/teach/SKILL.md" "teach SKILL.md exists"
run_file_eval "$REPO_ROOT/teach/MISSION-FORMAT.md" "teach mission format exists"
run_file_eval "$REPO_ROOT/teach/LEARNING-RECORD-FORMAT.md" "teach learning-record format exists"
run_file_eval "$REPO_ROOT/teach/GLOSSARY-FORMAT.md" "teach glossary format exists"
run_file_eval "$REPO_ROOT/teach/RESOURCES-FORMAT.md" "teach resources format exists"
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
