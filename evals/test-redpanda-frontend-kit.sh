# Evals for the redpanda profile reference (folded from redpanda-frontend-kit in 4.27.0).

RP="$REPO_ROOT/frontend-starter-kit/references/redpanda/README.md"
run_file_eval "$RP" "redpanda reference exists"
run_content_eval "$RP" "REDPANDA_KIT" "redpanda reference gates on REDPANDA_KIT env"
run_content_eval "$RP" "registry" "redpanda reference covers registry workflow"
run_content_eval "$REPO_ROOT/frontend-starter-kit/SKILL.md" "redpanda" "starter kit exposes redpanda profile"
