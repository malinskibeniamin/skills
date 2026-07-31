# Harness orchestration learnings

## Scope

This note captures research from three read-only sources:

- `codex-review/SKILL.md` from the linked skills repository.
- `.claude/skills/todo-worker/SKILL.md` from the linked Go repository.
- Bazel, CI, and task-runner patterns in the linked Go repository.

No source repository was modified during research.

## High-leverage patterns

### Outcome contracts

A long-running goal should be an outcome contract, not a loose reminder or a workflow
script. Ordinary short tasks keep this in conversation.

Recommended fields:

- Objective.
- Guardrails.
- Verification.
- Stop condition, including real blockers.
- Artifact links when execution must survive a session boundary.

The useful pattern is outcome-oriented goal text, for example: work item plus the exact end state that proves completion. The harness should keep driving until that state is reached or a blocked condition is met.

### Durable task state

The todo-worker flow is strong because it has a deterministic queue and review gates, but its state is spread across chat, branch, commits, RFC, TODO checkbox, and PR comments.

Add a machine-readable state file per long-running task:

```json
{
  "itemId": "P1.2",
  "phase": "implementation_review",
  "branch": "feat/p1-2-example",
  "rfcPath": "rfcs/012-example.md",
  "prUrl": "https://github.com/example/repo/pull/123",
  "headSha": "abc1234",
  "lastReviewedSha": "abc1234",
  "reviewers": {
    "spec": "approved",
    "quality": "approved",
    "external": "pending"
  },
  "blockedReason": null
}
```

This makes resume behavior idempotent. On restart, the controller can inspect existing artifacts and continue from the next incomplete phase instead of creating duplicates.

### Approval freshness

Approvals should bind to immutable artifacts:

- RFC approval binds to an RFC content hash.
- Implementation approval binds to a commit SHA.
- Final approval binds to the current HEAD.

Any change after approval should either invalidate the approval or record why it remains valid.

### Positive completion signals

Do not infer async completion from weak signals like comment count, body length, checklist state, or generic words like "working". Use positive signals:

- Explicit finished marker.
- Completed CI run.
- Stored reviewed SHA.
- Structured status footer.

This prevents both early exits and endless polling.

### Review freshness

Use one loop: inspect the fixed artifact, verify claims, classify actionable findings, and
synthesize. Accepted defects return to implementation and invalidate affected evidence.
The key invariant: a clean review is valid only for the exact artifact it reviewed.

### Misconception-first skill docs

The codex-review skill is effective because it starts with the failure mode agents are likely to assume: waiting for a review that will never appear unless manually started.

Reusable section for orchestration skills:

```md
## Critical misconception

Do not wait for X unless you triggered X. If X is expected, start it with the command below.
```

This pattern is valuable anywhere agents otherwise poll, idle, or wait for an external actor.

### Safe external review defaults

For expensive or external review agents, default to:

- Read-only sandbox.
- No approval prompts.
- Deterministic output file.
- Separate trace log.
- Manual publish step.
- Clean-tree preflight.
- Cost warning for large diffs.

The run artifact and publish action should be separate. This gives the controller a moderation and freshness checkpoint.

## Bazel patterns for agent harnesses

The Go repository uses Bazel in a way that is friendly to agents.

Useful patterns:

- Bzlmod only, with `MODULE.bazel.lock` committed.
- `bazelisk`, not raw `bazel`.
- `justfile` as the operator interface.
- `just generate && git diff --exit-code` as generated-code drift gate.
- Build Event Protocol JSON emitted for tests.
- HTML report generated from BEP and test artifacts.
- Tags separate fast PR tests, conformance, stress, manual, fuzz, and benchmark work.
- Long or Docker-heavy targets are isolated from default PR verification.
- Test parallelism is capped where external resources can saturate.

Harness recommendations:

- Agents should call named `just` recipes instead of inventing shell commands.
- Agents should parse BEP or structured reports instead of raw logs.
- Add query helpers such as `just affected FILE`, `just test-target PKG`, and `just why-dep FROM TO`.
- Keep generated-code drift checks in CI.
- Pin Docker images by digest for genrules.
- Add checksums to custom repository downloads.
- Preserve tag taxonomy so agents do not accidentally run hour-scale work.

## Remaining evidence questions

1. On each major model release, rebuild ambient context from the bare-model ablation and
   restore only groups that improve quality.
2. Shadow non-strict hooks before deletion and qualify retention data by harness version,
   model, and real versus synthetic run.
3. Replace eval tasks once every context variant passes them; saturated checks cannot
   justify prompt weight.
4. Use persistent task state and structured review footers only for workflows that must
   survive session boundaries. Ordinary work stays in the compact outcome loop.

## Proposed outcome contract template

```md
## Outcome contract

Objective:

Guardrails:

Verification:

Stop condition:

Artifacts:
```

## Structured footer for persistent automation

```yaml
status: approved | needs_changes | blocked | skipped
reviewed_artifact:
  type: commit | rfc | diff | pr
  id: <sha-or-hash-or-url>
findings:
  - severity: p0 | p1 | p2 | p3
    file: <path>
    line: <line-or-null>
    claim: <short finding>
    evidence: <why this is true>
next_action: <what controller should do next>
```
