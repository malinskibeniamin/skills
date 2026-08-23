# Evals for the beginner-first /eli5 visual explainer.

SKILL="$REPO_ROOT/eli5/SKILL.md"
METADATA="$REPO_ROOT/eli5/agents/openai.yaml"
PLUGIN="$REPO_ROOT/.claude-plugin/plugin.json"

run_file_eval "$SKILL" "eli5 SKILL.md exists"
run_content_eval "$SKILL" "^name: eli5$" "eli5 name matches its directory"
run_content_eval "$SKILL" "^argument-hint:.*topic" \
  "eli5 advertises its topic argument"
run_content_eval "$SKILL" "picture explainer|visual explainer" \
  "eli5 can be discovered from beginner visual requests"
run_content_eval "$SKILL" "knows nothing|no assumed background" \
  "eli5 assumes no prior topic knowledge"
run_content_eval "$SKILL" "module.*trade-?off.*incident|module.*incident.*trade-?off" \
  "eli5 covers module, tradeoff, and incident explainers"
run_content_eval "$SKILL" "evidence|source material" \
  "eli5 grounds explanations before simplifying them"
run_content_eval "$SKILL" "facts?.*inference|inference.*facts?" \
  "eli5 does not disguise inferred causes as incident facts"
run_content_eval "$SKILL" "self-contained.*HTML|HTML.*self-contained" \
  "eli5 produces one self-contained HTML artifact"
run_content_eval "$SKILL" "inline (CSS|SVG)|CSS.*SVG" \
  "eli5 keeps its visual dependencies inside the artifact"
run_content_eval "$SKILL" "big (pictures|visuals)" \
  "eli5 makes visuals carry the explanation"
run_content_eval "$SKILL" "few words" "eli5 keeps the explanation terse"
run_content_eval "$SKILL" "one idea.*(scene|panel)|(scene|panel).*one idea" \
  "eli5 gives each visual one teaching job"
run_content_eval "$SKILL" "recompose.*narrow|narrow.*recompose" \
  "eli5 keeps diagrams legible instead of shrinking them on mobile"
run_content_eval "$SKILL" "jargon.*define|define.*jargon" \
  "eli5 removes or defines necessary jargon"
run_content_eval "$SKILL" "patroniz|childish" \
  "eli5 stays beginner-friendly without talking down"
run_content_eval "$SKILL" "accessible description|text alternative" \
  "eli5 gives visuals an accessible explanation"
run_content_eval "$SKILL" "temporary|TMPDIR|mktemp" \
  "eli5 fallback artifacts do not pollute the repository"
run_content_eval "$SKILL" "isolated browser|browser.*isolated" \
  "eli5 verifies artifacts without taking over a human browser"

if [ -f "$SKILL" ] && ! grep -q '^disable-model-invocation: true$' "$SKILL"; then
  echo "  PASS  eli5 remains available for matching picture-explainer requests"
  PASS=$((PASS + 1))
else
  echo "  FAIL  eli5 remains available for matching picture-explainer requests"
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: eli5 should keep normal model invocation"
fi

run_file_eval "$METADATA" "eli5 canonical Codex metadata exists"
run_content_eval "$METADATA" 'default_prompt:.*[$]eli5' \
  "eli5 metadata offers a ready-to-run prompt"
run_content_eval "$PLUGIN" '"\./eli5/"' "Claude plugin registers eli5"
run_content_eval "$REPO_ROOT/scripts/generate-skill-catalog.sh" '"eli5":' \
  "Codex metadata defines eli5"
run_file_eval "$REPO_ROOT/codex-skills/eli5/SKILL.md" \
  "generated Codex eli5 proxy exists"
run_file_eval "$REPO_ROOT/codex-skills/eli5/agents/openai.yaml" \
  "generated Codex eli5 metadata exists"
run_content_eval "$REPO_ROOT/codex-skills/eli5/agents/openai.yaml" \
  'display_name: "ELI5"' "Codex preserves the ELI5 initialism"
run_content_eval "$REPO_ROOT/ask-ben/SKILL.md" "/eli5" \
  "generated catalog lists eli5"
run_content_eval "$REPO_ROOT/docs-site/generate-skill-diagrams.ts" 'eli5:' \
  "eli5 has a semantic docs diagram"
run_file_eval "$REPO_ROOT/docs-site/public/diagrams/skills/eli5.excalidraw" \
  "eli5 editable docs diagram exists"
run_file_eval "$REPO_ROOT/docs-site/public/diagrams/skills/eli5.svg" \
  "eli5 rendered docs diagram exists"
