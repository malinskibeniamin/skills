---
description: "Build, review, or plan purposeful web UI motion: transitions, easing, springs, choreography, staggers, view swaps, and motion audits. Use gestures for direct manipulation; not video or native apps."
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["animate"]}
sidebar: {"label":"/animate"}
title: "/animate"
type: "skill"
---
![Diagram of the /animate skill](/diagrams/skills/animate.svg)

[Open the editable Excalidraw source](/diagrams/skills/animate.excalidraw)


Choose motion that explains a state change without delaying the user's task.
Adapted from Emil Kowalski; [source and selection](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/EMIL-SKILLS-CREDITS.md).
Recorded product walkthroughs use the [demo recording stack](https://github.com/malinskibeniamin/skills/blob/v4.45.0/demo/RECORDING.md),
not UI animation. `/demo` remains user-invoked; this pointer grants no publication scope.

## Endpoint

- Build/fix: implement the requested motion through the project's TDD and delivery gates.
- Review: report evidenced defects; leave source unchanged.
- Audit/plan/opportunities: rank improvements or justified additions; leave source unchanged.
  Save plans only when requested. Do not turn an audit into an execution wave.

## Choose the motion lane

Use the symptom, not the word "slow", to select the next step. Inspect the interaction
before prescribing removal, shorter durations or a performance fix.

| Request / observed symptom | Local owner |
|---|---|
| "The app feels slow" because motion makes people wait | [remove-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/remove-animations/SKILL.md) for subtraction; this skill for retained motion's timing |
| "The sidebar is janky" / frames visibly stutter | [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-performance/SKILL.md): capture a trace before optimizing |
| "The drawer jumps when I let go" / a flick ignores direction | [gestures](https://github.com/malinskibeniamin/skills/blob/v4.45.0/gestures/SKILL.md): tracking, release and interruption |
| "The two views fight while the card resizes" | This skill's [choreography](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/REFERENCE.md#choreography), not another command |
| "Survey the app and plan motion fixes" | [improve-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/improve-animations/SKILL.md); audit/plan stays read-only |
| "What should and shouldn't animate here?" / "review this popover" | This skill's review/opportunity mode below; findings, not implementation |
| "What's it called when a popover grows from its button?" | [animation-vocabulary](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-vocabulary/SKILL.md); naming alone authorizes no build |

## Decision sequence

1. Inspect the component, existing motion tokens, installed library/version, input paths,
   and product context. Use the existing UI primitives before inventing a component.
2. Name the purpose: feedback, spatial continuity, state indication, explanation,
   or rare delight. Repeated navigation, command palettes, and data-reading surfaces
   favor instant changes. Frequency is a heuristic, not an invented daily-use metric.
   Keyboard users get equivalent feedback without a waiting period.
3. Choose the cheapest faithful driver: CSS transitions for state changes;
   `@starting-style` for supported entry transitions; WAAPI for imperative control;
   an installed spring/motion library for gestures, layout, or exit lifecycles.
   Read installed types and current official docs before using library-specific APIs.
   For drag/swipe/sheet physics, load [gestures](https://github.com/malinskibeniamin/skills/blob/v4.45.0/gestures/SKILL.md); it owns tracking,
   release velocity, resistance, scroll arbitration and re-grab continuity.
4. Prefer explicit `transform`/`opacity` transitions. Retarget from the current value;
   preserve exit state until completion and handle interruption/unmount cleanup.
   Scale anchored surfaces from their trigger; keep centered dialogs centered.
5. Reuse tokens. For new tokens and component-specific starting points, read
   [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/REFERENCE.md); profile instead of assuming hardware acceleration.
   For surface/icon motion recipes, read [interface compatibility](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/INTERFACES.md#better-ui),
   then [better-ui](https://github.com/malinskibeniamin/skills/blob/v4.45.0/jakubkrehel-skills/better-ui/SKILL.md); its fixed values never override project tokens or instant feedback.
6. Respect reduced motion, hover capability, focus, and cancellation from the start.
   Remove non-essential movement; instant state changes are valid. Keep essential
   meaning available without animation. Gate hover with `(hover: hover) and (pointer: fine)`.
7. Exercise enter/exit, rapid reversal, repeated activation, keyboard, reduced motion,
   and touch paths at the real entrypoint. Record what was observed and what needs a device.

For multiple elements responding to one event, read
[choreography](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/REFERENCE.md#choreography): choose what stays still, run related parts
together, and sequence only meaningful dependencies. Keep interaction immediate;
prevent stale async continuations from restarting a canceled sequence.

## Review and planning

For subtraction-only cleanup, load [remove-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/remove-animations/SKILL.md).
For a codebase-wide audit or prioritized roadmap, load
[improve-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/improve-animations/SKILL.md); this skill remains the craft owner.

Review purpose/frequency, easing/timing, origin, interruption, frame cost, accessibility,
and cohesion. Cite `file:line` plus visible or trace evidence; distinguish craft suggestions
from reproducible defects. Existing deliberate tradeoffs are context, not automatic findings.
Describe a finding as observed behavior -> proposed behavior -> why it helps. Compare the
same state/input at normal speed; a source demo is a reference, not proof of this app's result.

For opportunity searches, show the eligible location, purpose, expected frequency,
recipe, and rejected candidates. No surviving opportunity is a valid result.
For a roadmap, rank confirmed findings by user impact and effort; include exact target
values, existing tokens, scope, rollback, and a real feel-check in each requested plan.

Report the decision, ingredients, verification, and limits briefly. A code-only review
cannot approve perceived feel or claim measured smoothness. For measured frame problems,
load [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-performance/SKILL.md); for general visual critique,
load [visual-review](https://github.com/malinskibeniamin/skills/blob/v4.45.0/visual-review/SKILL.md) per the
[dependency-loading contract](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies).
