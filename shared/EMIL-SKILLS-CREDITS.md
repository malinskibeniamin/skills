# Emil Kowalski skills: selection and provenance

Add six focused web skills from [emilkowalski/skills](https://github.com/emilkowalski/skills),
reviewed at [`2d228630ba1446365f614a108cb8252f1feda202`](https://github.com/emilkowalski/skills/tree/2d228630ba1446365f614a108cb8252f1feda202/skills).
They fill motion implementation, frame diagnosis, terminology, mobile-platform,
data-stress, and toast-library gaps. Consolidate overlapping motion workflows;
preserve existing design/prototype owners. Upstream defaults need adaptation to
our accessibility, runtime, and endpoint contracts rather than wholesale installation.

```text
Distinct web capability -> six canonical skills -> Claude registration + generated Codex proxies
Overlap/stack conflict -> existing owner or defer -> smaller discovery surface
Both paths -> source/license retained -> offline distribution and repository checks
```

## Selection

All rows refer to `skills/<name>/SKILL.md` at the revision above.

| Upstream skill | Decision | Reason/local owner |
|---|---|---|
| `animate` | Add | Purpose-first implementation; also owns scoped motion review, audit, and opportunities |
| `animation-performance` | Add | Frame-driver/rendering diagnosis is narrower than general `ux-performance` |
| `animation-vocabulary` | Add | Reverse lookup of motion terms; answer-only, no implementation |
| `mobile-native` | Add | Mobile **web** viewport/touch/keyboard/PWA behavior, not native development |
| `break-ui` | Add | Explicit schema-backed fixture/layout stress; complements lifecycle `dogfood` |
| `ask-sonner` | Add | Sonner-specific operation, styling, and placement guidance; existing UI wrapper wins |
| `review-animations` | Consolidate | Read-only review mode in `animate`; general visual findings stay with `visual-review` |
| `improve-animations` | Consolidate | Read-only audit/plan mode in `animate`; no executor dispatch or extra approval gate |
| `find-animation-opportunities` | Consolidate | Purpose/frequency gate and rejected candidates in `animate`; no forced additions |
| `emil-design-eng` | Keep existing owner | Its motion/component craft already appears in `visual-review/REFERENCE.md` |
| `apple-design` | Keep existing owner | Continuity, gestures, feedback, and reduced motion overlap `animate`/`visual-review`; avoid another broad taste router |
| `prototype` | Keep ours | Existing `prototype/UI.md` owns variants; upstream cleanup conflicts with retained evidence |
| `pick-ui-library` | Skip | Fixed choices can override the caller's library or registry; use existing primitives and current package evidence |
| `animate-expo` | Defer | Expo/Reanimated is outside this web harness's current stack |
| `write-swift` | Defer | Native Swift requires a separate toolchain/version-aware workflow |

## Adapted files

- `animate/SKILL.md` and `REFERENCE.md`: upstream `animate`, `RECIPES.md`, and the
  review/audit/opportunity entrypoints. Exact timing/curve candidates retained without
  turning every upstream preference into a blocking rule.
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
- Keep pinch zoom through gesture ownership. `dvh` is not a cross-browser keyboard
  guarantee. Physical-device checks remain explicitly unverified when unavailable.

Corrections were checked against [Motion performance](https://motion.dev/docs/performance),
[MDN touch-action](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Properties/touch-action),
and [MDN reduced motion](https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/At-rules/@media/prefers-reduced-motion).
Sonner examples require the installed package's types; optional multi-toaster exports
and callback/return semantics are deliberately not frozen here.

## Refresh and verify

Compare the upstream sources and license at one new reviewed commit. Preserve the
adaptations above, update this pin, and keep each skill's `LICENSE` byte-exact so an
individual installation includes the MIT notice. Reassess deferred/overlapping skills
only if stack or owner boundaries change.

Edit `.claude-plugin/plugin.json` and `scripts/generate-skill-catalog.sh` for discovery;
regenerate rather than editing Codex proxies or router rows manually:

```sh
bash scripts/generate-skill-catalog.sh
bash evals/run.sh emil-vendored-skills
bash evals/run.sh skill-writing-quality
bash evals/run.sh skill-md-hygiene
bash scripts/generate-skill-catalog.sh --check
bun run lint:fix
bun run type:check
```

Each added skill includes the upstream MIT license, copyright 2026 Emil Kowalski,
from [LICENSE at the reviewed revision](https://github.com/emilkowalski/skills/blob/2d228630ba1446365f614a108cb8252f1feda202/LICENSE).
