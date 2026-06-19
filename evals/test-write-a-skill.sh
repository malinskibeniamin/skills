# Evals for /writing-great-skills skill-quality discipline.

SKILL_DIR="$REPO_ROOT/writing-great-skills"
SKILL="$SKILL_DIR/SKILL.md"

run_file_eval "$SKILL" "writing-great-skills SKILL.md exists"
run_file_eval "$SKILL_DIR/GLOSSARY.md" "writing-great-skills glossary exists"
run_content_eval "$SKILL" "^name: writing-great-skills" "writing-great-skills has correct name"
run_content_eval "$SKILL" "^disable-model-invocation: true$" "writing-great-skills is user-invoked"
run_content_eval "$SKILL" "Predictability" "writing-great-skills centers predictability"
run_content_eval "$SKILL" "Hunt no-ops|No-op" "writing-great-skills hunts no-ops"
run_content_eval "$SKILL" "progressive disclosure" "writing-great-skills keeps progressive disclosure"
run_content_eval "$SKILL" "Token budget|description" "writing-great-skills controls description cost"
run_content_eval "$SKILL_DIR/GLOSSARY.md" "Skill|Trigger|No-op" "writing-great-skills glossary defines core terms"
