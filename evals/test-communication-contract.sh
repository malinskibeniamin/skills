#!/bin/bash

# Public prompt-contract and routing checks, not evidence of model compliance.
CONTRACT="$REPO_ROOT/shared/communication.md"
run_file_eval "$CONTRACT" "shared reader-attention contract exists"

for entry in CLAUDE.md AGENTS.md shared/intent-map.md shared/TSTACK.md pr/SKILL.md review/SKILL.md grilling/SKILL.md development-lifecycle/SKILL.md efficient-frontier/SKILL.md; do
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

# The PR prompt is the public artifact here, not proof of model compliance.
PR_CONTRACT="$REPO_ROOT/pr/SKILL.md"
run_content_eval "$CONTRACT" 'one sentence.*entire change.*why it matters' \
  "every PR opens with the whole change and its purpose in one sentence"
run_content_eval "$CONTRACT" '10 seconds' \
  "the PR opening has a ten-second first-read budget"

# Templates are public prompts: prove neither entrypoint puts headings or metadata
# ahead of the opening sentence. This checks guidance, not generated PR quality.
if python3 - "$PR_CONTRACT" "$REPO_ROOT/commit-push-pr/REFERENCE.md" <<'PY'
import sys
from pathlib import Path

for path, marker in zip(sys.argv[1:], ("```markdown\n", "<<'EOF'\n")):
    body = Path(path).read_text().split(marker, 1)[1].lstrip()
    opening = body.split("\n\n", 1)[0]
    assert "\n" not in opening and not opening.startswith(("#", "-", "*")), path
    assert "one sentence" in opening and "entire change" in opening and "why it matters" in opening, path
PY
then
  echo '  PASS  both PR templates start with a standalone whole-change sentence'
  PASS=$((PASS + 1))
else
  echo '  FAIL  a PR template puts headings, metadata, or a partial summary first'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: PR opening sentence placement"
fi

run_content_eval "$PR_CONTRACT" 'scope, contracts, verification, or rollout risk' \
  "PR decision context is limited to consequential departures"
run_content_eval "$PR_CONTRACT" 'prior choice -> new evidence -> current choice -> review consequence' \
  "PR guidance carries decision changes from existing records to review"
run_content_eval "$PR_CONTRACT" 'self-contained.*empty.*never invent' \
  "PR rationale stands alone without empty or invented history"
run_content_eval "$PR_CONTRACT" 'authorized, redacted.*accessible to reviewers' \
  "optional session context preserves authorization and reviewer access"
run_content_eval "$PR_CONTRACT" 'otherwise give safe standalone rationale' \
  "unavailable session context has a safe prose fallback"
run_content_eval "$PR_CONTRACT" 'neither correctness nor diligence' \
  "session activity is not a quality certificate"
run_content_eval "$PR_CONTRACT" 'current diff and execution evidence' \
  "session claims remain subject to current implementation evidence"
