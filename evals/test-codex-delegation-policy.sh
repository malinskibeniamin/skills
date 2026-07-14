# Codex delegation policy: native fan-out is explicit, bounded, and honest.

APPENDIX="$REPO_ROOT/.agents/codex-appendix.md"

run_content_eval "$APPENDIX" "native Codex" "appendix scopes the policy to native Codex"
run_content_eval "$APPENDIX" 'explicitly requests.*subagents.*delegation.*parallel.*or invokes `/swarm`' \
  "native Codex spawning requires explicit consent"
run_content_eval "$APPENDIX" "Skill activation alone is not consent" \
  "implicit skill activation cannot authorize fan-out"
run_content_eval "$APPENDIX" "descendants.*separate authorization" \
  "nested delegation needs separate authorization"
run_content_eval "$APPENDIX" 'do not.*recursive.*`codex exec`' \
  "native Codex does not recursively invoke codex"
run_content_eval "$APPENDIX" "run.*axes inline" \
  "required review coverage falls back inline"
run_content_eval "$APPENDIX" "first automated review/fix pass.*one CI.*snapshot" \
  "Codex has a concrete post-PR stop boundary"
run_content_eval "$APPENDIX" '`/plow-ahead`.*not.*delegation consent' \
  "plow-ahead does not silently authorize subagents"
run_content_eval "$APPENDIX" "Codex usage unavailable to the harness" \
  "unknown Codex usage is reported honestly"
run_content_eval "$APPENDIX" "[Nn]ever infer.*session tokens" \
  "subscription usage is not guessed from session tokens"
run_content_eval "$APPENDIX" "[Pp]reserve.*model.*reasoning" \
  "the guardrail preserves the user's xhigh selection"
run_content_eval "$APPENDIX" "[Dd]o not.*enable experimental multi-agent flags" \
  "the guardrail does not enable experimental multi-agent flags"

for file in \
  codex/SKILL.md \
  development-lifecycle/SKILL.md \
  efficient-frontier/SKILL.md \
  go/SKILL.md \
  grilling/SKILL.md \
  resilience-review/SKILL.md \
  review/SKILL.md \
  stay-within-limits/SKILL.md; do
  run_content_eval "$REPO_ROOT/$file" "[Nn]ative Codex|Codex host" \
    "$file has a Codex-host execution rule"
done

run_content_eval "$REPO_ROOT/swarm/SKILL.md" "explicit.*opt-in" \
  "/swarm remains the explicit parallelism path"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "termination" \
  "swarm packets require a termination condition"
run_content_eval "$REPO_ROOT/swarm/SKILL.md" "descendants.*separate authorization" \
  "swarm lanes cannot recursively fan out"

run_content_eval "$REPO_ROOT/codex/SKILL.md" "Claude-hosted" \
  "Claude-led codex delegation remains supported"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "recursive.*codex exec" \
  "native Codex avoids recursive codex execution"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "preserve.*selected model.*reasoning" \
  "codex skill does not lower interactive reasoning"

run_content_eval "$REPO_ROOT/stay-within-limits/SKILL.md" "ccusage.*Claude" \
  "ccusage is described as Claude-only"
run_content_eval "$REPO_ROOT/stay-within-limits/SKILL.md" "usage is unknown" \
  "Codex missing-meter fallback says usage is unknown"
run_content_eval "$REPO_ROOT/stay-within-limits/SKILL.md" "Do not.*guess.*reset" \
  "Codex reset timing is never guessed"

run_content_eval "$REPO_ROOT/grilling/SKILL.md" "Codex.*inline" \
  "Codex grilling keeps every hat inline by default"
run_content_eval "$REPO_ROOT/review/SKILL.md" "Codex.*inline" \
  "Codex review keeps every axis inline by default"
run_content_eval "$REPO_ROOT/resilience-review/SKILL.md" "Codex.*inline" \
  "Codex resilience review keeps every axis inline by default"
run_content_eval "$REPO_ROOT/go/SKILL.md" "Codex.*inline" \
  "Codex go review stays inline by default"

# A hook cannot prevent a spawn after admission; keep the enforcement surface honest.
run_content_eval "$REPO_ROOT/shared/subagent-start.sh" "Cannot block subagent creation" \
  "SubagentStart remains context-only"
