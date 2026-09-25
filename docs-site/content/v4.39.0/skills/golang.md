---
title: "/golang"
description: "Apply evidence-backed Go rules for bounds, APIs, errors, concurrency, Temporal, tests, rollout, and controllers. Use when changing Go services, handlers, workflows, or tests."
type: skill
sidebar:
  label: "/golang"
---
![Diagram of the /golang skill](/diagrams/skills/golang.svg)

[Open the editable Excalidraw source](/diagrams/skills/golang.excalidraw)


This core routes to domain guidance; `/golang-review` owns the aggregate [rule catalog](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang-review/RULES.md). `/aip` owns resource design; this skill owns Go implementation.

## Non-negotiables

- Bound tenant-controlled memory, cardinality, fan-out, concurrency, and response size.
- Traverse protos with generated getters: `a.GetB().GetC()`.
- Proto annotations own field contracts; do not duplicate handler validation.
- Use `optional` only for semantic presence; update intent belongs in masks.
- Collections are paginated, filterable `List`; `Get` returns one resource.
- At API boundaries, log internal causes and return structured Connect/gRPC errors with stable reasons and public paths. Preserve upstream per-item granularity.
- Security fails closed; secrets are references, never plaintext input, storage, output, or logs.
- Bound retry/backoff inside the owning timeout.
- Reuse semantic config types, not strings or bool sets.
- Feature-flag risky mixed-version rollout and remove flags after convergence.
- Bootstrap files wire; packages own behavior.
- Integration tests cross real boundaries; tests assert stable behavior, not paths or incidental text.

## Contextual tensions

- Prefer positive config booleans, except negative `disabled` when the zero value must fail closed.
- Exhaustive enum switches reject unknowns; intentional subsets document ignored values.
- gRPC keepalive depends on every intermediary.
- New AIP surfaces use bounded filter strings; preserve established typed filters for compatibility.
- Fakes suit unit tests, never claims of protocol, role, provider, or container compatibility.

## Load by task

| Work | Read |
|---|---|
| Protos, handlers, Connect/gRPC, public errors | [PROTO-API.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/PROTO-API.md) |
| Goroutines, caches, shutdown, shared state | [CONCURRENCY.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/CONCURRENCY.md) |
| Errors, logging, metrics | [ERRORS.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/ERRORS.md) |
| Tests and CI | [TESTING.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/TESTING.md) |
| Temporal | [TEMPORAL.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/TEMPORAL.md) |
| Tenant input, egress, authz, secrets, destructive ops | [SECURITY.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/SECURITY.md) |
| Flags, deprecation, schema removal | [ROLLOUT.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/ROLLOUT.md) |
| Packages, storage, interfaces | [STRUCTURE.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/STRUCTURE.md) |
| Operators and reconcilers | [CONTROLLERS.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/CONTROLLERS.md) |
| Go 1.27 APIs and leak profiles | [GO-1.27.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/golang/GO-1.27.md) |

Hooks warn on unreserved shipped proto removals and floating test images. Review diffs with `/golang-review`.
