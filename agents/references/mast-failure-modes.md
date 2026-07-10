# MAST multi-agent failure modes (Cemri et al. 2025)

Lazy reference for orchestration audits only -- loaded from
[karpathy-failure-modes.md](../karpathy-failure-modes.md) when the reviewed session
spawned subagents. Not required reading for ordinary diff reviews.

# Multi-Agent Failure Modes (MAST, Cemri et al. 2025)

Source: *Why Do Multi-Agent LLM Systems Fail?* (arXiv:2503.13657, 285 citations as of 2026-04). Empirical taxonomy from 1600+ execution traces across 7 popular MAS frameworks (ChatDev, MetaGPT, HyperAgent, AppWorld, AG2, Magentic-One, OpenManus). Three categories, 14 modes, each annotated with paper's observed failure prevalence.

**When to run these checks:** any agent spawning subagents (`development-lifecycle`, `grilling`, `work`, `resolve-pr-feedback`, `adversarial-reviewer`). Skip for plain single-turn edits.

## Category FC1 -- System Design Issues (44.2% of observed failures)

Failures from architectural or prompt-specification choices at setup. Prevention cheapest -- fix brief, not run.

---

### 8. Disobey Task Specification (FM-1.1, 11.8%)

**Problem**: Subagent ignores or deviates from user's original ask -- e.g., user asked for 5-letter Wordle, subagent implements dictionary-fixed version.

**Mitigation**: Parent restates user's ask verbatim in subagent brief. `subagent-length-cap.sh` caps brief length -- ensure ask survives cap. When launching subagent, include original user sentence under `ORIGINAL_ASK:` in prompt.

**Verify**:
```
# Subagent output must reference the original ask tokens at least once
grep -c "<key noun from ask>" <subagent-transcript>
```

---

### 9. Disobey Role Specification (FM-1.2, 1.5%)

**Problem**: Subagent drops assigned role mid-task -- reviewer starts writing code, adversarial-reviewer starts approving.

**Mitigation**: Every reviewer/planner subagent MUST emit role as first line of output (`{"role": "adversarial-reviewer"}`). Parent rejects response whose first line lacks role.

**Verify**:
```
jq -e '.role == "<expected>"' <subagent-output>.json
```

---

### 10. Step Repetition (FM-1.3, 15.7% -- highest single mode)

**Problem**: Agent or subagent repeats same step (same tool call, same edit, same question) without new information. Biggest driver of MAS failures in paper.

**Mitigation**: Track tool-call signatures in session; flag >=2 identical signatures within N turns. `edit-loop-check.sh` catches identical Edit ops; extend to tool-call-level detection in subagents.

**Verify**:
```
# From metrics-summary output, grep for repeat signatures
jq -r '.tool_calls | group_by(.signature) | map(select(length>1))' <session>.json
```

---

### 11. Loss of Conversation History (FM-1.4, 2.80%)

**Problem**: Subagent forgets earlier turns -- prior decisions, established constraints, completed sub-steps. Common after long subagent runs or compaction.

**Mitigation**: `subagent-length-cap.sh` trims inputs; ensure cap preserves *decisions taken*, not just brief. Before any non-trivial subagent step, re-inject condensed decision log (`## Decisions so far:`).

**Verify**:
```
# Decision log present in subagent context
grep -c "^## Decisions" <subagent-prompt>
```

---

### 12. Unaware of Termination Conditions (FM-1.5, 12.4%)

**Problem**: Agent doesn't know when task done -- keeps generating, keeps refining, or stops too early. Bad in open-ended skills (`grilling` explore mode).

**Mitigation**: Every subagent brief MUST include explicit `TERMINATION:` section listing output shape signaling completion. `lifecycle-stop.sh` handles lifecycle phases; extend pattern to all spawned subagents.

**Verify**:
```
grep -c "^TERMINATION:" <subagent-brief>
```

---

## Category FC2 -- Inter-Agent Misalignment (32.3%)

Failures in coordination, communication, or consistency between agents. Harder to prevent up front -- need runtime checks.

---

### 13. Conversation Reset (FM-2.1, 2.20%)

**Problem**: Subagent spawns fresh, loses parent's context. Only brief survives -- any ambient constraint not in brief gone.

**Mitigation**: Treat every subagent spawn as fresh session. Parent encodes ALL load-bearing context into brief (CLAUDE.md rule refs, decisions taken, files touched). `subagent-start.sh` should log brief contents for audit.

**Verify**:
```
# Subagent brief contains explicit context block
grep -c "^## Context\|^## Constraints" <subagent-brief>
```

