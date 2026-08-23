---
title: "/to-questionnaire"
description: "Turn a decision you cannot fully answer into a questionnaire for someone else."
type: skill
sidebar:
  label: "/to-questionnaire"
---
![Diagram of the /to-questionnaire skill](/diagrams/skills/to-questionnaire.svg)

[Open the editable Excalidraw source](/diagrams/skills/to-questionnaire.excalidraw)

Turn something the user cannot answer alone into a Markdown questionnaire for one person to fill in asynchronously or during a meeting. The recipient holds knowledge the user lacks; the questionnaire pulls it out.

**Grill the send, not the subject.** Ask the user only about what they can answer: who receives it and what they need back. The document then targets the gap between the recipient's knowledge and the user's decision.

1. **Who receives it?** Ask for the recipient's role, expertise, and relationship to the user in one exchange. This sets tone and required context. Done when the audience and their unique knowledge are clear.
2. **What must come back?** Ask for the specific facts or decisions the user cannot resolve alone. Done when there is a concrete list of what the user must be able to decide or do afterward.
3. **Write it.** Create `to-questionnaire-<topic-slug>.md` in the current directory using the structure below. Done when every requested outcome is covered by one question and the path is reported.

## Document structure

Frame it as a **discovery questionnaire**. Order questions most-important-first because asynchronous requests may get only one pass. Use `##` theme headings once there are more than a handful.

```markdown
# <Questionnaire title>

**Purpose:** <why this exists and the decision riding on it>

**From:** <user> -- **To:** <recipient> -- **How answers will be used:** <destination>

## Context

<One paragraph orienting someone who was not in the original conversation.>

## How to answer

<Deadline and rough effort. Say partial answers and "I don't know" are useful.>

## <Theme>

### <One focused question>

_Why this matters: <only when needed to prevent a shallow or misread answer>_

>

## Anything else?

What did we not ask that we should know?
```

Every question covers one idea, has an answer stub directly beneath it, and uses a rationale only when the question could be misread.
