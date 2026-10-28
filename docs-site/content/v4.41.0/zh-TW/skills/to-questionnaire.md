---
title: /to-questionnaire
description: 將你無法完全回答的決策轉換成一份問卷，交由他人填寫。
type: skill
sidebar:
  label: /to-questionnaire
---
![「/to-questionnaire」技能示意圖](/diagrams/skills/to-questionnaire.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/to-questionnaire.excalidraw)

將使用者無法獨自回答的事項轉換成 Markdown 問卷，供一人非同步填寫或在會議期間作答。收件者掌握使用者欠缺的知識；問卷則負責將這些知識引導出來。

**深入釐清如何送出，而非主題本身。** 只詢問使用者能夠回答的事項：誰會收到問卷，以及他們需要取得哪些回覆。接著，文件應聚焦於收件者掌握的知識與使用者所需決策之間的落差。

1. **誰會收到？** 在一次問答中詢問收件者的角色、專業知識，以及與使用者的關係。這會決定語氣與需要提供的背景資訊。當受眾及其獨有的知識都已明確時，即告完成。
2. **必須取得哪些回覆？** 詢問使用者無法獨自釐清的具體事實或決策。當使用者事後必須能夠決定或執行的事項已有明確清單時，即告完成。
3. **撰寫問卷。** 使用下方結構，在目前目錄中建立 `to-questionnaire-<topic-slug>.md`。當每項預期成果都有一個問題涵蓋，且已回報檔案路徑時，即告完成。

## 文件結構

將其定位為一份**探索問卷**。依重要性由高至低排列問題，因為非同步請求可能只有一次回答機會。問題超過少數幾個時，使用 `##` 主題標題。

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

每個問題只涵蓋一個概念，其正下方須有作答預留區，且只有在問題可能遭到誤解時才附上提問理由。
