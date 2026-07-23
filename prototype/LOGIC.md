# Logic Prototype

A single, self-contained HTML file -- a **shareable demo** -- that lets anyone drive a state model by clicking buttons. Use this when the question is about business logic, state transitions, or data shape: the kind of thing that looks reasonable on paper but only feels wrong once you push it through real cases.

Because it needs nothing installed, a designer, PM, or domain expert can open it directly and feel the model. Use domain language, not code language.

## When this is the right shape

- "I'm not sure if this state machine handles the edge case where X then Y."
- "Does this data model actually let me represent the case where..."
- "I want to feel out what the API should look like before writing it."
- Anything where someone wants to **press buttons and watch state change**.

If the question is "what should this look like" -- wrong branch. Use [UI.md](UI.md).

## Process

### 1. State the question

Put the model and question in a visible introduction at the top of the demo. A prototype that answers the wrong question is pure waste, so make the bound checkable when the user returns.

### 2. Isolate the logic

Put the decision-bearing logic in one `<script>` block behind a small, pure interface that can lift into the real code later. The page around it is throwaway; the logic is not.

Choose the shape that fits the question:

- **Pure reducer** -- `(state, action) => state` for discrete events over one state value.
- **State machine** -- explicit states and transitions when legal actions depend on current state.
- **Pure functions** -- transformations over plain data when there is no implicit current state.
- **Class or module** -- only when the logic genuinely owns ongoing internal state.

Keep the module free of DOM calls and button handlers. The page calls it; nothing flows the other way.

### 3. Build the shareable HTML

Use one plain HTML/CSS/JS file: no framework, bundler, server, or external assets. It must open by double-click and survive being emailed.

Lay it out top to bottom:

1. **Title and question** -- one line explaining what the demo explores.
2. **Current state** -- labelled fields, not raw JSON; re-render after every action and call out the latest change when useful.
3. **Free-play buttons** -- one per action, always available.
4. **Guided walkthroughs** -- one scenario per tab, each with a short description and ordered buttons to press. Starting a walkthrough resets known state; each click performs the real action and advances the scenario.

Include the happy path, a difficult edge case, and an action that should be illegal. Keep typography clean, spacing generous, and styling restrained so state remains the focus.

### 4. Hand it over

Send or open the file. The useful moments are "that shouldn't be possible" and "I assumed X would differ" -- bugs in the idea. Add actions or scenarios as the question sharpens.

### 5. Capture the answer and prototype

Capture the verdict, then follow [SKILL.md](SKILL.md): lift validated logic into the real module and preserve the HTML demo on the throwaway primary-source branch. Leave a context pointer on the implementation issue so the evidence stays runnable.

## Anti-patterns

- **Tests.** A prototype that needs tests is no longer a prototype.
- **Real database wiring.** Use in-memory state unless persistence is the question.
- **Generality.** Answer one question, not imagined future ones.
- **DOM inside the logic module.** Keep the page a thin shell over liftable logic.
- **Framework, bundler, or server.** One file the recipient double-clicks.
- **Shipping the HTML shell.** Production keeps the validated logic, not the demo surface.
