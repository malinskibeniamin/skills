# Effect skills are distributed through both plugin surfaces from local copies.

EFFECT_SHA="2309e6f27d9955b434c0e3f394b945c136e89fd2"

for skill in effect-ts effect-v3-to-v4; do
  run_file_eval "$REPO_ROOT/$skill/SKILL.md" "vendored Effect skill exists: $skill"
  run_content_eval "$REPO_ROOT/$skill/SKILL.md" "^name: $skill$" "Effect skill has matching name: $skill"
  run_content_eval "$REPO_ROOT/.claude-plugin/plugin.json" "\\./$skill/" "Claude plugin registers Effect skill: $skill"
  run_content_eval "$REPO_ROOT/codex-skills/$skill/SKILL.md" "\\.\\./\\.\\./$skill/SKILL\\.md" "Codex proxy loads canonical Effect skill: $skill"
  run_file_eval "$REPO_ROOT/codex-skills/$skill/agents/openai.yaml" "Codex interface exists: $skill"
  run_file_eval "$REPO_ROOT/$skill/LICENSE" "standalone Effect skill includes its license: $skill"
  run_content_eval "$REPO_ROOT/$skill/LICENSE" 'Copyright \(c\) 2023 Effectful Technologies Inc' "standalone Effect skill preserves the MIT notice: $skill"
  run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/$skill" "router lists Effect skill: $skill"
done

run_content_eval "$REPO_ROOT/effect-v3-to-v4/SKILL.md" '^disable-model-invocation: true$' "migration remains explicitly invoked"
run_content_eval "$REPO_ROOT/codex-skills/effect-v3-to-v4/agents/openai.yaml" 'allow_implicit_invocation: false' "Codex keeps migration explicitly invoked"
run_file_eval "$REPO_ROOT/effect-v3-to-v4/REFERENCE.md" "migration reference is bundled locally"
run_content_eval "$REPO_ROOT/effect-v3-to-v4/SKILL.md" '\[REFERENCE\.md\]\(REFERENCE\.md\)' "migration loads its bundled reference"
run_content_eval "$REPO_ROOT/shared/EFFECT-SKILLS-CREDITS.md" "$EFFECT_SHA" "Effect provenance pins the upstream revision"
run_content_eval "$REPO_ROOT/shared/EFFECT-SKILLS-CREDITS.md" 'Copyright \(c\) 2023 Effectful Technologies Inc' "Effect distribution preserves the upstream MIT notice"
run_content_eval "$REPO_ROOT/shared/EFFECT-SKILLS-CREDITS.md" 'skills/effect-ts/SKILL\.md' "Effect setup has an upstream refresh source"
run_content_eval "$REPO_ROOT/shared/EFFECT-SKILLS-CREDITS.md" 'skills/effect-v3-to-v4/SKILL\.md' "Effect migration has an upstream refresh source"
run_content_eval "$REPO_ROOT/README.md" 'Effect-TS/skills' "README identifies Effect vendoring"
