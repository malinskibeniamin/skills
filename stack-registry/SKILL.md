---
name: stack-registry
description: Govern current and banned frontend stacks. Use when adding library-specific rules, starting stack migrations, retiring old guidance, or checking for stale APIs.
---

Harness guidance is either durable **invariant** (`/frontend-invariants`) or versioned **stack rule**. Tag library/API rules with their stack generation so migrations replace them instead of leaving stale instructions.

## Current `stack:2026`

| Layer | Current | Owner |
|---|---|---|
| UI | Tailwind v4, shadcn/Base UI, registry | registry-workflow, visual-review, hooks |
| Router | TanStack Router, file routes/loaders/validateSearch | tanstack-router |
| Data | connect-query, gRPC, protobuf-es v2, protovalidate | connect-query |
| Forms | react-hook-form; zod only for route search | form hooks |
| Client state | zustand, React context | zustand hooks |
| React | 19 + Compiler; no manual memo/forwardRef | react hooks |
| Build/test | rsbuild, Vitest tiers/browser, Playwright | test hooks, e2e-testing |

## Banned and frozen

Never recommend or accept: Chakra/legacy kits; `react-router-dom`; RTK Query/redux-observable; MobX; Formik; Yup; react-intl/`FormattedMessage` dictionaries; CRA/react-scripts/jest idioms; nuqs. Hooks/lint enforce bans.

Keep at most one library-free meta-lesson from old guidance. Treat banned-stack review history as evidence, never instruction.

## Migration

1. Grill choice: big-bang router/framework; strangler data layers with coexistence budget.
2. Add and generation-tag the new rule group.
3. Same PR: ban old library mechanically (`noRestrictedImports`/hook), retire or era-tag guidance.
4. Update exemplars in that PR; models imitate them strongly.
5. Definition of done includes the freeze so agents cannot resurrect the dead stack.

## Rule checklist

For every library/API rule: if it is stack-independent, move it to `/frontend-invariants`; otherwise tag `stack:2026`, add a mechanical check when possible, and specify the replaced pattern that check rejects.
