# Evals for the positive-steering mechanisms (owner: "not just done -- clean").

# 1. Codex steering payload travels with delegations.
run_content_eval "$REPO_ROOT/codex/SKILL.md" "Steering payload" "codex contract requires steering payload"
run_content_eval "$REPO_ROOT/codex/SKILL.md" "exemplars/" "codex prompts inline the matching exemplar"

# 2. Exemplars exist and carry the conventions they claim.
for f in README.md component.tsx use-resource.ts route.tsx component.test.tsx; do
  run_file_eval "$REPO_ROOT/exemplars/$f" "exemplar exists: $f"
done
run_content_eval "$REPO_ROOT/exemplars/component.tsx" "@/components/ui/button" "component exemplar is registry-first"
run_content_eval "$REPO_ROOT/exemplars/component.tsx" "ConnectError.from" "component exemplar surfaces errors canonically"
run_content_eval "$REPO_ROOT/exemplars/use-resource.ts" "STALE_TIME" "hook exemplar names staleTime constant"
run_content_eval "$REPO_ROOT/exemplars/use-resource.ts" "function sync" "hook exemplar names its effect"
run_content_eval "$REPO_ROOT/exemplars/route.tsx" "validateSearch" "route exemplar validates search params"
run_content_eval "$REPO_ROOT/exemplars/route.tsx" "errorComponent" "route exemplar has error boundary"
run_content_eval "$REPO_ROOT/exemplars/component.test.tsx" "userEvent.setup" "test exemplar uses userEvent"
run_content_eval "$REPO_ROOT/exemplars/component.test.tsx" "getByRole" "test exemplar queries by role"
run_content_eval "$REPO_ROOT/exemplars/form.tsx" "CREATE_RESOURCE_DEFAULT_VALUES" "form exemplar has deterministic defaults"
run_content_eval "$REPO_ROOT/exemplars/form.tsx" "reValidateMode: 'onChange'" "form exemplar selects post-submit revalidation"
run_content_eval "$REPO_ROOT/exemplars/form.tsx" "FormErrorSummary form=\\{form\\}" "form exemplar wires the error summary"
run_content_eval "$REPO_ROOT/exemplars/form.tsx" "fieldState.invalid" "form exemplar avoids broad formState subscription"
run_content_eval "$REPO_ROOT/exemplars/form.tsx" "required: 'Name is required'" "form exemplar matches its required indicator"
run_content_eval "$REPO_ROOT/exemplars/form.tsx" "onCreated\\(request.name\\)" "form exemplar uses submitted mutation values"
run_content_eval "$REPO_ROOT/tdd/SKILL.md" "exemplars/" "tdd points at exemplars"
run_content_eval "$REPO_ROOT/CLAUDE.md" "exemplars/" "CLAUDE.md lifecycle points at exemplars"

# 3. Less-is-more is core; deslop is fallback only.
run_content_eval "$REPO_ROOT/CLAUDE.md" "smallest obvious" "lifecycle authors the smallest design directly"
run_content_eval "$REPO_ROOT/deslop/SKILL.md" "Fallback, not lifecycle" "deslop documents fallback status"
run_content_eval "$REPO_ROOT/exemplars/e2e.spec.ts" "test\\.step" "test.step structure remains exemplary"

# 4. React Doctor score ratchet.
run_content_eval "$REPO_ROOT/.claude/hooks/react-doctor-stop.sh" "ratchet baseline" "doctor stop hook has the score ratchet"
run_content_eval "$REPO_ROOT/.claude/hooks/react-doctor-stop.sh" "hook_stop_enforce" "ratchet enforces directly (no aggregator race)"
run_content_eval "$REPO_ROOT/frontend-starter-kit/references/react-doctor/REFERENCE.md" "Score ratchet" "react-doctor reference documents the ratchet"
