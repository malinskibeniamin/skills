---
name: improve-codebase-architecture
description: Finds deepening opportunities using domain language and ADRs. Use when improving architecture, finding refactors, consolidating coupling, or improving testability.
---

# Improve Codebase Architecture

Goal: find architectural friction and propose **deepening opportunities**: shallow modules -> deeper modules. Optimize testability + AI navigation.

## Language

Use [LANGUAGE.md](LANGUAGE.md) terms exactly: module, interface, implementation, depth, deep, shallow, seam, adapter, leverage, locality.

Principles:

- Deletion test: delete module. If complexity vanishes, pass-through. If complexity spreads to callers, module has depth.
- Interface is test surface.
- One adapter = hypothetical seam. Two adapters = real seam.

Read `CONTEXT.md` + relevant ADRs first. Domain language names good seams. ADRs avoid re-litigating decisions.

## 1. Explore

Use Explore subagent when available. Otherwise `rg`, `find`, tests, call graph reading.

Look for:

- one concept needing many file hops
- shallow modules: interface nearly as complex as impl
- pure functions extracted for testability while bugs hide in call choreography
- coupled modules leaking across seams
- hard-to-test areas

Apply deletion test to suspects.

## 2. HTML report

Write self-contained HTML to temp dir: `$TMPDIR/architecture-review-<timestamp>.html` fallback `/tmp`. Open it. Use [HTML-REPORT.md](HTML-REPORT.md).

Report cards include:

- Files/modules
- Problem
- Solution
- Benefits: locality, leverage, tests
- Before/after visual
- Recommendation: `Strong`, `Worth exploring`, `Speculative`

End with **Top recommendation**.

Use Tailwind CDN + Mermaid CDN. Mix Mermaid for graphs/sequences with custom CSS/SVG for editorial visuals.

Use `CONTEXT.md` terms for domain and [LANGUAGE.md](LANGUAGE.md) terms for architecture. If candidate contradicts ADR, surface only when friction justifies reopening; mark conflict.

Do not propose interfaces yet. Ask: "Which of these would you like to explore?"

## 3. Grilling loop

For chosen candidate, grill constraints, deps, module shape, seam, adapters, tests, rollback.

Inline side effects:

- New domain term -> update `CONTEXT.md` using `/grill-with-docs` format.
- Fuzzy term sharpened -> update `CONTEXT.md`.
- User rejects with durable reason -> offer ADR so future reviews skip same suggestion.
- Need alternative interfaces -> use [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md).

## 4. Issue/RFC

If user wants implementation plan, create refactor RFC with tiny reversible commits. Use [DEEPENING.md](DEEPENING.md) for candidate patterns and [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md) for interface exploration.
