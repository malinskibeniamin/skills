---
title: /plan-arbiter
description: 裁决相互竞争的计划。用于选择或合并来自智能体、对话记录、可视化计划、PR 描述、文件或粘贴策略的提案。
type: skill
sidebar:
  label: /plan-arbiter
---
![‌/plan-arbiter 技能示意图](/diagrams/skills/plan-arbiter.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/plan-arbiter.excalidraw)

阅读 `references/builder-upstream.md`，了解评审检查清单。

将相互竞争的计划整合为一个可执行的方向。保留最佳思路，否决薄弱假设，并生成清晰的交接方案，而不是含混不清的拼凑结果。

## 工作流程

1. 收集源计划：粘贴的文本、本地文件、会话 ID、对话记录、PR、评论、可视化计划链接或聊天记录。
2. 规范化每个计划：目标、范围、假设、未解决的问题、涉及的文件、执行顺序、验证、回滚、复杂度。
3. 根据实际代码库、文档、规范、测试、截图或相关外部系统进行交叉评审。
4. 作出决定：`Adopt`、`Hybrid` 或 `Revise first`。
5. 生成一份包含验证关卡和已否决备选方案的执行交接方案。

除非用户在作出决定后明确要求实施，否则规划过程为只读操作。

## 决胜标准

1. 正确性以及与用户请求的契合度。
2. 是否以实际文件、API、测试、数据和 UI 行为为依据。
3. 更低的不可逆风险。
4. 更小的可交付范围以及更可靠的验证。
5. 更清晰的执行者交接方案。

## 输出

```md
## Plan arbiter
Sources: <plans inspected>
Verdict: Adopt <plan>|Hybrid|Revise first
Why: <evidence-backed reason>
Execution plan: <ordered steps>
Rejected alternatives: <what and why>
Verification gates: <commands/checks>
Open questions: <only blockers>
```
