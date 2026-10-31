---
description: "Catch what a change claims but does not do: hallucinated APIs or claims, code that fakes success, tests that cannot fail, unrequested changes, copyable anti-patterns. Use on every PR."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["lie detector"]}
sidebar: {"label":"/lie-detector"}
title: "/lie-detector"
type: "skill"
---
![Diagram of the /lie-detector skill](/diagrams/skills/lie-detector.svg)

[Open the editable Excalidraw source](/diagrams/skills/lie-detector.excalidraw)


Treat changes as unproven; steelman "this should not merge". Standalone or inline
**lie-detector hat** in `/review` on every diff; prioritize customer-facing surfaces.
Defects: `/review`; value: `/product`. Pin scope, including captured WIP.

## 1. Claims without evidence

Require diff lines, command output or primary docs for claims in PRs, commits, code, docs and summaries:

- Phantom surface: symbol/prop/hook/flag/config/env/token/route/option absent at the installed version.
  Check lockfile, `node_modules` types or primary docs, not memory.
- "Tested", "verified", "fixes X", "no behavior change": needs the command and output or a
  red-then-green pair.
- Citations that do not support their claims.

## 2. Code that pretends

Trace changed paths to caller-visible output; flag unperformed work:

- success before the work completes: a toast, redirect, or `200` before the mutation,
  write, or invalidation resolves;
- errors that swallow, log-only, or fall back to defaults, placeholders, or cached data
  while the UI shows success;
- stubs, TODOs, hardcoded or mock data, or disabled branches shipped as done;
- a flag, option, or config key that no code path reads;
- names, comments, types, or casts that disagree with the code they describe;
- loading, empty, or error states that cannot be reached or never end.

## 3. Tests that cannot fail

For each added or changed test:

1. In a disposable snapshot per [review isolation](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/REFERENCE.md#source-snapshots-and-mutation-tests), break the behavior it claims to protect:
   invert the changed condition, drop the rendered element, or change the user-visible value; wiring-only breaks miss tautologies.
   Rerun there; leave original files, index, and branch untouched. Still green: the test lies.
   Count RED only from an assertion, not setup failure. Record the command and failure.
   Unavailable isolation is a named evidence gap, not permission to mutate the active checkout.
2. Check survivors against the [test-audit junk patterns](https://github.com/malinskibeniamin/skills/blob/v4.42.0/test-audit/SKILL.md#junk-patterns).
3. A behavior change with no test that went red and no real-entrypoint replay (`/dogfood`)
   is unproven.

## 4. Changes nobody asked for

Flag unexplained out-of-scope behavior changes or weakened guards: deleted, skipped, or loosened tests; regenerated snapshots;
`@ts-ignore` or lint suppressions; changed defaults, copy, routes, flags, error handling,
retries, or timeouts; widened exclusions, relaxed compiler/lint rules, or shell/CI failure
exits turned into success; lockfile or config churn; hand-edited generated files; a visual
change with no screenshot. Review changed checks/configs separately from the implementation
they judge; a justified rule correction needs known-bad and valid cases through its real command.

Trace auth-proof creation: casts, unchecked constructors and comments cannot authorize.
Green types do not prove a trusted module sound. For assertions/type evidence/rules, use
[anti-slop](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/anti-slop.md); taste is not a defect.

## 5. Patterns that will spread

Compare introduced idioms with precedent (`rg`), root/scoped `CLAUDE.md`/`AGENTS.md`,
`exemplars/` and stack registry. Contradicting policy/dominant idiom is a finding. Copy reach:
shared components/hooks/fixtures/helpers/templates/generators/exemplars/skills = P1; leaf = P2.
Fix the source pattern or update its rule in the PR with rationale; do not leave competing styles.

## 6. Steelman gate

Follow [steelman/SKILL.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/steelman/SKILL.md) on the premise "this PR should merge".
Argue the strongest case against it from the [product](https://github.com/malinskibeniamin/skills/blob/v4.42.0/product/SKILL.md) verdict, the findings
above, and `/review` findings. **Merge-ready** only when all three hold:

- value: the `product:` verdict is `justified`;
- truth: no P1 here, and every changed behavior has a red-then-green test or a
  real-entrypoint replay;
- implementation: `/review` reports no P0/P1.

Otherwise **not proven**; name the missing proof. Drop counterarguments without
file:line or command output. Never block on preference.

## Severity

- **P1**: a claim the code or docs contradict; a phantom API; code that reports success it
  did not achieve; a test green on broken behavior; an unexplained behavior change or
  weakened guard; an anti-pattern in a copyable place.
- **P2**: an unverified but plausible claim; a misleading name or comment; a leaf
  anti-pattern; a tautological assertion beside real ones.
- **P3**: summary only.

Report at most five findings, merge-deciding first.
## Output

Lead with one verdict line:
`lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence, at most 20 words>`

`truthful`: no findings. `suspect`: P2 only. `lying`: any P1. Then
`[P1|P2|P3] <file:line> <section> -- <lie and proof>; <smallest fix>`. Clean pass: verdict only.
