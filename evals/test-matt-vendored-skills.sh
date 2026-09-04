# Evals for mattpocock/skills vendoring completeness.

VENDORED=(
  ask-ben
  codebase-design
  diagnosing-bugs
  domain-modeling
  grilling
  handoff
  improve-codebase-architecture
  prototype
  research
  resolving-merge-conflicts
  review
  tdd
  teach
  to-questionnaire
  to-spec
  to-tickets
  triage
  wayfinder
  wait-what
  wizard
  writing-beats
  writing-for-agents
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
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "Wide refactors.*exception" "to-tickets treats wide refactors as a vertical-slice exception"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "expand.*migrate.*contract" "to-tickets sequences wide refactors with expand-contract"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "migrate.*blocked by.*expand" "to-tickets blocks every migration batch on expand"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "contract.*blocked by every.*migrate" "to-tickets blocks contract on every migration batch"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "integration branch.*integrate-and-verify|integrate-and-verify.*integration branch" "to-tickets handles migration batches that cannot stay green alone"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "\\.scratch/<feature-slug>/tickets/<NN>-<slug>\\.md" "to-tickets publishes one canonical local file per ticket"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "AGENTS\\.md.*CLAUDE\\.md|CLAUDE\\.md.*AGENTS\\.md" "to-tickets resolves tracker docs through agent instructions"
run_content_eval "$REPO_ROOT/to-tickets/SKILL.md" "CLAUDE\\.md.*first|If.*CLAUDE\\.md.*exists.*AGENTS\\.md" "to-tickets defines instruction-file precedence"

if grep -qE 'one `tickets\.md`|docs/agents/issue-tracker\.md' "$REPO_ROOT/to-tickets/SKILL.md"; then
  echo "  FAIL  to-tickets removes combined-file and hardcoded-tracker instructions"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: to-tickets still contains a combined tickets.md or hardcoded tracker instruction"
else
  echo "  PASS  to-tickets removes combined-file and hardcoded-tracker instructions"
  PASS=$((PASS + 1))
fi
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
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "plans, decisions,.*ideas" "grilling applies beyond implementation plans"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "decision tree" "grilling walks decisions rather than design-only branches"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "environment.*filesystem.*tools" "grilling looks up facts across the available environment"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "confirmation only when.*requested" "grilling respects the requested endpoint"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "user.*decisions.*theirs" "grilling leaves decisions to the user"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "whole frontier" "grilling interviews round by round"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "unsettled prerequisite.*rest of the frontier proceeds" "grilling does not block independent frontier questions"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "pre-agreed seams|confirm.*seams" "TDD tests only agreed seams"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "Tautological" "TDD names tautological tests as anti-pattern"
run_content_eval "$REPO_ROOT/tdd/tests.md" "Expected value.*implementation|known literal" "tests.md prevents tautological expected values"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" "smell baseline" "review carries Fowler smell baseline"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" "Mysterious Name" "review baseline includes Mysterious Name"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" "Speculative Generality" "review baseline includes Speculative Generality"
run_content_eval "$REPO_ROOT/review/REFERENCE.md" "standard always wins|repo overrides" "review baseline defers to repo standards"

# Latest harness adaptation: review retains upstream evidence depth without orchestration ceremony.
run_content_eval "$REPO_ROOT/review/SKILL.md" "Customer-facing UI/CLI/report" "review detects user-facing surfaces"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Security/privacy/data loss" "review detects credible high-impact failures"
run_content_eval "$REPO_ROOT/review/SKILL.md" "standards separate from product/spec" "review keeps standards and spec axes separate"
run_content_eval "$REPO_ROOT/review/SKILL.md" "inspect -> verify -> classify -> synthesize" "review defines one evidence loop"
run_content_eval "$REPO_ROOT/review/SKILL.md" "surface-specific scrutiny only when the diff supplies evidence" "review depth is evidence-triggered"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Do not edit, commit, push" "review stays diagnostic"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Deep mode" "review has a deep release-audit mode"
run_content_eval "$REPO_ROOT/review/SKILL.md" "complete applicability ledger" "deep review accounts for every surface"
run_content_eval "$REPO_ROOT/review/SKILL.md" "could still be wrong if tests pass" "review keeps an adversarial question"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Deduplicate by root cause" "review deduplicates findings"
run_content_eval "$REPO_ROOT/review/SKILL.md" "semantic density" "review evaluates change value directly"
run_content_eval "$REPO_ROOT/review/SKILL.md" "No performance finding without measurement" "review rejects unsupported value claims"
run_content_eval "$REPO_ROOT/review/SKILL.md" "No edge-case finding" "review filters hypothetical defects"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "independent audit before reading PR discussion" "deep review preserves fresh eyes before feedback"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "Deep-mode review reference" "deep-audit reference exists"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "Code-judo.*preserves behavior.*deleting" "deep review demands evidence-backed structural ambition"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "Developer experience.*secret sources.*environment variable" "deep review traces developer configuration"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "ports/networking.*required.*scripts" "deep review catches mandatory workflow regressions"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "Feature exposure.*feature flags.*internal-only" "deep review traces feature gates"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "unintended exposure or bypass" "deep review catches feature-gate leaks"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "Intended breakage.*well-scoped.*unintended blast radius" "deep review separates requested breakage from collateral damage"
run_content_eval "$REPO_ROOT/review/DEEP-AUDIT.md" "devex.*feature-exposure" "deep review schema classifies release behavior"
if grep -qE '/visual-review|/resilience-review|/steelman|Hat panel|different-family' "$REPO_ROOT/review/SKILL.md"; then
  echo "  FAIL  review retains orchestration chains"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: review orchestration chains remain"
else
  echo "  PASS  review retains no orchestration chains"
  PASS=$((PASS + 1))
fi

# Latest Matt vendoring: wayfinder.
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "map is an .*index" "wayfinder map is an index"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Refer to maps and tickets by .*name" "wayfinder refers by name"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Claim.*assigning" "wayfinder claims by assignment"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "native blocking" "wayfinder prefers native blocking"
run_content_eval "$REPO_ROOT/wayfinder/SKILL.md" "Resolve at most one ticket per session" "wayfinder resolves one ticket per session"
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
run_content_eval "$REPO_ROOT/research/SKILL.md" "inline by default" "research stays inline without delegation consent"
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

# Matt ICA flow is a standalone, architecture-only skill.
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "HTML report|architecture-review" "ICA writes HTML architecture report"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "Top recommendation" "ICA report includes top recommendation"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "/codebase-design" "ICA links shared codebase-design skill"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "Scope before.*YAGNI" "ICA decides scope before scanning"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "user names a module|take that scope" "ICA honors explicit scope"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "git log --(name-only|stat).*hot spots" "ICA uses path-aware history for recent change hot spots"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "scattered" "ICA widens only when history has no hot spot"
run_file_eval "$REPO_ROOT/improve-codebase-architecture/HTML-REPORT.md" "ICA architecture report reference exists"
run_file_eval "$REPO_ROOT/codebase-design/DESIGN-IT-TWICE.md" "codebase-design interface design reference exists"

# Latest Matt vendoring: writing-for-agents generalizes the reference and keeps the negation cure.
run_content_eval "$REPO_ROOT/writing-for-agents/SKILL.md" "AGENTS\\.md.*CLAUDE\\.md" "writing-for-agents covers all agent-consumed documents"
run_content_eval "$REPO_ROOT/writing-for-agents/SKILL.md" "Negation" "writing-for-agents names negation failure mode"
run_content_eval "$REPO_ROOT/writing-for-agents/SKILL.md" "Prompt the \*\*positive\*\*|prompt the \*\*positive\*\*" "writing-for-agents cures negation with positive prompting"

# Matt 2026-07 prototype lifecycle and logic-demo updates.
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "\.context/prototypes" "prototype retains a local artifact"
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "primary source" "prototype retains runnable evidence"
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "endpoint.*authorizes commits|authorizes commits.*endpoint" \
  "prototype branch retention respects the requested endpoint"
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "\.context/prototypes" \
  "prototype has a retained no-commit destination"
run_content_eval "$REPO_ROOT/prototype/LOGIC.md" "single, self-contained HTML file|single self-contained HTML file" "logic prototype is a shareable HTML demo"
run_content_eval "$REPO_ROOT/prototype/LOGIC.md" "Guided walkthroughs" "logic prototype includes guided scenarios"
run_content_eval "$REPO_ROOT/prototype/UI.md" "primary source" "UI variants are retained as primary-source evidence"

run_content_eval "$REPO_ROOT/prototype/SKILL.md" "question, evidence, and verdict" \
  "prototype preserves its durable verdict"

# Matt 2026-07 questionnaire skill.
run_content_eval "$REPO_ROOT/to-questionnaire/SKILL.md" "Grill the send, not the subject" "questionnaire asks only what the sender can answer"
run_content_eval "$REPO_ROOT/to-questionnaire/SKILL.md" "discovery questionnaire" "questionnaire frames async discovery"
run_content_eval "$REPO_ROOT/to-questionnaire/SKILL.md" "most-important-first" "questionnaire prioritizes a partial async response"
run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" '"./to-questionnaire/"' "plugin registers to-questionnaire"

# Matt v1.2 completion: concise repair and model-invoked human-only setup.
run_content_eval "$REPO_ROOT/wait-what/SKILL.md" "ASD-STE100 Simplified Technical English" \
  "wait-what re-pitches with simplified English"
run_content_eval "$REPO_ROOT/wait-what/SKILL.md" "CONTEXT\.md" \
  "wait-what uses the project vocabulary"
run_content_eval "$REPO_ROOT/wizard/SKILL.md" "human-only" \
  "wizard names its human-only boundary"
if grep -q '^disable-model-invocation:' "$REPO_ROOT/wizard/SKILL.md"; then
  echo "  FAIL  wizard remains explicit-use only"
  FAIL=$((FAIL + 1)); ERRORS="$ERRORS\n  FAIL: wizard is not model-invoked"
else
  echo "  PASS  wizard is model-invoked"
  PASS=$((PASS + 1))
fi

if grep -qE "Work the frontier.*(/tdd|/implement)" "$REPO_ROOT/to-tickets/SKILL.md"; then
  echo "  FAIL  to-tickets still owns ticket implementation"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: to-tickets still owns ticket implementation"
else
  echo "  PASS  to-tickets ends after ticket publication"
  PASS=$((PASS + 1))
fi

# Matt 2026-08 reconciliation: upstream a621cc4f..5b15a47f, adapted to this harness.
run_file_eval "$REPO_ROOT/ask-ben/PHASE-BOUNDARIES.md" "ask-ben phase-boundary reference exists"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "PHASE-BOUNDARIES\.md" \
  "ask-ben discloses phase-boundary guidance"
run_content_eval "$REPO_ROOT/ask-ben/PHASE-BOUNDARIES.md" "[Ee]xplicit.*delegation|[Dd]elegation.*explicit" \
  "phase boundaries preserve delegation consent"
run_content_eval "$REPO_ROOT/diagnosing-bugs/SKILL.md" "^## Redact$" \
  "diagnosing-bugs redacts secrets before sharing evidence"
run_content_eval "$REPO_ROOT/diagnosing-bugs/SKILL.md" "<REDACTED>" \
  "diagnosing-bugs names the redaction placeholder"
run_content_eval "$REPO_ROOT/diagnosing-bugs/scripts/hitl-loop.template.sh" "capture.*terminal|terminal.*capture" \
  "HITL capture warns that values are echoed"
run_content_eval "$REPO_ROOT/domain-modeling/SKILL.md" \
  "^description:.*codebase terminology.*CONTEXT\.md.*ADR" \
  "domain-modeling triggers on terminology and context artifacts"
run_content_eval "$REPO_ROOT/grilling/SKILL.md" "\*\*Q2 --" \
  "grilling demonstrates separated multi-question rounds"
run_content_eval "$REPO_ROOT/wait-what/SKILL.md" "CONTEXT-MAP\.md" \
  "wait-what resolves the right bounded context"
run_content_eval "$REPO_ROOT/wizard/SKILL.md" "stage-by-stage progress" \
  "wizard reports stage progress without invented duration"

if grep -qE 'TOTAL_MINUTES|_MINUTES_ELAPSED|time-remaining|min left|about [0-9]+ minutes' \
  "$REPO_ROOT/wizard/SKILL.md" "$REPO_ROOT/wizard/template.sh"; then
  echo "  FAIL  wizard still invents duration estimates"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: wizard still invents duration estimates"
else
  echo "  PASS  wizard uses stage counts instead of duration estimates"
  PASS=$((PASS + 1))
fi

run_content_eval "$REPO_ROOT/codebase-design/DESIGN-IT-TWICE.md" \
  "[Ee]xplicit.*delegation|delegation.*[Ee]xplicit" \
  "design-it-twice preserves explicit delegation consent"
run_content_eval "$REPO_ROOT/codebase-design/DESIGN-IT-TWICE.md" \
  "[Ii]nline.*without.*delegation|[Ww]ithout.*delegation.*inline" \
  "design-it-twice has an inline fallback"

# Reviewed but intentionally omitted, superseded, or incompatible upstream surfaces.
for excluded in batch-grill-me implement-spec setup-ts-deep-modules spawn writing-great-skills; do
  if [ -e "$REPO_ROOT/$excluded/SKILL.md" ] || grep -q "\"./$excluded/\"" "$REPO_ROOT/.claude-plugin/plugin.json"; then
    echo "  FAIL  incompatible or superseded Matt skill stays unregistered: $excluded"
    FAIL=$((FAIL + 1))
    ERRORS="$ERRORS\n  FAIL: excluded Matt skill registered: $excluded"
  else
    echo "  PASS  incompatible or superseded Matt skill stays unregistered: $excluded"
    PASS=$((PASS + 1))
  fi
done

if [ -e "$REPO_ROOT/frontend-starter-kit/references/deep-modules" ]; then
  echo "  FAIL  experimental setup-ts-deep-modules adaptation is absent"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: experimental setup-ts-deep-modules adaptation remains"
else
  echo "  PASS  experimental setup-ts-deep-modules adaptation is absent"
  PASS=$((PASS + 1))
fi
