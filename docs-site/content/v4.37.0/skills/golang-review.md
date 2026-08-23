---
title: "/golang-review"
description: "Review Go against evidence-backed rules for bounds, APIs, concurrency, errors, security, tests, and rollout. Use for Go diffs, PRs, branches, modules, or backend protos."
type: skill
sidebar:
  label: "/golang-review"
---
![Diagram of the /golang-review skill](/diagrams/skills/golang-review.svg)

[Open the editable Excalidraw source](/diagrams/skills/golang-review.excalidraw)

One review axis: does this Go diff follow the evidence-backed conventions in
[RULES.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang-review/RULES.md)? Each catalog rule carries an anonymous aggregate support count,
so findings cite the rule id and explain repository-visible impact rather than relying
on reviewer taste.

Runs standalone on any Go diff, or inline as the **golang hat** inside `/review`. Explicit
delegation or `/swarm` may use this skill as a bounded reviewer-lane contract.

## Non-goals

- Anything `golangci-lint` already enforces in the target repo -- read its config first and skip those.
- Generic Go style (gofmt, naming, comment grammar) with no RULES.md backing.
- Frontend, generated files (`*.pb.go`, `*_pb.go`, `*.connect.go`, `@generated`/`DO NOT EDIT`), vendored code.
- Re-litigating the catalog: a rule you disagree with is feedback for the catalog, not a finding to invert.

## Procedure

1. **Scope**: diff from fixed point to HEAD, Go and proto files only. Note the repo's
   `.golangci.yml` enabled linters; anything they enforce is out of scope.
2. **Classify** the diff into domains: proto/API surface, service handlers, Temporal
   workflows/activities, Kubernetes controllers, tests, config/rollout, tenant-facing
   security paths, concurrency/lifecycle.
3. **Load** the matching sections of [RULES.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang-review/RULES.md) and the matching `/golang`
   domain files (PROTO-API, CONCURRENCY, ERRORS, TESTING, TEMPORAL, SECURITY, ROLLOUT,
   STRUCTURE, CONTROLLERS). Apply every S/A rule in scope; B on clear violation; C/D
   only when the diff plainly violates the statement.
4. **Check the tensions list** in RULES.md and `/golang` SKILL.md before writing a
   finding -- positive-boolean vs fail-closed, enum-subset switches, keepalive,
   filter objects vs strings are context-dependent, not violations.
5. **Report** findings, each with: rule id, file:line, what the diff does, the required
   change, and priority. Max 400 words as a panel hat; standalone runs may go longer
   but stay catalog-backed.

## Severity

- **P0**: fail-open security predicate, tenant egress bypassing safedial, plaintext
  secret stored/returned/logged, progress committed before durable processing,
  unversioned change breaking live Temporal histories.
- **P1**: any other S/A violation -- unbounded tenant-controlled growth, raw internal
  errors on the public surface, missing staged removal, integration claim on mocks.
- **P2**: B violations; S/A cases needing a judgment call the author should answer.
- **P3**: C/D wording and polish.

Confirmed bugs stay P0/P1 regardless of fix size.

## Output

Standard hat contract: findings must be diff-introduced, user-impacting, actionable,
each PR-comment-ready (What, Why tied to the catalog rule, Suggested fix, One-shot prompt).
When no rule in scope is violated: `APPROVED -- <domains checked>, no catalog violations.`
