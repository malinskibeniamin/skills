---
name: lie-detector
description: "Catch what a change claims but does not do: hallucinated APIs or claims, code that fakes success, tests that cannot fail, unrequested changes, copyable anti-patterns. Use on every PR."
---

Treat the change as unproven. Steelman "this should not merge", then let the diff refute it
with evidence. Runs standalone or inline as the **lie-detector hat** in `/review` on
every diff; weight customer-facing surfaces (UI, copy, CLI output, public API, report)
highest. Code defects stay in `/review`; value stays in `/jb`. Work on a committed tree
with `BASE` set to the merge base.

## 1. Claims without evidence

List every claim in the PR title, body, commits, code comments, docs, and agent summary.
Each needs a diff line, command output, or primary doc:

- Phantom surface: an imported symbol, prop, hook, CLI flag, config key, env var, design
  token, route, or option that does not exist at the installed version. Check lockfile,
  `node_modules` types, or primary docs, not memory.
- "Tested", "verified", "fixes X", "no behavior change": needs the command and output or a
  red-then-green pair.
- A cited file:line, issue, or doc that does not say what the claim says.

## 2. Code that pretends

Trace each changed path to what the user or caller actually gets. Flag code that reports
work it did not do:

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

1. Break the behavior it claims to protect: `git diff "$BASE" -- <src> | git apply -R`,
   invert the changed condition, drop the rendered element, or change the value the user
   sees (copy, count, state); wiring-only breaks miss tautologies. Run the test, then
   `git checkout HEAD -- <src>`. Still green: the test lies. Count red only from an
   assertion, not an import, compile, or setup error. Record the command and failure.
2. Check survivors against the [test-audit junk patterns](../test-audit/SKILL.md#junk-patterns).
3. A behavior change with no test that went red and no real-entrypoint replay (`/dogfood`)
   is unproven.

## 4. Changes nobody asked for

Compare every hunk with the stated scope. Flag each unexplained hunk that changes observable
behavior or weakens a guard: deleted, skipped, or loosened tests; regenerated snapshots;
`@ts-ignore` or lint suppressions; changed defaults, copy, routes, flags, error handling,
retries, or timeouts; lockfile or config churn; hand-edited generated files; a visual change
with no screenshot.

## 5. Patterns that will spread

People and agents copy the nearest example. For each idiom the diff introduces, find
precedent with `rg` and compare with root and scoped `CLAUDE.md`/`AGENTS.md`, `exemplars/`,
and the stack registry. Contradicting a documented rule or the dominant idiom is a finding;
severity follows copy reach: a shared component, hook, fixture, test helper, template,
generator, exemplar, or skill is P1; leaf code is P2. Fix at the source: use the sanctioned
pattern, or update the rule in the same PR and say why. Two live styles is the defect.

## 6. Steelman gate

Follow [steelman/SKILL.md](../steelman/SKILL.md) on the premise "this PR should merge".
Argue the strongest case against it from the [jb](../jb/SKILL.md) verdict, the findings
above, and `/review` findings. **Merge-ready** only when all three hold:

- value: the `jb:` verdict is `justified`;
- truth: no P1 here, and every changed behavior has a red-then-green test or a
  real-entrypoint replay;
- implementation: `/review` reports no P0/P1.

Anything else is **not proven**; name the one piece of evidence that would flip it. Drop any
counterargument without file:line or command output. Never block on preference.

## Severity

- **P1**: a claim the code or docs contradict; a phantom API; code that reports success it
  did not achieve; a test green on broken behavior; an unexplained behavior change or
  weakened guard; an anti-pattern in a copyable place.
- **P2**: an unverified but plausible claim; a misleading name or comment; a leaf
  anti-pattern; a tautological assertion beside real ones.
- **P3**: summary only.

Report at most five findings, merge-deciding first.

## Output

Always lead with one verdict line:

`lie-detector: <truthful|suspect|lying> -- merge <ready|not proven> -- <evidence, at most 20 words>`

`truthful`: no findings. `suspect`: P2 only. `lying`: any P1. Then
`[P1|P2|P3] <file:line> <section> -- <lie and proof>; <smallest fix>`. A clean pass is only the verdict line.
