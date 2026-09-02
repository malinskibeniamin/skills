#!/bin/bash

# One compositional presentation contract for substantial human-facing artifacts.

CONTRACT="$REPO_ROOT/shared/intent-map.md"

run_file_eval "$CONTRACT" "shared intent-map contract exists"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'shared/intent-map\.md' \
  "ambient instructions route relevant outputs through the intent-map contract"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'Substantial plans.*analyses.*reviews.*recaps.*status.*handoffs' \
  "intent-map trigger is output-shaped rather than a manual skill list"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'map objective.*assumptions.*references' \
  "ambient instructions carry the usable map shape without a skill-specific load"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'implementation.*verification' \
  "ambient intent maps connect decisions to implementation evidence"
run_content_eval "$REPO_ROOT/CLAUDE.md" 'trivial.*linear|single-path.*linear' \
  "trivial outputs stay linear"
run_content_eval "$REPO_ROOT/AGENTS.md" 'shared/intent-map\.md' \
  "generated Codex instructions inherit the intent-map contract"

for node in Objective Assumption Decision Reference Implementation Verification Risk; do
  run_content_eval "$CONTRACT" "\*\*$node\*\*" \
    "intent-map contract defines the $node node"
done

run_content_eval "$CONTRACT" 'presentation contract.*not.*artifact|not.*extra artifact' \
  "intent maps change communication without manufacturing artifacts"
run_content_eval "$CONTRACT" 'chain of thought|private reasoning' \
  "intent maps summarize rationale without exposing private reasoning"
run_content_eval "$CONTRACT" 'first read|First read' \
  "intent maps define a concise first read"
for rendering in 'native diagram' Mermaid 'indented bullets'; do
  run_content_eval "$CONTRACT" "$rendering" \
    "intent maps support the $rendering rendering rung"
done
run_content_eval "$CONTRACT" 'at most 9 visible' \
  "intent maps bound first-read graph density"

run_content_eval "$REPO_ROOT/visual-plan/SKILL.md" '\.\./shared/intent-map\.md' \
  "visual plans render the shared intent-map contract"
run_content_eval "$REPO_ROOT/visual-recap/SKILL.md" '\.\./shared/intent-map\.md' \
  "visual recaps render the shared intent-map contract"
run_content_eval "$REPO_ROOT/CONTEXT.md" '\*\*Intent map\*\*' \
  "domain glossary names the shared presentation model"
