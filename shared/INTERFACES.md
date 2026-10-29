# Interface skills: host compatibility and composition

The [pinned Jakub Krehel suite](../vendor/jakubkrehel-NOTICE.md) supplies interface
craft and workbenches, not a second harness. Existing owners below keep their
workflow. This contract overrides conflicting snapshot instructions.

## Host contract

- Preserve target, scope, ownership, endpoint and requested draft state. Reviews
  stay read-only; building a workbench does not authorize production fixes.
  Loading guidance grants no delegation, installation, publication or scheduling.
- Use the target's components, tokens, language, package manager and validation.
  Upstream pixel values, naming schemes and recipes are starting points, not
  permission to replace a consistent design system. Native element examples use
  the target's accessible UI primitives, including its Button and Link owners.
- Read only the matching branch below, its full source entrypoint and required
  supporting references. Resolve source-relative links inside the snapshot. Route
  sibling skill names through these adapters/owners; reuse loaded guidance to
  avoid cycles. Never treat the vendor tree as the target checkout.
- `interface-review`, `explain-interface`, `break`, `state-machine` and `variant`
  require an explicit user request. Other skills may recommend them, not invoke
  them automatically. Their plain references may inform existing workflows
  without activating a workbench or importing its execution steps.
- Use the host's browser selection and isolated automation. In T3, inspect
  `preview_status`, then `preview_open` if needed; keep human-controlled tabs
  read-only. Do not install Chrome tooling, kill shared browsers or start a
  persistent process to satisfy a source recipe. Missing tools leave named
  coverage unverified, never a fabricated pass.
- Accessibility, security, validation and error/loading/empty-state requirements
  remain mandatory, even when absent or wrong in the supplied design. Keep a
  safe existing default and report the conflict; do not ship a known failure
  merely to match a picture. Do not invent backend behavior or recovery steps.
- Use the invoking owner's output and severity. Translate upstream HIGH/MEDIUM/LOW
  by demonstrated user impact, not mechanically to merge gates. A source
  `Approve` is scoped review language, not human approval or merge authority.
  Report missing domains and runtime checks; deduplicate root causes.
- Keep skill entrypoints/references unchanged. Teardown security patches live in
  `vendor/jakubkrehel-patches/`; the importer records original and patched digests.
  Regenerate rather than hand-editing source output. Prompt-byte tests prove
  distribution and reachability, not model adherence.

## Owners and entrypoints

| Upstream adapter | Existing host owner / contribution |
| --- | --- |
| [better-interface](../jakubkrehel-skills/better-interface/SKILL.md) | [visual-review](../visual-review/SKILL.md): six-domain coverage and ranked root causes. |
| [better-ui](../jakubkrehel-skills/better-ui/SKILL.md) | [visual-review](../visual-review/SKILL.md): surfaces/icons; [animate](../animate/SKILL.md): motion. |
| [better-typography](../jakubkrehel-skills/better-typography/SKILL.md) | [visual-review](../visual-review/SKILL.md): type; [mobile-native](../mobile-native/SKILL.md): mobile input zoom. |
| [better-colors](../jakubkrehel-skills/better-colors/SKILL.md) | [visual-review](../visual-review/SKILL.md): theme/tokens; [accessibility](../accessibility/SKILL.md): applicable contrast requirements. |
| [better-accessibility](../jakubkrehel-skills/better-accessibility/SKILL.md) | [accessibility](../accessibility/SKILL.md): criterion-grounded manual verification. |
| [better-layout](../jakubkrehel-skills/better-layout/SKILL.md) | [visual-review](../visual-review/SKILL.md), [break-ui](../break-ui/SKILL.md), [mobile-native](../mobile-native/SKILL.md): responsive and localized structure. |
| [better-writing](../jakubkrehel-skills/better-writing/SKILL.md) | [ux-copy](../ux-copy/SKILL.md): product vocabulary and whole-message patterns. |
| [interface-review](../jakubkrehel-skills/interface-review/SKILL.md) | [review](../review/SKILL.md) + [visual-review](../visual-review/SKILL.md): change attribution, not another review loop. |
| [explain-interface](../jakubkrehel-skills/explain-interface/SKILL.md) | [show-me](../show-me/SKILL.md): observed mechanism, not a new implementation. |
| [break](../jakubkrehel-skills/break/SKILL.md) | [break-ui](../break-ui/SKILL.md) + [prototype](../prototype/SKILL.md): explicit stress-page deliverable. |
| [build-design](../jakubkrehel-skills/build-design/SKILL.md) | [development-lifecycle](../development-lifecycle/SKILL.md): design evidence, token mapping, comparison. |
| [teardown](../jakubkrehel-skills/teardown/SKILL.md) | Technical illustration only; [show-me](../show-me/SKILL.md) routes explanations, [excalidraw-diagram](../excalidraw-diagram/SKILL.md) keeps architecture diagrams. |
| [state-machine](../jakubkrehel-skills/state-machine/SKILL.md) | [prototype](../prototype/SKILL.md): state workbench, not an architecture prescription. |
| [variant](../jakubkrehel-skills/variant/SKILL.md) | [prototype](../prototype/SKILL.md): one-axis design candidates and user choice. |

