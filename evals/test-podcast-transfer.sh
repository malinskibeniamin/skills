# Public skill instructions, not proof of model obedience or autonomous execution.
# Test only the transferred contracts and their discoverable shared references.

run_content_eval "$REPO_ROOT/handoff/SKILL.md" 'requested endpoint|Requested endpoint' \
  "handoff carries the requested endpoint"
run_content_eval "$REPO_ROOT/handoff/SKILL.md" 'progress-evidence.md' \
  "handoff routes continuation freshness to shared evidence"
run_content_eval "$REPO_ROOT/prime/REFERENCE.md" 'requested endpoint|Requested endpoint' \
  "prime restores the requested endpoint"
run_content_eval "$REPO_ROOT/shared/progress-evidence.md" 're-read|Re-read' \
  "continuation refreshes externally observed gates"
run_content_eval "$REPO_ROOT/shared/progress-evidence.md" 'identity.*permission|permission.*identity' \
  "continuation retains identity and permission boundaries"
run_content_eval "$REPO_ROOT/diagnosing-bugs/SKILL.md" 'verification-replay.md' \
  "diagnosis routes captured state to the existing replay contract"
run_content_eval "$REPO_ROOT/diagnosing-bugs/SKILL.md" 'before minim' \
  "diagnosis preserves the original state before minimization"
run_content_eval "$REPO_ROOT/ux-performance/SKILL.md" 'animation.*branding|branding.*animation' \
  "performance preserves intended visual features"
run_content_eval "$REPO_ROOT/ux-performance/SKILL.md" 'verification-replay.md' \
  "performance defines fidelity through the shared replay contract"
run_content_eval "$REPO_ROOT/revamp/SKILL.md" 'held-out' \
  "ports separate held-out compatibility from known corpus parity"
run_content_eval "$REPO_ROOT/resolve-pr-feedback/SKILL.md" 'Pending owner decision.*Block|pending owner decision.*block' \
  "feedback keeps pending owner decisions visibly blocked"
run_content_eval "$REPO_ROOT/resolve-pr-feedback/SKILL.md" 'fixed.*rejected.*blocked' \
  "feedback gives every finding a reasoned disposition"
run_content_eval "$REPO_ROOT/resolve-pr-feedback/REFERENCE.md" 'pending.*not.*complete|Pending.*not.*complete' \
  "feedback summaries cannot claim completion with pending decisions"
