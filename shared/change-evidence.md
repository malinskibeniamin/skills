# Change evidence routing

Authoring and review select capabilities from the changed behavior, not file extensions or
how many skills the user named. Load only applicable owners through
[skill mechanics](../writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
Review collects and evaluates evidence without editing or publishing unless explicitly asked.
An author request owns implementation and publication only through its requested endpoint.
Apply [proportionate verification](verifiability.md#proportionate-verification) before
selecting owners. The table routes relevant expertise, not a checklist of artifacts:
reuse current checks; create output only for a concrete risk, explanation or explicit requirement.

| Changed behavior / needed explanation | Owner and completion evidence |
|---|---|
| Product or maintainer improvement | [quantify-impact](../quantify-impact/SKILL.md): value sentence for obvious value; paired measurements for explicit performance claims, no benchmark theater |
| New or changed interface, state owner, or structural invariant | [codebase-design](../codebase-design/SKILL.md): author a caller-first sketch before types; use the [curated structural probe](POTETO-ENGINEERING.md#probe-the-shortest-wrong-edit) in review against paths the diff already permits. Skip relationship-preserving mechanical moves |
| Runnable behavior | [dogfood](../dogfood/SKILL.md): actual entrypoint, intended use and a credible failure/recovery path |
| Protobuf schemas (including deletions/renames), Buf/codegen config, or protobuf runtime/descriptor consumers | [protobuf](../protobuf/SKILL.md): binary, JSON, generated-source and behavioral compatibility through real consumers; validation enforcement and descriptor-driven behavior. AIP stays conditional; capability opportunities stay advisory |
| Effect compositions | [Effect development](../t3code-skills/effect-development/SKILL.md): match affected APIs and patterns to the installed version's guidance; existing application work needs no setup or migration task |
| GitHub Actions jobs, actions, permissions or events | [CI maintenance](../t3code-skills/ci-maintenance/SKILL.md): trigger, checkout, credentials, untrusted inputs and least-privilege checks |
| JavaScript workspace-package registration, exports or publication status | [Package development](../t3code-skills/package-development/SKILL.md): repo-native registration, focused tests and intended packed contents |
| Checked-in third-party code, skills, assets or generated snapshots | [Vendored assets](../t3code-skills/vendored-assets/SKILL.md): pinned provenance, retained licenses, deterministic regeneration and consumer checks |
| Customer-facing surface | [visual-review](../visual-review/SKILL.md): inspect affected rendered behavior; use the [PR evidence procedure](../commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5) when captures/comparisons help review or are required |
| Web UI motion changed or requested | [animate](../animate/SKILL.md): inspect purpose, interruption, keyboard/touch and reduced motion; [remove-animations](../remove-animations/SKILL.md) for subtraction-only cleanup, [improve-animations](../improve-animations/SKILL.md) for a prioritized audit/roadmap, [animation-performance](../animation-performance/SKILL.md) for measured frame problems |
| Mobile web viewport, keyboard, touch, safe-area or PWA behavior | [mobile-native](../mobile-native/SKILL.md): reproduce the phone/browser symptom, preserve zoom and native activation; distinguish emulation from physical-device evidence, not a React Native or Swift route |
| Content/layout stress or overflow at valid data bounds | [break-ui](../break-ui/SKILL.md): schema-backed fixtures through the real component; reuse dogfood captures and keep audit requests read-only |
| Sonner toast setup, styling or lifecycle | [ask-sonner](../ask-sonner/SKILL.md): installed types and existing Toaster wrapper, one notification per operation, settled outcome and persistent error path; other toast libraries keep their existing owner |
| Architecture, API contract, data flow or workflow relationships need visual explanation | [excalidraw-diagram](../excalidraw-diagram/SKILL.md) and its [PR comparison](../excalidraw-diagram/PR-WORKFLOW.md): only when requested or clearer than a short explanation; no automatic diagram/source files |
| Logic, ownership or code shape needs a small explanation | [show-me](../show-me/SKILL.md): smallest useful diff sketch, tree or Mermaid; omit visuals that add no understanding |
| PR creation/update | [pr](../pr/SKILL.md): value, reviewer focus, before/after evidence, risk and rollback; separate core changes from generated/mechanical files |

Prefer a short inline result over an evidence file. For useful visual comparisons,
capture the actual base/candidate without disturbing the active worktree. Reuse a focused
screenshot pair; add annotations only when the delta is hard to find. Record video only
when motion/interaction cannot be explained adequately by stills or it is requested.
Then follow [review-video storytelling](../commit-push-pr/VIDEO.md) and the existing
capture/hosting procedure. Use real product/terminal output, not synthetic proof.

A request to build product motion is different from a request to animate an explanation.
Do not add UI animations, generated images or extra movies merely to decorate a PR.
For an explicitly requested customer demo, `/demo` documents the capture-first browser,
asciinema, narration, and walkthrough stack in [its recording recipes](../demo/RECORDING.md).
It is user-invoked; the recipes do not grant publication permission or replace PR evidence.
When explicitly requested creative media needs installed HyperFrames or image-generation
capabilities, use those available owners; do not assume they ship with this harness. They
cannot replace real captures, tests or measurements. Interactive planning remains with
[visual-plan](../visual-plan/SKILL.md) when the task actually calls for that planning surface.

Refresh retained artifacts after edits or base changes; reuse still-current evidence across
self-review and publication. Missing or inaccessible evidence stays an explicit limit, never
fabricated proof. Excalidraw rendering failures warn and continue under its nonblocking contract;
explicitly required project/user evidence keeps its blocker/waiver behavior. Optional
media tooling gaps do not block an otherwise verified change.
