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
run_content_eval "$CONTRACT" 'routine review/testing/risk detail stays inside' \
  "PR supporting prose has a compact default instead of a section inventory"
run_content_eval "$CONTRACT" 'collapsed agent-generated description' \
  "long required receipts stay available outside the main read"

# Public prompts: canonical scaffold, publication routing and GitHub front door.
# Follow supporting prose through its required reference instead of duplicating it.
if python3 - "$PR_CONTRACT" "$REPO_ROOT/commit-push-pr/REFERENCE.md" "$REPO_ROOT/.github/pull_request_template.md" <<'PY_CHECK'
import re
import sys
from pathlib import Path

canonical, publication, github = [Path(path).read_text() for path in sys.argv[1:]]
body = canonical.split("```markdown\n", 1)[1].split("\n```", 1)[0].strip()
opening = body.split("\n\n", 1)[0]
assert "\n" not in opening and "human-authored line about the change and why" in opening
assert "explicitly labeled agent draft" in opening
assert "../pr/SKILL.md#body-template" in publication
assert github.index("One line: what changes and why") < github.index("| Before | After |")
for prompt in (body, github):
    visible = re.sub(r"<!--.*?-->", "", prompt, flags=re.S)
    assert visible.count("<details>") == visible.count("</details>") == 1
    before, detail = visible.split("<details>", 1)
    assert "| Before | After |" in before
    assert "<summary>Agent-generated description</summary>" in detail
    assert "UI packaging:" in visible
    assert 1 <= sum(line.startswith("- ") for line in detail.splitlines()) <= 3
    assert not any(line.startswith("- ") for line in before.splitlines())
    assert not any(line.startswith("#") for line in visible.splitlines())
assert "SUMMARY-VIEWS.md#supporting-description" in canonical
PY_CHECK
then
  echo '  PASS  PR templates preserve human intent, UI comparisons and packaging, and collapsed agent detail'
  PASS=$((PASS + 1))
else
  echo '  FAIL  a PR template buries the opening or expands into a wall of text'
  FAIL=$((FAIL + 1))
  ERRORS="$ERRORS\n  FAIL: PR opening sentence placement"
fi

PR_DESCRIPTION="$REPO_ROOT/pr/SUMMARY-VIEWS.md"
run_content_eval "$PR_DESCRIPTION" 'scope, contracts, verification, or rollout risk' \
  "PR decision context is limited to consequential departures"
run_content_eval "$PR_DESCRIPTION" 'prior choice -> new evidence -> current choice -> review consequence' \
  "PR guidance carries decision changes from existing records to review"
run_content_eval "$PR_DESCRIPTION" 'self-contained.*empty.*never invent' \
  "PR rationale stands alone without empty or invented history"
run_content_eval "$PR_DESCRIPTION" 'authorized, redacted.*accessible to reviewers' \
  "optional session context preserves authorization and reviewer access"
run_content_eval "$PR_DESCRIPTION" 'otherwise give safe standalone rationale' \
  "unavailable session context has a safe prose fallback"
run_content_eval "$PR_DESCRIPTION" 'neither correctness nor diligence' \
  "session activity is not a quality certificate"
run_content_eval "$PR_DESCRIPTION" 'current diff and execution evidence' \
  "session claims remain subject to current implementation evidence"
