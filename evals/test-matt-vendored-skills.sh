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

# Latest Matt vendoring: teach workspace.
run_file_eval "$REPO_ROOT/teach/SKILL.md" "teach SKILL.md exists"
run_file_eval "$REPO_ROOT/teach/MISSION-FORMAT.md" "teach mission format exists"
run_file_eval "$REPO_ROOT/teach/LEARNING-RECORD-FORMAT.md" "teach learning-record format exists"
run_file_eval "$REPO_ROOT/teach/GLOSSARY-FORMAT.md" "teach glossary format exists"
run_file_eval "$REPO_ROOT/teach/RESOURCES-FORMAT.md" "teach resources format exists"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "lessons/.*html|learning-records|NOTES.md" "teach keeps stateful workspace files"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "citations|trusted resources" "teach grounds lessons in trusted resources"
run_content_eval "$REPO_ROOT/teach/SKILL.md" "feedback loop|interactive" "teach requires interactive feedback loops"

# Latest Matt vendoring: improve-codebase-architecture richer report flow.
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "HTML report|architecture-review" "ICA writes HTML architecture report"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "Top recommendation" "ICA report includes top recommendation"
run_content_eval "$REPO_ROOT/improve-codebase-architecture/SKILL.md" "INTERFACE-DESIGN.md" "ICA links interface design reference"
run_file_eval "$REPO_ROOT/improve-codebase-architecture/HTML-REPORT.md" "ICA HTML report reference exists"
run_file_eval "$REPO_ROOT/improve-codebase-architecture/INTERFACE-DESIGN.md" "ICA interface design reference exists"
