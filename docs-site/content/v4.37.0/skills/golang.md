---
title: "/golang"
description: "Apply evidence-backed Go rules for bounds, APIs, errors, concurrency, Temporal, tests, rollout, and controllers. Use when changing Go services, handlers, workflows, or tests."
type: skill
sidebar:
  label: "/golang"
---
![Diagram of the /golang skill](/diagrams/skills/golang.svg)

[Open the editable Excalidraw source](/diagrams/skills/golang.excalidraw)

Conventions synthesized from two years of multi-repository review: 102 rules, each
supported by at least three independent examples. This file holds the core; domain files
hold the working guidance; anonymous aggregate support lives in the `/golang-review`
[rule catalog](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang-review/RULES.md). `/aip` owns proto resource *design*; this
skill owns the Go *implementation* around it.

## Non-negotiables (S grade)

- **Bound everything workload- or tenant-controlled**: memory, cardinality, fan-out, concurrency, response size. Unbounded input becomes OOM and cardinality failure.
- **Traverse protos with generated getters** -- `a.GetB().GetC()`, never nil-check ladders.
- **Proto annotations own field contracts** (behavior, requiredness, bounds); never duplicate validation in handlers.
- **`optional` only for semantic presence**: if zero is a legitimate value, no `optional`; update intent lives in the mask.
- **Collections are `List`** -- paginated and filterable; `Get` returns exactly one resource.
- **Translate errors at the API boundary**: log the internal cause, return structured Connect/gRPC errors with stable reasons and public field paths. Preserve upstream protocol granularity (Kafka per-partition, per-item) on the way.
- **Security predicates fail closed**: missing config, errored license/authz backend, partial policy state deny -- never default to allow.
- **Secrets are references**: never accept, store, return, or log plaintext secret material.
- **Retry/backoff fits the operation lifetime**: jitter, bounded max, cumulative horizon inside the owning timeout.
- **Config uses semantic types**: reuse the repo's config structs (`config.TLS`, durations, enums), never bare strings and bool sets.
- **Feature-flag risky mixed-version rollouts**; flags are migration tools, removed after the fleet converges.
- **Server/bootstrap files wire; packages own behavior** -- construction and wiring only in `server.go`.
- **Integration tests cross the real boundary**; mocks never prove provider, billing, or serialization compatibility.
- **Tests assert stable observable behavior**, not path execution or incidental message text.

## Tensions -- context decides, do not flatten

- Positive config booleans for readability -- **except** when the Go zero value must
  fail closed on a security path; then a negative `disabled` field is correct.
- Enum switches fail on unknown values only when they claim the full domain; an
  intentional subset documents and ignores the rest.
- gRPC keepalive depends on every intermediary acknowledging it; no universal setting.
- AIP-compatible surfaces use bounded filter strings; established typed-filter APIs
  preserve their object shape for compatibility.
- Unit tests fake dependencies freely; the moment a test claims boundary compatibility
  it must cross the real protocol, role, provider, or container.

## Domain files

| Working on | Read |
|---|---|
| Protos, handlers, Connect/gRPC surface, public errors | [PROTO-API.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/PROTO-API.md) |
| Goroutines, channels, caches, shutdown, shared state | [CONCURRENCY.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/CONCURRENCY.md) |
| Error wrapping/classification, logging, metrics | [ERRORS.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/ERRORS.md) |
| Any `_test.go`, fixtures, CI behavior | [TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/TESTING.md) |
| Temporal workflows, activities, signals | [TEMPORAL.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/TEMPORAL.md) |
| Tenant input, egress, authz, secrets, destructive ops | [SECURITY.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/SECURITY.md) |
| Config surfaces, flags, deprecations, schema/field removal | [ROLLOUT.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/ROLLOUT.md) |
| Package boundaries, storage layers, interfaces | [STRUCTURE.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/STRUCTURE.md) |
| Kubernetes operators and reconcilers | [CONTROLLERS.md](https://github.com/malinskibeniamin/skills/blob/v4.37.0/golang/CONTROLLERS.md) |

## Hooks

Two mechanical checks run on edits; both warn, never block:

- `go-proto-reserved`: removing a shipped proto field must add `reserved N;` and
  `reserved "name";`; renumbering is never safe. Escape: `// allow: proto-unshipped [reason]`.
- `go-test-image-pin`: test/container images pin a supported release tag, never
  `:latest`/`:main`/`:master`. Escape: `// allow: floating-image [reason]`.

Reviewing a diff instead of writing code? That is `/golang-review`.
