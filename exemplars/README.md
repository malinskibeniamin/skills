# Exemplars -- match the shape

Gold-standard files embodying this harness's conventions. Models imitate
examples better than they follow rules: every /tdd cycle, codex delegation,
and review hat should compare new code against the exemplar of its kind and
match its SHAPE -- naming rhythm, comment restraint, structure, error
handling -- not its content. When a convention changes, change the exemplar
in the same PR.

- `component.tsx` -- registry-first UI, tokens, a11y, states
- `use-resource.ts` -- hook shape: connect-query, named effects, error surfacing
- `route.tsx` -- TanStack route: loader/error boundaries, search params
- `component.test.tsx` -- integration test shape: userEvent, getByRole, waitFor
- `form.tsx` -- proto-driven form: clickable submit + error summary, server FieldViolations onto fields, format validation
- `delete-flow.tsx` -- destructive flow that fails closed: fresh zero-reference check gates confirm, close paths respect in-flight state
- `e2e.spec.ts` -- deterministic e2e: test.step everywhere, cause-based waits, version-free route matchers, side-effect assertions
