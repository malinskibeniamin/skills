# Anti-slop adoption review

**Date:** 2026-09-02
**Decision:** adopt a three-rule opt-in profile for repositories that already use
Oxlint. Do not adopt the full preset, install a second canonical linter, or add an
installer skill yet.

## Recommendation

Anti-slop's central idea is right: recurring low-evidence patterns should become
executable constraints instead of prompt prose. Its full preset is deliberately a
maintainer's taste, however, not a universal TypeScript standard. Upstream explicitly
expects teams to vendor and adapt it.

Use this narrow profile:

```json
{
  "anti-slop/no-chained-type-assertions": "error",
  "anti-slop/no-unknown-type-aliases": "error",
  "anti-slop/no-widen-then-assert": "error"
}
```

These rules target type-evidence laundering rather than ordinary TypeScript
narrowing, boundary types, naming, or test architecture. The profile should include
tests: a double assertion can make a test pass against an impossible value just as
easily as it can hide a production defect.

A dedicated rerun with only this profile produced 15 diagnostics in 11 files: 14 in
Protoform and one in Querylane.

This is an **Oxlint-native opt-in**, not a change to `stack:2026`. Biome/Ultracite
remains the project linter and formatter; React Doctor's bundled Oxlint engine remains
an implementation detail. The existing harness decision explicitly avoids a second
standalone linter. See the [stack registry](../stack-registry/SKILL.md),
[React Doctor ownership map](../frontend-starter-kit/references/react-doctor/REFERENCE.md),
and [settled lint decision](this-week-in-react-skills-harness-opportunities-2026-07-07.md#2-modernize-react-compiler-setup-around-rustlint-first-integrations).

## Upstream reassessment

The current upstream is materially stronger than the version first reviewed on
2026-08-18. This review pinned
[`anti-slop` v0.1.2 at `e8c4880`](https://github.com/dmmulroy/anti-slop/tree/e8c4880471b23ab7f216fba7b27d173a6ef07d4c).
Between v0.1.0 and v0.1.2, upstream added or refined third-party member handling,
type-guard conventions, finite-key records, existence probes, generic constraints,
alias resolution, safety-comment validation, and missing rule tests. The current
README also documents the rules' lexical, non-type-aware analysis boundary.
See the [v0.1.0...v0.1.2 comparison](https://github.com/dmmulroy/anti-slop/compare/v0.1.0...v0.1.2)
and [pinned rule documentation](https://github.com/dmmulroy/anti-slop/blob/e8c4880471b23ab7f216fba7b27d173a6ef07d4c/README.md#rules).

The pinned upstream passed:

- Oxlint over `src/`;
- every generic and Effect `RuleTester` suite;
- TypeScript typechecking;
- bundled skill/source drift verification.

The earlier concern that three shipped rules lacked tests is therefore obsolete.

## Shadow-audit method

The audit used two public, independently structured TypeScript corpora:

- frontend-library surface: Protoform's shipped `base-nova` registry at
  [`9634f94`](https://github.com/malinskibeniamin/protoform/tree/9634f9424126e5f73ddc5163d5b90bd7dd644c8e/registry/base-nova/protoform);
- mixed application/tooling surface: Querylane at
  [`1f12ee4`](https://github.com/querylane/querylane/tree/1f12ee40138293bec4c04fdbbdeef07e2c59219a).

All 15 generic v0.1.2 rules ran at `error` with their default options. Generated,
dependency, build, and coverage paths were excluded. The target repositories were
fresh clones; no dependency, configuration, or source changes were made in them.
Oxlint reported 359 files for Protoform and 770 for Querylane.

Diagnostics were classified by path:

- **Product:** application or library source;
- **Test:** tests, fixtures, mocks, and end-to-end code;
- **Tooling:** scripts, examples, docs tooling, and build/test configuration.

Counts are policy matches, not confirmed defects. Representative sites were read for
every triggered rule before assigning the disposition below.

## Results

The full preset produced **2,117 diagnostics across 1,129 linted files**: 1,500 in
product code, 560 in tests, and 57 in tooling.

| Rule | Protoform | Querylane | Product | Test | Tooling | Disposition |
|---|---:|---:|---:|---:|---:|---|
| `no-chained-type-assertions` | 14 | 1 | 11 | 4 | 0 | **Core error** |
| `no-conditional-empty-object-spread` | 21 | 49 | 57 | 11 | 2 | Off |
| `no-known-value-widening` | 90 | 63 | 129 | 22 | 2 | Research candidate |
| `no-module-mocking` | 0 | 51 | 0 | 51 | 0 | Replace with scoped policy |
| `no-object-parameters` | 7 | 3 | 7 | 3 | 0 | Off |
| `no-reflect-apply` | 3 | 1 | 3 | 1 | 0 | Off |
| `no-reflect-get` | 24 | 5 | 25 | 2 | 2 | Off |
| `no-runtime-typeof` | 239 | 115 | 294 | 38 | 22 | Off |
| `no-shape-in-symbol-names` | 95 | 135 | 203 | 27 | 0 | Off |
| `no-unknown-parameters` | 140 | 128 | 229 | 32 | 7 | Off |
| `no-unknown-returns` | 28 | 59 | 63 | 23 | 1 | Off |
| `no-unknown-type-aliases` | 0 | 0 | 0 | 0 | 0 | **Core error** |
| `no-unsafe-dictionary-type` | 198 | 60 | 182 | 68 | 8 | Off |
| `no-widen-then-assert` | 0 | 0 | 0 | 0 | 0 | **Core error** |
| `require-safety-comment-for-type-assertion` | 327 | 261 | 297 | 278 | 13 | Off |

### Why the core survives

`no-chained-type-assertions` found only 15 sites, and each exposed a real evidence
gap. Examples included casting a created Protobuf message through `unknown` into its
form representation and coercing a keyboard event through `unknown` into a mouse
event. Those may be necessary compatibility seams today, but the double assertion
does not prove the invariant. The rule makes the seam explicit rather than silently
normalizing it. See the
[Protoform conversion](https://github.com/malinskibeniamin/protoform/blob/9634f9424126e5f73ddc5163d5b90bd7dd644c8e/registry/base-nova/protoform/hooks/use-proto-form/use-proto-form.ts#L345-L350).

The other two core rules had no matches. That is expected for preventive rules aimed
at narrow laundering patterns, not a reason to manufacture migrations. Upstream's
tests provide positive and negative fixtures, and an independent 568k-line adoption
report also adopted both rules alongside `no-chained-type-assertions`.
See [the independent adoption report](https://github.com/dmmulroy/anti-slop/issues/21).

### Why the rest stays out

- **Conditional empty spreads:** the 70 matches generally expressed exact omission
  compactly. Rewriting a clear object builder into mutation would add surface without
  establishing more type evidence. See a
  [Protoform configuration object](https://github.com/malinskibeniamin/protoform/blob/9634f9424126e5f73ddc5163d5b90bd7dd644c8e/registry/base-nova/protoform/components/auto-form/auto-form-core.tsx#L755-L764).
- **Known-value widening:** several findings were useful `satisfies` prompts, but
  others intentionally exposed an open dictionary or public return contract. For
  example, Protoform's renderer map accepts runtime field-type lookup; preserving only
  its literal keys would change its useful contract. See
  [`BUILT_IN_RENDERER_TYPES`](https://github.com/malinskibeniamin/protoform/blob/9634f9424126e5f73ddc5163d5b90bd7dd644c8e/registry/base-nova/protoform/components/auto-form/configuration.ts#L44-L50).
  Keep this as an audit prompt until a type-aware rule can separate intentional owner
  contracts from accidental widening.
- **Module mocking:** all 51 matches were tests. Some mocked external framework
  boundaries, such as TanStack Router; others indicate internal seams worth redesigning.
  A blanket syntactic ban cannot distinguish them. Preserve the existing policy:
  external boundaries may be mocked, owned modules should use real seams. See
  [the example](https://github.com/querylane/querylane/blob/1f12ee40138293bec4c04fdbbdeef07e2c59219a/frontend/src/components/admin-shell.browser.test.tsx#L60-L69)
  and [local mocking guidance](../tdd/mocking.md).
- **`object` and reflection:** `object` is sometimes the exact contract, including a
  key entering a `WeakMap`. Reflection also appeared in compatibility adapters and
  tests intentionally reaching invalid runtime states. See
  [`layoutIdentityKey`](https://github.com/querylane/querylane/blob/1f12ee40138293bec4c04fdbbdeef07e2c59219a/frontend/src/features/database-visualization/flow-canvas.tsx#L183-L192)
  and the
  [invalid export-format test](https://github.com/querylane/querylane/blob/1f12ee40138293bec4c04fdbbdeef07e2c59219a/frontend/src/features/data-explorer/table-data/selection-formatters.unit.test.ts#L452-L458).
- **Runtime `typeof`:** the default rule produced 354 matches. Enabling its
  `allowInTypeGuards` option still left 287. Many defaults were ordinary, useful type
  predicates, including filtering a library error union to strings. TypeScript treats
  `typeof` checks as a standard narrowing construct; parsing every already-typed union
  through a schema would be ceremony. See the
  [Protoform predicate](https://github.com/malinskibeniamin/protoform/blob/9634f9424126e5f73ddc5163d5b90bd7dd644c8e/registry/base-nova/protoform/components/auto-form/adapters/react-hook-form-v8.tsx#L34-L39)
  and [TypeScript narrowing documentation](https://www.typescriptlang.org/docs/handbook/2/narrowing.html#typeof-type-guards).
- **`shape` naming:** the rule flagged an imported Protobuf type named
  `MessageShape` and domain language such as SQL query shape. Renaming or aliasing
  precise upstream/domain terminology reduces clarity. See the
  [Protobuf import](https://github.com/malinskibeniamin/protoform/blob/9634f9424126e5f73ddc5163d5b90bd7dd644c8e/registry/base-nova/protoform/components/auto-form/proto/conversion.ts#L1-L5)
  and [query-shape model](https://github.com/querylane/querylane/blob/1f12ee40138293bec4c04fdbbdeef07e2c59219a/frontend/src/features/data-explorer/explorer-view-detail-model.ts#L97-L106).
- **Blanket `unknown` bans:** dynamic form values, caught errors, JSON payloads, and
  ignored async callback results legitimately use `unknown` to preserve safety before
  narrowing. Examples include Protoform's
  [`FormValues`](https://github.com/malinskibeniamin/protoform/blob/9634f9424126e5f73ddc5163d5b90bd7dd644c8e/registry/base-nova/protoform/components/auto-form-react-hook-form-v8/index.tsx#L10-L18)
  and Querylane's
  [retry callback](https://github.com/querylane/querylane/blob/1f12ee40138293bec4c04fdbbdeef07e2c59219a/frontend/src/components/admin-ops/admin-section-error.tsx#L12-L20).
  TypeScript defines `unknown` as the type-safe top type: consumers must narrow it
  before use. See the
  [TypeScript 3.0 `unknown` specification](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-0.html#new-unknown-top-type).
- **Safety comments:** 588 findings would create a large comment migration and reward
  agents for satisfying syntax with plausible prose. Assertions need removal,
  boundary validation, or a focused review of the specific invariant—not a mandatory
  comment on every occurrence.

## Proposed opt-in profile contract

- **Name:** `anti-slop-core`
- **Trigger:** explicit user request in a repository that already uses Oxlint.
- **Source:** vendor the audited rules; record the upstream commit and local deviations.
- **Rules:** enable only the three core rules above at `error`.
- **Scope:** run the first audit read-only; gate changed JavaScript/TypeScript files after
  adoption instead of demanding a repository-wide cleanup.
- **Findings:** fix evidence laundering in the current change. For an established
  compatibility seam, introduce the narrowest typed adapter or document a file-scoped
  override with its owner and removal condition.
- **Ineligible repository:** if Oxlint is absent, do not install it solely for this
  profile. Preserve the repository's lint owner and report the three invariants for its
  existing enforcement layer.
- **Graduation:** create an installer skill only after the profile passes an Oxlint-native
  repository fixture and an eval proving that non-Oxlint repositories remain unchanged.

This keeps one lint owner, makes the valuable invariant mechanical where the platform
already exists, and avoids inheriting twelve project-specific taste rules.
