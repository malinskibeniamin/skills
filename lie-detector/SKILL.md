---
name: lie-detector
description: "Catch what a diff claims but does not do: tests that cannot fail, hallucinated APIs, unrequested changes, copyable anti-patterns. Use on consumer-facing diffs and before calling a PR mergeable."
---

Treat the change as unproven. Steelman "this should not merge", then let the diff refute it
with evidence. Runs standalone or inline as the **lie-detector hat** in `/review` on every
customer-facing diff (UI, copy, CLI output, public API, report). Code defects stay in
`/review`; value stays in `/jb`.

Work on a committed tree; set `BASE` to the merge base.

## 1. Tests that cannot fail

For each added or changed test that covers consumer-facing behavior:

1. Break the behavior it claims to protect: `git diff "$BASE" -- <src> | git apply -R`,
   invert the changed condition, drop the rendered element, or change the value the user
   sees (copy, count, state); wiring-only breaks miss tautologies. Run the test, then
   `git checkout HEAD -- <src>`. Still green on broken code: the test lies. The red must
   come from an assertion, not an import, compile, or setup error. Record the command and
   the failure message.
2. Check survivors against the [test-audit junk patterns](../test-audit/SKILL.md#junk-patterns).
3. A consumer-facing behavior change with no test that went red and no real-entrypoint
   replay (`/dogfood`) is unproven.

## 2. Claims without evidence

List every claim in the PR title, body, commits, code comments, docs, and agent summary.
Each needs a diff line, command output, or primary doc:

- Phantom surface: an imported symbol, prop, hook, CLI flag, config key, env var, design
  token, route, or option that does not exist at the installed version. Check lockfile,
  `node_modules` types, or primary docs, not memory.
- "Tested", "verified", "no behavior change", "fixes X": needs the command and output or a
  red-then-green pair.
- A cited file:line, issue, or doc that does not say what the claim says.

## 3. Changes nobody asked for

Compare every hunk with the stated scope. Flag each unexplained hunk that changes observable
behavior or weakens a guard: deleted, skipped, or loosened tests; regenerated snapshots; casts,
`@ts-ignore`, lint suppressions; changed defaults, copy, routes, flags, error handling,
retries, or timeouts; lockfile or config churn; hand-edited generated files; a visual change
with no screenshot.

## 4. Patterns that will spread

People and agents copy the nearest example. For each idiom the diff introduces:

- Find precedent with `rg`; compare with root and scoped `CLAUDE.md`/`AGENTS.md`,
  `exemplars/`, and the stack registry.
- Contradicts a documented rule or the dominant repo idiom: finding. Severity follows copy
  reach: a shared component, hook, fixture, test helper, template, generator, exemplar, or
  skill is P1; leaf code is P2.
- Fix at the source: use the sanctioned pattern, or update the rule in the same PR and say
  why the new one is better. Two live styles is the defect.

## 5. Steelman gate

Follow [steelman/SKILL.md](../steelman/SKILL.md) on the premise "this PR should merge".
Argue the strongest case against it from the [jb](../jb/SKILL.md) verdict, the findings
above, and `/review` findings. **Merge-ready** only when all three hold:

- value: the `jb:` verdict is `justified`;
- truth: no P1 here, and every consumer-facing behavior has a red-then-green test or a
  real-entrypoint replay;
- implementation: `/review` reports no P0/P1.

Anything else is **not proven**; name the one piece of evidence that would flip it. Drop any
counterargument without file:line or command output. Never block on preference.

## Severity

- **P1**: a test green on broken behavior; a claim the code or docs contradict; a phantom
  API; an unexplained behavior change or weakened guard; an anti-pattern in a copyable place.
- **P2**: an unverified but plausible claim; a leaf anti-pattern; a tautological assertion
  beside real ones.
- **P3**: summary only.

Report at most five findings, merge-deciding first.

## Output

Always lead with one verdict line:

`lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence, at most 20 words>`

`truthful`: no findings. `suspect`: P2 only. `lying`: any P1. Then
`[P1|P2|P3] <file:line> <section> -- <lie and proof>; <smallest fix>`. A clean pass is only
the verdict line.
