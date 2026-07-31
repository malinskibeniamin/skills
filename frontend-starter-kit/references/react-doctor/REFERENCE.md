# React Doctor reference

## Released contract

The pinned npm release is `react-doctor@0.9.2`. Its released registry contains
781 rules: 776 active and 5 retired. All 112 design-tagged rules are opt-in.
Use the tagged registry rather than the live rules website when changing the
pin because the website can include unreleased rules.

Primary references:

- [0.9.2 release](https://github.com/millionco/react-doctor/releases/tag/react-doctor%400.9.2)
- [0.9.2 rule registry](https://github.com/millionco/react-doctor/blob/react-doctor%400.9.2/packages/oxlint-plugin-react-doctor/src/plugin/rule-registry.ts)
- [configuration](https://www.react.doctor/docs/configuration/config-files)
- [CLI](https://www.react.doctor/docs/reference/cli-reference)

React Doctor runs on its bundled oxlint engine. That is an implementation
detail, not a second project linter: Biome/Ultracite remains the lint and format
owner.

## Rule activation and diagnostic surfaces

An opt-in rule runs only when its full `react-doctor/<rule>` key appears in
`rules`. Category severity changes already-enabled rules; it does not activate
opt-in rules.

Design diagnostics are excluded from `prComment`, `score`, and `ciFailure`
surfaces by default. The config restores the complete `design` tag to all three
surfaces and explicitly activates every design rule.

[`doctor.config.json`](doctor.config.json) is the executable ownership map:

| Policy | Count | Behavior |
|---|---:|---|
| Applicable catalog rules | 728 | Enabled; warnings and errors both fail changed scope |
| React Native rules | 42 | Excluded by tag because this is a browser starter |
| Explicit conflicts / terminal opt-ins | 11 | Off; owned elsewhere or inapplicable |
| Total registry | 781 | Pinned 0.9.2 catalog |

The explicit rule map contains 183 entries: 42 errors, 130 warnings, and 11
off. All 112 design rules are active; the versioned
[`design-rules-0.9.2.txt`](design-rules-0.9.2.txt) inventory makes omissions
testable. `blocking: "warning"` turns both configured severities into a strict
changed-scope gate.

The 11 exclusions are intentional:

- Biome owns exhaustive dependencies and nested-component definitions.
- Automatic JSX runtime makes `react-in-jsx-scope` invalid.
- Tailwind component props, React Hook Form prop spreading, and encapsulated
  hook handlers conflict with three style opt-ins.
- Escaping every apostrophe creates noisy JSX without changing rendered text.
- Three Ink-only opt-ins do not apply to browser applications.

All other released defaults and browser-app opt-ins remain active. Re-audit the
inventory, exclusions, and tag counts on every pinned version bump.

`respectInlineDisables: false` prevents source comments from hiding findings.
For a proven false positive or required platform exception, add the narrowest
file-scoped `ignore.overrides` entry with a rationale in the project copy of
the config.

`deadCode: true` applies to the advisory full-project scan
(`bun run doctor:full`). React Doctor skips reachability analysis for changed
scope because unused-file and unused-export results require the full graph.

## Transferred hook ownership

Do not restore these regex checks after their React Doctor fixture passes:

| Former hook rule | React Doctor rule |
|---|---|
| React Compiler manual memoization | `react-doctor/react-compiler-no-manual-memoization` |
| Derived/reset state effects | `react-doctor/no-derived-state-effect`, `react-doctor/no-derived-useState`, `react-doctor/no-reset-all-state-on-prop-change`, `react-doctor/no-adjust-state-on-prop-change` |
| Ref initializer rerenders | `react-doctor/rerender-lazy-ref-init` |
| Effect fetching/chains/prop mirroring | `react-doctor/no-fetch-in-effect`, `react-doctor/no-effect-chain`, `react-doctor/no-mirror-prop-effect` |
| Outline removal / disabled zoom | `react-doctor/no-outline-none`, `react-doctor/no-disabled-zoom` |
| Dialog name / nested interactive / redundant alt / placeholder label | `react-doctor/dialog-has-accessible-name`, `react-doctor/html-no-nested-interactive`, `react-doctor/img-redundant-alt`, `react-doctor/label-has-associated-control` |
| `aria-invalid` without an error description | `react-doctor/no-aria-invalid-without-description` |
| Dangerous React HTML sink | `react-doctor/no-danger` |
| Class components | `react-doctor/prefer-function-component` |
| `cloneElement` | `react-doctor/no-clone-element` |
| Query stable client / rest destructuring / whole-result spread / void query function | `react-doctor/query-stable-query-client`, `react-doctor/query-no-rest-destructuring`, `react-doctor/query-destructure-result`, `react-doctor/query-no-void-query-fn` |

Biome/Ultracite still owns exhaustive hook dependencies and nested component
definitions. Those React Doctor rules are explicitly off.

Keep shell hooks for project conventions, CSS-only checks, cross-file domain
rules, generated-file policy, and fail-closed orchestration. Transfer another
check only when a positive fixture, negative fixture, changed-scope fixture,
and untracked-file fixture prove equivalent behavior.

## Stop hook

> Script: [`scripts/react-doctor-stop.sh`](scripts/react-doctor-stop.sh)

The hook first checks whether this session changed a React source file, then
invokes:

```bash
bun run doctor -- --scope changed --include-untracked --blocking warning --no-score
```

The React Doctor exit code owns diagnostic blocking. The wrapper only handles
project applicability and converts any non-zero result—including configuration
or tool failures—into a Stop finding.

There is deliberately no score parser or score ratchet. `--score` emits only a
number, hiding the rule diagnostics that must own the gate. A score from one
changed-file set is also not a stable baseline for another.

## CLI flags

| Flag | Purpose |
|---|---|
| `--scope changed` | Report diagnostics introduced relative to the detected base |
| `--include-untracked` | Include new React source files |
| `--blocking warning` | Exit non-zero when a warning or error reaches `ciFailure` |
| `--no-score` | Skip score upload and keep diagnostic output available |
| `--verbose` | Show file-level details during a manual investigation |
| `design` | Run the focused opt-in design review |

`--diff` is a deprecated alias. Do not add it back.