---

### 14. Fail to Ask for Clarification (FM-2.2, 6.80%)

**Problem**: Agent proceeds on ambiguous input instead of asking. Common in agents tuned "helpful" -- guess rather than pause.

**Mitigation**: `/grilling` skill = explicit counter. For other agents, require confidence score (`"confidence": 0.0-1.0`) on task interpretation; confidence < 0.7 triggers clarification request before acting.

**Verify**:
```
jq -e '.confidence >= 0.7 or .clarification_requested == true' <subagent-output>.json
```

---

### 15. Task Derailment (FM-2.3, 7.40%)

**Problem**: Agent drifts from original task into adjacent work -- asked to fix bug X, also refactors Y, also adds tests for Z.

**Mitigation**: Parent re-verifies subagent output against original ask's acceptance criteria. Modified files must be justifiable against ask; unrequested scope creep blocks approval.

**Verify**:
```
# Diff scope matches ask
git diff --name-only | xargs -I{} grep -l "<ask_keyword>" {}
```

---

### 16. Information Withholding (FM-2.4, 0.80%)

**Problem**: Agent has relevant info (error details, edge case seen) but doesn't surface to caller/peer. Rare but high-impact when hides bug.

**Mitigation**: Subagent output MUST include `known_unknowns` or `caveats` field; empty field needs justification. Reviewer agents treat missing caveats as red flag.

**Verify**:
```
jq -e 'has("caveats") and (.caveats | type == "array")' <subagent-output>.json
```

---

### 17. Ignored Other Agent's Input (FM-2.5, 1.90%)

**Problem**: In multi-agent debate (`/grilling`, adversarial-reviewer + self-reviewer), one agent responds without referencing peer's claims -- parallel monologues, not debate.

**Mitigation**: Second-turn agents MUST cite at least one specific claim from first-turn agent's output (quoted or paraphrased with reference). Reviewer rejects responses lacking peer citations.

**Verify**:
```
# Second-turn output references first-turn content
grep -cE "<peer>:(claim|said|argued)|refuting|responding to" <round2>.md
```

---

### 18. Reasoning-Action Mismatch (FM-2.6, 13.2% -- second-highest mode)

**Problem**: Agent states will do X, then does Y. Plan says "add test", action runs `git commit` without test. Second-biggest driver of MAS failures in paper.

**Mitigation**: Before every tool call, require agent state intent in one line (`INTENT: <what and why>`). `orchestration-stop.sh` compares intents to executed tool calls; flag divergence.

**Verify**:
```
# Each tool call preceded by INTENT line
awk '/TOOL_CALL/ && !/INTENT/ {print NR}' <session>.log
```

---

## Category FC3 -- Task Verification (23.5%)

Failures in validating outputs -- verifier absent, superficial, or checking wrong thing.

---

### 19. Premature Termination (FM-3.1, 6.20%)

**Problem**: Agent ends before task complete -- returns early success, skips validation, declares done while errors remain.

**Mitigation**: `pr-feedback-completeness-stop.sh` and `lifecycle-stop.sh` gate on completion criteria. Extend to all terminal subagent outputs: each must emit `"status": "complete"|"blocked"|"partial"` with rationale; `complete` without passing verify counts as FM-3.1.

**Verify**:
```
jq -e '.status == "complete" and .verification_passed == true' <subagent-output>.json
```

---

### 20. No or Incomplete Verification (FM-3.2, 8.20%)

