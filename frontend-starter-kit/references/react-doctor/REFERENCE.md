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
surfaces by default. Every blocking design rule therefore needs both:

1. `"react-doctor/<rule>": "error"` under `rules`
2. its full key under `surfaces.ciFailure.includeRules`

[`doctor.config.json`](doctor.config.json) is the executable ownership map:

| Disposition | Count | Behavior |
|---|---:|---|
| Blocking design | 24 | Explicit errors included in `ciFailure` |
| Advisory design | 50 | Explicit warnings visible in general CLI scans |
| Focused review | 30 | Left opt-in; run with `react-doctor design` |
| Disabled taste rules | 8 | Explicitly off because they are brand decisions |

Blocking rules cover deterministic accessibility, interaction, layout, motion,
and runtime hazards. Advisory rules are local, actionable smells with credible
exceptions. Focused-review rules judge page composition or repeated visual
motifs, so running them on every Stop would create noise. Disabled rules ban
valid brand choices rather than defects.

The config names every blocking, advisory, and disabled rule. These are the 30
remaining design rules reserved for focused review:

- `react-doctor/no-cramped-container-padding`
- `react-doctor/no-dark-mode-glow`
- `react-doctor/no-decorative-blur-orb`
- `react-doctor/no-decorative-grid-background`
- `react-doctor/no-decorative-radial-spotlight`
- `react-doctor/no-default-purple-page-gradient`
- `react-doctor/no-emoji-heading-decoration`
- `react-doctor/no-excessive-card-surfaces`
- `react-doctor/no-excessive-centered-copy`
- `react-doctor/no-excessive-pill-treatment`
- `react-doctor/no-fake-browser-chrome`
- `react-doctor/no-flat-page-type-scale`
- `react-doctor/no-full-viewport-centered-hero`
- `react-doctor/no-generic-purple-blue-icon-gradient`
- `react-doctor/no-hero-eyebrow-chip`
- `react-doctor/no-icon-tile-heading-stack`
- `react-doctor/no-monotonous-page-spacing`
- `react-doctor/no-numbered-section-markers`
- `react-doctor/no-oversized-long-heading`
- `react-doctor/no-placeholder-persona-copy`
- `react-doctor/no-radial-halo`
- `react-doctor/no-repeated-emoji-tiles`
- `react-doctor/no-repeated-glass-surfaces`
- `react-doctor/no-repeated-hover-scale`
- `react-doctor/no-repeated-section-shells`
- `react-doctor/no-repeating-gradient-decoration`
- `react-doctor/no-tight-display-tracking`
- `react-doctor/no-uniform-feature-card-grid`
- `react-doctor/no-uppercase-mono-label`
- `react-doctor/prefer-motion-transform-property`

The other 669 active or retired non-design rules retain the release defaults
unless the config transfers ownership from a harness hook or disables a proven
Biome overlap. Re-audit them on every version bump; do not mirror the entire
upstream default registry into project config.

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
bun run doctor -- --scope changed --include-untracked --blocking error --no-score
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
| `--blocking error` | Exit non-zero when an error reaches `ciFailure` |
| `--no-score` | Skip score upload and keep diagnostic output available |
| `--verbose` | Show file-level details during a manual investigation |
| `design` | Run the focused opt-in design review |

`--diff` is a deprecated alias. Do not add it back.
