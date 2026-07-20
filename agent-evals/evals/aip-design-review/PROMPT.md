# Task

Use the installed `aip` skill to review `candidate.proto`. This is an adversarial
API proposal, not a request to preserve every choice in the file.

Context:

- `LibraryService` is a public management-plane API already released as stable
  `v1`.
- Existing clients know field 2 on `Book` as `title`; the proposal renames it to
  `display_name` without changing its field number.
- Book revisions are only a possible future feature.
- `software_version` exposes a third-party database version.
- `EventIngressService` is a latency-sensitive data-plane API using an
  established publish protocol. Do not force management-plane resource methods
  onto it merely for uniformity.
- `./tools/api-linter candidate.proto` is the repository's available linter
  command.

Produce exactly two deliverables:

1. `review.md`, with an evidence table headed
   `AIP | state | applicability | result | evidence/exception`. Select AIPs by
   applicability, link the exact official pages consulted, distinguish
   normative failures from advisory suggestions, identify non-applicable AIPs,
   and explain compatibility exceptions.
2. `corrected.proto`, the smallest corrected management-plane schema. Preserve
   the valid data-plane custom method. Do not turn advisory revision or external
   dependency guidance into normative blockers or invent their unfinished
   designs.

Run the repository linter, but do not claim that a clean linter result proves
full conformance. Do not search for or install protobuf dependencies; this eval
scores the design review, not compilation.
