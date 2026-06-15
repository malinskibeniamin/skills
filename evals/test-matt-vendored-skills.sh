# Evals for mattpocock/skills vendoring completeness.

VENDORED=(
  caveman
  edit-article
  git-guardrails-claude-code
  grill-with-docs
  migrate-to-shoehorn
  obsidian-vault
  prototype
  review
  scaffold-exercises
  setup-matt-pocock-skills
  setup-pre-commit
  teach
  to-issues
  to-prd
  writing-beats
  writing-fragments
  writing-shape
)

for skill in "${VENDORED[@]}"; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "vendored Matt skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "vendored Matt skill has matching name: $skill"
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\./$skill/" "Claude plugin registers vendored Matt skill: $skill"
done

run_content_eval "$REPO_ROOT/caveman/SKILL.md" "Ultra-compressed|token usage|terse" "caveman skill keeps compression purpose"
run_content_eval "$REPO_ROOT/prototype/SKILL.md" "prototype|throwaway|test" "prototype skill keeps prototype intent"
run_content_eval "$REPO_ROOT/to-prd/SKILL.md" "PRD|requirements" "to-prd skill keeps PRD intent"
run_content_eval "$REPO_ROOT/to-issues/SKILL.md" "issue|GitHub" "to-issues skill keeps issue intent"
run_content_eval "$REPO_ROOT/grill-with-docs/SKILL.md" "CONTEXT\.md|ADR" "grill-with-docs keeps docs sync intent"


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

# Latest Matt vendoring: improve-codebase-architecture richer report flow.
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "HTML report|architecture-review" "ICA writes HTML architecture report"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "Top recommendation" "ICA report includes top recommendation"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "INTERFACE-DESIGN.md" "ICA links interface design reference"
run_file_eval "$REPO_ROOT/improve-codebase-architecture/HTML-REPORT.md" "ICA HTML report reference exists"
run_file_eval "$REPO_ROOT/improve-codebase-architecture/INTERFACE-DESIGN.md" "ICA interface design reference exists"
