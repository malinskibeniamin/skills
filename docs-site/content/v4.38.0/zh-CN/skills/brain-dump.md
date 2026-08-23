---
title: /brain-dump
description: 在深入追问之前，将非结构化的想法、笔记、文章、文件或链接整理成一份有事实依据的机会简报。当用户大致了解涉及的范围，但尚无稳定目标或聚焦的问题时使用。
type: skill
sidebar:
  label: /brain-dump
---
![“/brain-dump”技能示意图](/diagrams/skills/brain-dump.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/brain-dump.excalidraw)

将原始信息整理成一份可选的探索材料包，用于后续的 `/grilling` 会话。保留广度：一份倾诉内容可能揭示多个彼此独立的问题、待办事项、工单或研究方向。始终停留在探索阶段。除非用户要求保存或发布，否则在聊天中返回简报；不要实施方案、创建工单，也不要将机会点转化为承诺事项。

## 1. 先吸收，再整理

将对话、笔记、附件、文件和链接视为一份整体倾诉内容。如果用户表示还在继续讲，简短回应并等待。否则直接继续，无需拘泥形式。阅读用户提供的材料和仓库中的相关证据。对于未附带问题的文章或链接，提取其主张、结论、约束条件、时间节点和潜在影响。如果当前标准、API 或路线图至关重要，应通过 `/read-the-damn-docs` 或 `/research` 追溯到一手来源。

区分：

- 来源事实和仓库事实；
- 用户的观察、偏好和约束；
- 合理的推断，并明确标注为推断；
- 矛盾之处和确实未知的信息。

绝不要让用户重复倾诉内容或证据中已有的答案。

## 2. 重构问题全貌

提取相关角色、痛点、期望结果、受影响的系统、触发条件、约束、现有想法、已否决的方向、紧迫性和成功信号。将隐含答案整理到一份**答案台账**中，并归入以下三种状态之一：

- **已确定** -- 明确说明或有直接依据；
- **暂定** -- 基于推断，可以质疑；
- **未知** -- 信息缺失，并且可能改变方向。

在提出工作建议之前，先说明整体范围；将底层需求与建议的解决方案区分开来。

## 3. 扩展机会图谱

列出所有存在实质差异且有证据支持的方向；合并重复项。通常列出 2-5 个，但如果有充分依据，则可以保留更多。只有在有依据时，才纳入产品、用户体验、工程、文档和研究方向。

对于每个机会点，说明：

1. 预期结果、受影响的角色和支持该机会点的证据；
2. 可能的工作产物、依赖项、风险和待决事项；
3. 成本最低的下一步验证：查证、原型、度量或可逆的小范围实现。

根据价值、证据、紧迫性和可逆性，推荐一个方向或一组兼容的方向。保留其他备选项；机会图谱并不意味着其中每一项都会成为待办工作。

## 4. 返回产物

使用以下结构，并删除空白章节：

```markdown
## Brain dump brief

### Orientation
<surface, central tension, and recommended starting direction or bundle>

### Source synthesis
<important conclusions, facts, implications, contradictions, and citations or paths>

## Answer ledger
| Likely grilling question | Extracted answer | State | Evidence |
|---|---|---|---|
| ... | ... | Settled / Tentative / Unknown | ... |

## Opportunity map
### <Opportunity>
- Outcome:
- Why this is plausible:
- Work products:
- Risks and dependencies:
- Cheapest next proof:

## Grilling handoff
- Settled context to preserve:
- Tentative assumptions to challenge:
- Material user decisions still open:
- Facts to look up without asking the user:
- Candidate prototypes or measurements:
```

产物应足够自包含，便于进入下一阶段，但应链接或引用源材料，而不是复制其内容。

## 5. 移交至深入追问

如果仍有重要决策待定，则继续使用 `/grilling`。传递每一条机会方向。仅针对可能否定某个方向或影响其优先级的**未知**事项提问；如果潜在负面影响较大，则质疑**暂定**事项。除非有证据与其矛盾，否则将**已确定**事项视为已经得到回答。

否则，在给出简报后停止，并推荐下一步适合进行的查证、原型、规格说明、规划或行动。