**Problem**: Agent generates output without running verification at all, or runs only superficial checks (compile but don't test, syntax check but not behavior).

**Mitigation**: `verifier` agent exists exactly for this; enforce invocation at phase 5 of `development-lifecycle`. Multi-level verification mandatory: (a) types, (b) tests, (c) integration, (d) behavior against ask.

**Verify**:
```
# Verifier agent output present in session
grep -c "subagent_type=\"verifier\"" <session>.log
```

---

### 21. Incorrect Verification (FM-3.3, 9.10%)

**Problem**: Agent verifies wrong thing -- passes unit tests but breaks integration, checks code compiles but output wrong, validates against stale spec.

**Mitigation**: `adversarial-reviewer` runs here -- job = find what passing verify missed. Pair verify + adversarial reviews for high-stakes changes.

**Verify**:
```
# Both verifier + adversarial-reviewer invoked for non-trivial changes
grep -cE "subagent_type=\"(verifier|adversarial-reviewer)\"" <session>.log | awk '$1 >= 2'
```

---

## Machine-readable checks (multi-agent scope)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "checks": [
    { "id": "fm-1.1-disobey-task",         "check": "Subagent output references original user ask",           "command": "grep -c '<ask noun>' <subagent-out>",            "severity": "HIGH",     "scope": "multi-agent" },
    { "id": "fm-1.2-disobey-role",         "check": "Subagent output first line declares role",               "command": "jq -e '.role' <subagent-out>",                   "severity": "MEDIUM",   "scope": "multi-agent" },
    { "id": "fm-1.3-step-repetition",      "check": "No tool-call signature repeated >= 2 times",             "command": "jq -r '.tool_calls | group_by(.signature)' <session>", "severity": "HIGH", "scope": "multi-agent" },
    { "id": "fm-1.4-history-loss",         "check": "Decision log injected into subagent prompt",             "command": "grep -c '## Decisions' <subagent-brief>",        "severity": "MEDIUM",   "scope": "multi-agent" },
    { "id": "fm-1.5-termination-unaware",  "check": "Subagent brief declares TERMINATION condition",          "command": "grep -c '^TERMINATION:' <subagent-brief>",       "severity": "HIGH",     "scope": "multi-agent" },
    { "id": "fm-2.1-conversation-reset",   "check": "Brief carries explicit context block from parent",       "command": "grep -c '## Context\\|## Constraints' <brief>",  "severity": "MEDIUM",   "scope": "multi-agent" },
    { "id": "fm-2.2-no-clarification",     "check": "Subagent emits confidence score or clarification req",   "command": "jq -e '.confidence or .clarification_requested' <out>", "severity": "MEDIUM", "scope": "multi-agent" },
    { "id": "fm-2.3-task-derailment",      "check": "Modified files traceable to ask keywords",               "command": "git diff --name-only | xargs grep -l '<ask>'",   "severity": "HIGH",     "scope": "multi-agent" },
    { "id": "fm-2.4-info-withholding",     "check": "Subagent output includes caveats[] field",               "command": "jq -e 'has(\"caveats\")' <out>",                 "severity": "LOW",      "scope": "multi-agent" },
    { "id": "fm-2.5-ignored-peer",         "check": "Round-2 agent cites round-1 claims",                     "command": "grep -cE 'refuting|responding to' <round2>",     "severity": "MEDIUM",   "scope": "multi-agent" },
    { "id": "fm-2.6-reasoning-action-mismatch", "check": "Each tool call preceded by INTENT line",            "command": "awk '/TOOL_CALL/ && !/INTENT/' <session>",       "severity": "CRITICAL", "scope": "multi-agent" },
    { "id": "fm-3.1-premature-termination", "check": "status=complete requires verification_passed=true",     "command": "jq -e '.status==\"complete\" and .verification_passed' <out>", "severity": "CRITICAL", "scope": "multi-agent" },
    { "id": "fm-3.2-no-verification",      "check": "verifier agent invoked in session",                      "command": "grep -c 'subagent_type=\"verifier\"' <session>", "severity": "HIGH",     "scope": "multi-agent" },
    { "id": "fm-3.3-incorrect-verification","check": "Both verifier + adversarial-reviewer invoked",           "command": "grep -cE 'subagent_type=\"(verifier|adversarial-reviewer)\"' <session>", "severity": "HIGH", "scope": "multi-agent" }
  ]
}
```

## Usage in reviewer agents

For review involving subagent orchestration (lifecycle agents, grilling, resolve-pr-feedback), ALSO include:

```json
"mast_checks": {
  "fm-1.1-disobey-task": "pass|fail|n/a",
  "fm-1.2-disobey-role": "pass|fail|n/a",
  "fm-1.3-step-repetition": "pass|fail|n/a",
  "fm-1.4-history-loss": "pass|fail|n/a",
  "fm-1.5-termination-unaware": "pass|fail|n/a",
  "fm-2.1-conversation-reset": "pass|fail|n/a",
  "fm-2.2-no-clarification": "pass|fail|n/a",
  "fm-2.3-task-derailment": "pass|fail|n/a",
  "fm-2.4-info-withholding": "pass|fail|n/a",
  "fm-2.5-ignored-peer": "pass|fail|n/a",
  "fm-2.6-reasoning-action-mismatch": "pass|fail|n/a",
  "fm-3.1-premature-termination": "pass|fail|n/a",
  "fm-3.2-no-verification": "pass|fail|n/a",
  "fm-3.3-incorrect-verification": "pass|fail|n/a"
}
```

`fail` on any `CRITICAL` item (Karpathy or MAST) blocks review from returning `status: APPROVED`.

`fail` on any `CRITICAL` MAST item blocks review from returning `status: APPROVED`.
