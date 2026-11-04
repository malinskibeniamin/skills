#!/bin/bash

# Public prompt-contract checks only: these prove published guidance and routing,
# not agent adherence, review accuracy, throughput, or a measured attention gain.

run_content_eval "$REPO_ROOT/shared/communication.md" '## Admit work by priority' \
  "reader-attention guidance includes work admission"
run_content_eval "$REPO_ROOT/shared/communication.md" 'displaces|displace' \
  "new work accounts for the priority it displaces"
run_content_eval "$REPO_ROOT/shared/communication.md" 'park.*follow-up|follow-up.*park' \
  "adjacent opportunities are parked rather than silently started"
run_content_eval "$REPO_ROOT/shared/communication.md" 'requested stop|working-hours|working hours' \
  "pacing honors user stops instead of filling idle agent capacity"
run_content_eval "$REPO_ROOT/development-lifecycle/SKILL.md" 'communication.md#admit-work-by-priority' \
  "implementation reaches priority guidance before choosing work"

run_content_eval "$REPO_ROOT/shared/repo-navigation.md" '## Leave shared context' \
  "navigation owns durable area context"
run_content_eval "$REPO_ROOT/shared/repo-navigation.md" 'invariants.*helpers|helpers.*invariants' \
  "area context preserves domain invariants and existing helpers"
run_content_eval "$REPO_ROOT/shared/repo-navigation.md" 'checkpoint|implementation-notes' \
  "durable area context stays distinct from transient session state"
run_content_eval "$REPO_ROOT/shared/delivery-workflow.md" 'repo-navigation.md#leave-shared-context' \
  "delivery reaches area-context maintenance"

run_content_eval "$REPO_ROOT/review/OPERATING-MODEL.md" 'minor.unit|currency' \
  "sensitive review checks authoritative money semantics"
run_content_eval "$REPO_ROOT/review/OPERATING-MODEL.md" 'locking|lock behavior' \
  "migration review includes operational locking risk"
run_content_eval "$REPO_ROOT/review/OPERATING-MODEL.md" 'idempotency|duplicate.*payment' \
  "migration and retry review includes repeated external effects"
run_content_eval "$REPO_ROOT/review/OPERATING-MODEL.md" 'forward.fix|forward fix|forward-fix' \
  "learning retains incidents fixed forward, not only reverts"
run_content_eval "$REPO_ROOT/pr/SKILL.md" 'operator digest' \
  "PR summary is the compact operator digest"
run_content_eval "$REPO_ROOT/pr/SKILL.md" 'recap artifacts need an explicit request' \
  "operator digest keeps extra recap artifacts opt-in"

# Cross-skill contracts live at their operational owners, not an article summary.
run_content_eval "$REPO_ROOT/writing-for-agents/SKILL.md" 'SKILL-MECHANICS.md' \
  "skill authoring reaches the shared improvement loop without ambient duplication"
run_content_eval "$REPO_ROOT/writing-for-agents/SKILL-MECHANICS.md" '## Improve the owning workflow' \
  "skill authoring improves execution rather than recording an essay"
run_content_eval "$REPO_ROOT/writing-for-agents/SKILL-MECHANICS.md" 'families|family' \
  "broad improvement requests assess skill families before editing"
run_content_eval "$REPO_ROOT/writing-for-agents/SKILL-MECHANICS.md" 'direct invocation|direct invocations' \
  "shared improvements remain reachable from direct skill use"
run_content_eval "$REPO_ROOT/product/CRAFT.md" 'displace' \
  "product planning accounts for displaced priorities"
run_content_eval "$REPO_ROOT/product/CRAFT.md" 'PRs, lines.*tokens.*activity' \
  "product planning distinguishes output volume from outcomes"
run_content_eval "$REPO_ROOT/shared/POTETO-NATIVE.md" 'review.*repair.*capacity|review/repair capacity' \
  "delegation accounts for operator review and recovery capacity"
run_content_eval "$REPO_ROOT/improve/references/audit-playbook.md" '## Agent workflow bottlenecks' \
  "improvement audits diagnose the bottleneck after code generation"
run_content_eval "$REPO_ROOT/shared/progress-evidence.md" 'parked.*reopen|reopen.*parked' \
  "handoff and resume retain deferred work without restarting it"
run_content_eval "$REPO_ROOT/visual-review/REFERENCE.md" 'generated style.*design intent|design intent.*generated style' \
  "surface review keeps deliberate design ahead of generic generated polish"
