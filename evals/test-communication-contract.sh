#!/bin/bash

# Public prompt-contract and routing checks, not evidence of model compliance.
CONTRACT="$REPO_ROOT/shared/communication.md"
run_file_eval "$CONTRACT" "shared reader-attention contract exists"

for entry in CLAUDE.md AGENTS.md shared/intent-map.md pr/SKILL.md review/SKILL.md grilling/SKILL.md development-lifecycle/SKILL.md efficient-frontier/SKILL.md; do
  run_content_eval "$REPO_ROOT/$entry" 'communication\.md' \
    "$entry routes relevant communication or tool choice to the shared contract"
done

run_content_eval "$CONTRACT" '120 words' "first read has a bounded reader budget"
run_content_eval "$CONTRACT" '200 words' "long communication has an explicit structure trigger"
run_content_eval "$CONTRACT" '[*][*]What / why:[*][*]' "brief explains why the change matters"
run_content_eval "$CONTRACT" '[*][*]Risk:[*][*]' "brief retains consequential risks"
run_content_eval "$CONTRACT" '[*][*]Ask:[*][*]' "brief names the requested reader action"
run_content_eval "$CONTRACT" 'count.*(tool|script|wc)|wc.*count' \
  "requested word limits are checked mechanically"
run_content_eval "$CONTRACT" 'author.*(intent|meaning)|meaning.*author' \
  "editing preserves the author's intent rather than just polishing"
run_content_eval "$CONTRACT" 'endorsement|sign-off' \
  "AI cannot invent human endorsement"
run_content_eval "$CONTRACT" 'unverified|inference' \
  "unsupported conclusions stay visibly qualified"
run_content_eval "$CONTRACT" 'observ.*evidence|evidence.*observ' \
  "claims trace to observations rather than private reasoning"
run_content_eval "$CONTRACT" 'propos.*(shipped|implemented)|shipped.*propos' \
  "RFCs distinguish proposals from shipped decisions"
run_content_eval "$CONTRACT" 'reply|feedback' \
  "feedback receives a substantive response instead of a paraphrase"
run_content_eval "$CONTRACT" 'AI excerpt|AI-generated excerpt' \
  "unendorsed model material is labeled as an excerpt"
run_content_eval "$CONTRACT" 'deterministic.*(script|CLI)|(script|CLI).*deterministic' \
  "repeatable work favors deterministic execution"
run_content_eval "$CONTRACT" 'latency|concurrency' \
  "agent concurrency is not the default answer to latency"
run_content_eval "$CONTRACT" 'schema|safety' \
  "brevity preserves owning output schemas and safety evidence"
