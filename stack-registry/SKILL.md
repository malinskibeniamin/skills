---
name: stack-registry
description: Governance for stack-tagged rules -- the current frontend stack, the banned ones, and wholesale rule retirement. Use when adding harness rules that name a library/API, when a stack migration starts, or when guidance smells stale.
---

# Stack Registry

Harness rules come in two durability classes. **Invariants** (see `/frontend-invariants`) never expire. **Stack rules** name a library or API and MUST be tagged with the stack generation so the next migration replaces them wholesale instead of leaving stale guidance that misleads agents. History: rule sets for four dead stacks lingered as "current guidance" long after the code moved on -- that is the failure mode this skill prevents.

## Current stack (`stack:2026`)

| Layer | Current | Rules live in |
|---|---|---|
| UI kit | Tailwind v4 + shadcn/Base UI + vendored registry | registry-workflow, visual-review, tailwind hooks |
| Router | TanStack Router (file-based, loaders, validateSearch) | tanstack-router |
| Data | connect-query + gRPC + protobuf-es v2 + protovalidate | connect-query |
| Forms | react-hook-form (+ proto-driven resolvers); zod only for route search schemas | form-mode hooks |
| Client state | zustand + React context | zustand hooks |
| React | 19 + Compiler (no manual memo, no forwardRef) | react-rules hooks |
| Build/test | rsbuild / vitest 4-tier (+ browser baselines) / Playwright | test-convention hooks, e2e-testing |

## Banned stacks (mechanically frozen)

Enforced by hooks/lint bans -- never recommend, never accept in new code, never quote their idioms as guidance:

`chakra` / legacy shared UI kits · `react-router-dom` · Redux Toolkit Query / redux-observable · MobX (`observer`, `makeObservable`, `useLocalObservable`) · Formik · Yup · react-intl / `FormattedMessage` + i18n dictionary machinery · CRA/react-scripts/jest idioms · nuqs (router owns search typing).

Each ban keeps at most one meta-lesson (e.g. Yup -> "validate format, not presence" survived; the mechanics did not). When mining or quoting historical code review guidance, anything referencing a banned stack is historical evidence, not instruction.

## Migration playbook (when a layer changes)

1. **Grill first**: big-bang for router/framework layers, strangler for data layers; budget for months of coexistence on data.
2. Write the new stack's rule group; tag it with the new generation.
3. Retire the old group in the SAME PR: move the library to the banned table, add the mechanical ban (hook/`noRestrictedImports`), delete or era-tag its guidance.
4. Update exemplars in the same PR -- models imitate exemplars harder than rules.
5. The migration's definition of done includes the freeze; an unbanned dead stack WILL be resurrected by an LLM author.

## Rule-authoring checklist

Adding any rule that names a library/API: (a) is it actually an invariant in disguise? state it library-free in `/frontend-invariants` instead; (b) tag it `stack:2026` in its home skill/hook; (c) give it a mechanical check when possible -- unenforced rules drift; (d) add the negative: what replaced pattern must the hook now reject?