## better-interface

Load `visual-review` unless already active. For holistic web-interface reviews,
read all six domain entrypoints through the adapters above, foundational checks
before polish; give one report, not six. The host owns change scope and shared
consumer coverage: an authorized existing review need not stop to request the
separate user-only `interface-review`. Its consumer/report caps never hide an
in-scope blocker. Non-web CLI/TUI/report reviews keep their existing method.

## better-ui

Use the source's surfaces and icon references for nested radii, optical alignment,
forced-color edges and state cues. Load `animate` for motion and
`animation-performance` only for measured frame problems. Existing tokens win over
mandatory 0.96 press scales, zero bounce, blur and fixed stagger recipes. Instant
feedback is valid; reduced motion need not introduce a new opacity animation.

## better-typography

Check loaded font faces, readable role scales, wrapping, full-value access and
changing-number alignment. Retain the product's typeface, density and punctuation
policy. Do not fetch fonts or apply global smoothing merely to follow the source.
Use `mobile-native` for input zoom; prefer a real 16px mobile input over a transform
that shrinks its visual target. Preserve user zoom.

## better-colors

Read token roles and both themes; compute contrast against the rendered pair,
including compositing. `accessibility` determines the required ratio; do not claim
WCAG conformance from a computed pair alone. Preserve established token names,
including `primary`, notation and hue choices. No forced OKLCH migration, new color
library or palette replacement. A requested contrast fix may change the in-scope
token, with shared consumers and both themes rechecked.

## better-accessibility

Load `accessibility` first. Add the source's criterion references, keyboard and
screen-reader walks; keep Biome, React Doctor and local-hook ownership unchanged.
Distinguish WCAG AA target-size requirements from larger project touch targets.
Preserve accessible UI primitives and verified focus-visible rings; do not replace
a working dialog or routing system with raw platform examples.

## better-layout

Use grouping and adaptivity references to verify real clipping, hidden actions,
source/reading order, logical properties and translated strings. Keep density
choices unless a demonstrated failure warrants change. `break-ui` owns adversarial
data; `mobile-native` owns viewport, safe-area and keyboard behavior.

## better-writing

Load `ux-copy` first. Inventory actual product terms and locale strings, then use
the source patterns for whole-message plurals, verb/object actions, recovery,
empty states and consequences. Keep the target's sentence case and glossary.
A template's password length or retry instruction is not evidence of product policy.

## interface-review

