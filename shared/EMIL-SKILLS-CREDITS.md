# Emil Kowalski skills: selection and provenance

Maintain nine focused web skills from [emilkowalski/skills](https://github.com/emilkowalski/skills),
reviewed at [`5206a950b715e0cabe7043ea0b2304332b91494e`](https://github.com/emilkowalski/skills/tree/5206a950b715e0cabe7043ea0b2304332b91494e/skills).
They fill motion subtraction, auditing, implementation, frame diagnosis, terminology,
mobile-platform, data-stress, toast-library, and direct-manipulation gaps. Consolidate overlapping motion workflows;
preserve existing design/prototype owners. Upstream defaults need adaptation to
our accessibility, runtime, and endpoint contracts rather than wholesale installation.

```text
Distinct web capability -> nine canonical skills -> Claude registration + generated Codex proxies
Overlap/stack conflict -> existing owner or defer -> smaller discovery surface
Both paths -> source/license retained -> offline distribution and repository checks
```

## Selection

All rows refer to `skills/<name>/SKILL.md` at the revision above.

| Upstream skill | Decision | Reason/local owner |
|---|---|---|
| `gestures` | Add | Direct tracking, rubber banding, signed release velocity, momentum, snap points and catch/cancel behavior |
| `choreograph` | Consolidate | Multi-element timing lives in `animate/REFERENCE.md`; no separate choreography router |
| `animate` | Add | Purpose-first implementation; also owns scoped motion review, audit, and opportunities |
| `animation-performance` | Add | Frame-driver/rendering diagnosis is narrower than general `ux-performance` |
| `animation-vocabulary` | Add | Reverse lookup of motion terms; answer-only, no implementation |
| `mobile-native` | Add | Mobile **web** viewport/touch/keyboard/PWA behavior, not native development |
| `break-ui` | Add | Explicit schema-backed fixture/layout stress; complements lifecycle `dogfood` |
| `ask-sonner` | Add | Sonner-specific operation, styling, and placement guidance; existing UI wrapper wins |
| `review-animations` | Consolidate | Read-only review mode in `animate`; general visual findings stay with `visual-review` |
| `improve-animations` | Add | Distinct audit/roadmap entrypoint for retained motion; `animate` owns execution, with no executor dispatch or extra approval gate |
| `remove-animations` | Add | Subtraction-only cleanup with hidden-state, completion, unmount and focus safeguards |
| `find-animation-opportunities` | Consolidate | Purpose/frequency gate and rejected candidates in `animate`; no forced additions |
| `emil-design-eng` | Keep existing owner | Its motion/component craft already appears in `visual-review/REFERENCE.md` |
| `apple-design` | Keep existing owner | Continuity, gestures, feedback, and reduced motion overlap `animate`/`visual-review`; avoid another broad taste router |
| `prototype` | Keep ours | Existing `prototype/UI.md` owns variants; upstream cleanup conflicts with retained evidence |
| `pick-ui-library` | Skip | Fixed choices can override the caller's library or registry; use existing primitives and current package evidence |
| `animate-expo` | Defer | Expo/Reanimated is outside this web harness's current stack |
| `write-swift` | Defer | Native Swift requires a separate toolchain/version-aware workflow |

## Adapted files

- `gestures/SKILL.md` and `REFERENCE.md`: upstream same-name entrypoint; separate
  tracking from release, retain existing primitives, make velocity units/direction explicit,
  and preserve cancellation, zoom, accessible alternatives and physical-device limits.

- `remove-animations/SKILL.md`: upstream same-name entrypoint; preserve essential
  feedback and lifecycle behavior, with no new motion, dependency changes or invented usage counts.
- `improve-animations/SKILL.md`: upstream same-name entrypoint, `AUDIT.md` and
  `PLAN-TEMPLATE.md`; reuse local craft guidance, inline audits, requested plans only.
- `animate/SKILL.md` and `REFERENCE.md`: upstream `animate`, `RECIPES.md`, and the
  review/opportunity entrypoints; broad audits now have the `improve-animations`
  front door. Upstream `choreograph` and its recipes add Together/Overlap/Sequence/Carry
  relationships, bounded timelines and cancellation-safe sequencing here rather than
  another command. Exact timing/curve candidates retained without turning every upstream
  preference into a blocking rule.
- `animation-performance/SKILL.md`: upstream same-name entrypoint, with measured
  diagnosis and browser/version-dependent acceleration instead of blanket GPU claims.
- `animation-vocabulary/SKILL.md` and `GLOSSARY.md`: upstream same-name entrypoint;
  glossary moved behind the naming-only trigger, technical definitions corrected.
- `mobile-native/SKILL.md` and `PLATFORM.md`: upstream same-name entrypoint, scoped
  to symptoms; preserve zoom, native activation, selection, scroll, and keyboard behavior.
- `break-ui/SKILL.md` and `CATALOG.md`: upstream same-name entrypoint and catalog;
  use real fixtures without forcing production edits, a persistent toggle, or a fix gate.
- `ask-sonner/SKILL.md` and `RECIPES.md`: upstream same-name entrypoint;
  installed types/current docs own the API instead of copying a drifting prop table.

## Compatibility decisions

- Remove readiness greetings and wait-for-a-question rituals. Start the requested work.
- All skills inherit the selected model. No automatic agents, worktrees, background
  processes, installs, source rewrites, or external actions arise from loading guidance.
- Explain/review/audit requests return findings; build/fix follows project TDD,
  verification, commit/push, and explicit stop boundaries. Plans are saved only on request.
- Reuse `@/components/ui/`, Button/Link, tokens, React Compiler, env, and routing owners.
  Fix styling at the source instead of promoting global `!important` overrides.
- Treat frequency/timing/blur thresholds as starting heuristics, not measured facts.
  Reduced motion may remove non-essential animation entirely. Keyboard feedback is
  equivalent, not categorically forbidden. Layout changes retain their flow semantics.
- Hardware acceleration is progressive enhancement; Motion can use WAAPI as well as
  main-thread code. Static analysis cannot prove frame rate or perceived feel.
- Gesture tracking is 1:1 only within bounds; resistance is deliberate beyond them.
  Release can use inertia, a velocity-seeded spring or an interruption-safe CSS transition;
  none automatically makes re-grab continuous. Keep a single release driver. Do not copy
  upstream's universal spring/keyframe bans, automatic Vaul adoption or blanket render-cost claims.
- Choreography preserves intentional flow, semantic controls and immediate activation.
  Motion `sync` already permits concurrent exits/enters; `popLayout` changes flow, not
  just timing. Cancel async continuations, not just animation controls. Avoid ref writes
  during render, inertness-free duplicate views and decorative hover completion gates.
- Keep pinch zoom through gesture ownership. `dvh` is not a cross-browser keyboard
  guarantee. Physical-device checks remain explicitly unverified when unavailable.

Corrections were checked against [Motion performance](https://motion.dev/docs/performance),
[MDN touch-action](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/touch-action),
and [MDN reduced motion](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@media/prefers-reduced-motion).
Gesture/choreography adaptations were also checked against [Motion drag](https://motion.dev/docs/react-drag),
[AnimatePresence modes](https://motion.dev/docs/react-animate-presence), and
[MDN pointer capture](https://developer.mozilla.org/en-US/docs/Web/API/Element/setPointerCapture).
Sonner examples require the installed package's types; optional multi-toaster exports
and callback/return semantics are deliberately not frozen here.

## Native workflow handoffs

`/remove-animations` -> `/improve-animations` -> `/animation-performance`: subtract
first, audit retained motion second, profile remaining frame problems last. The sequence
never promotes an audit into source editing or promises measured gains without traces.

Before the November 1 import, `improve-animations` was consolidated into `animate`
and had no separate removal entrypoint. Upstream's new `remove-animations` and the requested sequence
justifies separate subtraction and roadmap triggers without duplicating the craft owner.

Keep the existing front doors and load only the capability the task needs:

- `/work` and `/review` use [change evidence](change-evidence.md) to reach motion,
  mobile-web symptoms, data/layout stress and Sonner guidance conditionally.
- [Visual review](../visual-review/REFERENCE.md#motion-decision-framework) uses
  `animate` as the motion owner instead of maintaining a second recipe set;
  naming-only questions use `animation-vocabulary`, not an implementation workflow.
- Direct-manipulation changes reach `gestures` through change evidence, visual review,
  UI prototypes, `animate`, `mobile-native` and Sonner diagnosis. `gestures` owns physics;
  mobile guidance owns browser friction, Sonner owns its driver, and `animate` owns choreography.
- [UI prototypes](../prototype/UI.md#2-generate-radically-different-variants) load
  motion, data-stress or mobile guidance only when it helps answer the prototype question.
- [UX profiling](../ux-performance/OPTIMIZATION.md#reduce-react-and-main-thread-work)
  uses `animation-performance` for measured frame problems, retaining its journey metric.

These handoffs do not install Emil's whole stack, replace existing components or grant
editing/delivery permission. The adapted skills remain the source of craft guidance;
the local workflow remains the source of scope, evidence and endpoint rules.

## Refresh and verify

The complete upstream `skills/` tree, README, cheatsheets and MIT license are retained
byte-exact in [`vendor/emil`](../vendor/emil), including deferred and consolidated
skills as reference material, not registered commands.
[`vendor/emil.lock.json`](../vendor/emil.lock.json) records the immutable revision and
SHA-256/mode of every file. This refresh adds upstream `gestures` and `choreograph`
resources plus README entries; all previous source bytes and the license are unchanged.
`gestures` is the ninth registered adaptation; choreography enhances the existing motion
owner. Acceleration and perceived feel still require runtime evidence, not instruction checks.

Refresh explicitly from a separate upstream checkout; nothing fetches on skill invocation:

```sh
git clone https://github.com/emilkowalski/skills.git /tmp/emil-skills-upstream
python3 scripts/vendor-emil.py --source /tmp/emil-skills-upstream --revision <reviewed-full-commit-sha>
python3 scripts/vendor-emil.py --check
```

The importer reads committed Git blobs (not a dirty working tree), preserves resource
bytes/modes, copies the upstream license into all nine host skills, and rejects
snapshot/license drift before overwriting managed state. A same-pin rerun produces no
diff. Review source/license changes first, then reconcile adaptations manually outside
the snapshot; do not execute upstream greetings, delegation, worktree, forced feedback,
or automatic plan-writing instructions. Preserve the compatibility decisions above.
Reassess deferred/overlapping skills only if stack or owner boundaries change.

Edit `.claude-plugin/plugin.json` and `scripts/generate-skill-catalog.sh` for discovery;
regenerate rather than editing Codex proxies or router rows manually:

```sh
bash scripts/generate-skill-catalog.sh
bash evals/run.sh emil-vendored-skills
bash evals/run.sh emil-workflow-routing
bash evals/run.sh skill-writing-quality
bash evals/run.sh skill-md-hygiene
bash scripts/generate-skill-catalog.sh --check
bun run lint:fix
bun run type:check
```

Each adapted skill includes the upstream MIT license, copyright 2026 Emil Kowalski,
from [LICENSE at the reviewed revision](https://github.com/emilkowalski/skills/blob/5206a950b715e0cabe7043ea0b2304332b91494e/LICENSE).
