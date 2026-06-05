# Harness orchestration learnings

## Scope

This note captures research from three read-only sources:

- `codex-review/SKILL.md` from the linked skills repository.
- `.claude/skills/todo-worker/SKILL.md` from the linked Go repository.
- Bazel, CI, and task-runner patterns in the linked Go repository.

No source repository was modified during research.

## High-leverage patterns

### Goal contracts

A long-running goal should be an execution contract, not a loose reminder.

Recommended fields:

- Objective.
- Non-goals.
- Acceptance criteria.
- Verification commands.
- Current phase.
- Stop condition.
- Blocked condition.
- Artifact links, such as branch, task file, RFC, PR, and reviewed SHA.

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

### Review state machines

Good review workflows separate these stages:

1. Run review in read-only mode.
2. Store review artifact locally.
3. Classify verdict.
4. Reproduce and verify findings.
5. Fix root cause.
6. Add regression test for accepted bugs.
7. Re-run verification.
8. Re-review only the relevant delta.
9. Publish or update PR context.

The key invariant: a clean review is only valid for the exact artifact it reviewed.

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

## Gaps to close in this skills repository

### P0

1. Create a standard goal contract and require it in plans, task files, and subagent briefs.
2. Normalize reviewer schemas across all reviewer and plan-hat agents.
3. Add per-task state files for long-running workflows.
4. Bind every approval to a content hash, commit SHA, or run id.

### P1

1. Add resume preflight to long-running skills: inspect branch, task state, RFC, PR, CI, and reviewed SHA.
2. Split review loops into spec compliance first, then quality review.
3. Add skill-authoring TDD: write a failing pressure scenario before adding or editing a skill.
4. Add structured review footers with status, reviewed artifact, findings, and next action.

### P2

1. Add critical misconception sections to orchestration skills.
2. Compact frontmatter descriptions so they focus on trigger conditions.
3. Move long procedural bodies into reference files when possible.
4. Add CI wiring for evals, hook unit tests, manifest drift, and shell checks.

## Proposed goal contract template

```md
## Goal contract

Objective:

Non-goals:

Acceptance criteria:

Verification:

Stop condition:

Blocked condition:

Artifacts:

Current phase:
```

## Proposed structured review footer

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