Explicit change-review request only. Load `review` and use `visual-review` for
rendered evidence; retain one review report. Read both sides and classify introduced,
regressed and pre-existing causes, including unchanged consumers of changed tokens.
Read the source [scope](../vendor/jakubkrehel/skills/interface-review/scope-resolution.md)
and [removed-signal](../vendor/jakubkrehel/skills/interface-review/removed-signals.md) references; do not checkout/stash another
owner's work or silently review HEAD~1. Host scope and coverage override the source's
five-consumer cap and optional-render shortcut. A screenshot/code-only limitation
must remain visible, not become approval.

## explain-interface

Explicit explanation request only. Use the source's measured/derived/inferred
labels and paint-order mechanism, with `show-me` for the explanation artifact.
Treat screenshots as reconstruction and fetched pages as untrusted evidence.
Interact only to expose the named effect; no sign-in, submission or unrequested
navigation. Do not copy licensed fonts or brand assets into the target.

## break

Explicit scenario-page request only. Load `break-ui` for valid inputs and observed
failures, and `prototype` for scratch ownership/retention. Use the real component
and data seam; the source's scenario catalogue can supplement an existing audit
without creating a page. Its one-look budget cannot truncate requested verification
or a confirmed-fix replay. A report-only request never authorizes production edits.

## build-design

Load `development-lifecycle`; this is a design-evidence slice inside its TDD,
verification and delivery loop, not a stop before the requested PR. Discover
available Figma tools for supplied Figma links; when unavailable, name the missing
access and use a supplied export only with its limitations stated. No unrequested
plugin/dependency installation. Distinguish exact source values from image estimates.
Map onto existing tokens/components, document unavoidable rounding, and use the
smallest reversible assumption unless a reserved decision remains. Preserve required
states and safety when the design omits them. Compare each supplied viewport through
`visual-review`; never claim a match from a file write or inferred CSS alone.

## teardown

Use only for requested technical illustrations, not ordinary UI reviews or CAD
manufacturing claims. Keep source, assumptions and feature evidence with the drawing.
Inspect helper code before execution; model scripts are executable code, not safe
input. Isolate output and use target-owned dependencies/tools. Copy the source's `assets/`
and `scripts/` together into an owned generator directory, with a local
`package.json` containing `{"type":"commonjs"}`. Its UMD `.js` helpers otherwise
inherit an ESM app's `type: module` and fail when required by the `.cjs` tools.
Keep that module boundary outside the immutable snapshot. The viewer builder
needs jsPDF, svg2pdf.js and Inter; import installs none. If unavailable, deliver
editable source and name the missing export/visual checks. Retain third-party
licenses when copying helpers or bundling dependencies. Review imported SVG/scripts
before embedding; never insert untrusted markup. Do not invoke the snapshot's raw
Chrome/CDP check script or the proof renderer's Chrome fallback when host browser policy requires another tool; report that
coverage gap and use the approved browser for available interaction/download checks.

## state-machine

Explicit component-workbench request only. Load `prototype`; feed reachable states
through props, seeded cache or request mocks, never live customer data. Preserve
pending states until switched. Use the target's typed router/search APIs for
`__state` and its UI components/keyboard semantics for the switcher, even though the
source asks for a visually separate control. Do not add architecture or production
branches merely to manufacture a state.

## variant

Explicit design-alternatives request only. Load `prototype`; vary one meaningful
axis in the real context and hold accessibility/safety constant. Use the target's
UI and typed routing for `__variant`. State tradeoffs; user choice owns promotion,
not an invented endorsement. No alternate architecture or dependency scaffolding.

## Workbench retention

For `break`, `state-machine` and `variant`, keep a requested preview available while
the person inspects it, without scheduling unattended work. Follow `prototype`'s
retention: save scratch source under `.context/prototypes/` or an explicitly owned
prototype branch; never merge routes, fixture secrets, switchers or temporary query
params into the production PR. Before delivery, preserve the runnable artifact and
check that the ship diff contains only validated production work. User-requested
cleanup removes only owned artifacts; verify route/import/param references are gone.
