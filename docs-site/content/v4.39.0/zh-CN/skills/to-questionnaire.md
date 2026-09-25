---
title: /to-questionnaire
description: 将一个你无法完全回答的决策问题转化为供他人填写的问卷。
type: skill
sidebar:
  label: /to-questionnaire
---
![“/to-questionnaire”技能示意图](/diagrams/skills/to-questionnaire.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/to-questionnaire.excalidraw)

将用户无法独自回答的问题转化为一份 Markdown 问卷，供一人异步填写或在会议期间作答。接收者掌握用户所缺少的知识；问卷的作用就是将这些知识提取出来。

**深入追问如何发送，而非主题本身。** 只询问用户能够回答的内容：谁会收到问卷，以及他们需要得到什么反馈。然后，让文档聚焦于接收者掌握的知识与用户需要做出的决策之间的缺口。

1. **谁会收到问卷？** 在一次交流中询问接收者的角色、专业知识以及与用户的关系。这些信息决定问卷的语气和需要提供的背景信息。当受众及其独有的知识都已明确时，即完成此步骤。
2. **必须得到哪些反馈？** 询问用户无法独自确定的具体事实或决策。当用户之后必须能够决定或执行的事项已形成具体清单时，即完成此步骤。
3. **编写问卷。** 按照以下结构，在当前目录中创建 `to-questionnaire-<topic-slug>.md`。当每个预期结果都由一个问题覆盖，并且已报告文件路径时，即完成此步骤。

## 文档结构

将其设计为一份**探索问卷**。按重要性从高到低排列问题，因为异步请求可能只有一次作答机会。如果问题数量超过少数几个，请使用 `##` 主题标题。

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

每个问题只涉及一个主题，其正下方应有作答占位符；只有当问题可能被误解时，才说明提问理由。
