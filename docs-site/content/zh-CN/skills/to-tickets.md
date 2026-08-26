---
title: /to-tickets
description: "将计划拆分为具有明确阻塞边的贯穿式工单。"
type: skill
sidebar:
  label: /to-tickets
---
![`/to-tickets` 技能示意图](/diagrams/skills/to-tickets.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/to-tickets.excalidraw)

将已批准的计划、规格或对话变成可独立验证的纵向切片。
若存在 `CLAUDE.md`，先读它；否则读 `AGENTS.md`。遵循其中的 Issue tracker 指针。缺失时使用 `/work-automation-kit` 或本地后备方案。

## 1. 收集

使用现有对话上下文。获取传入规格、问题或 URL 的完整正文和评论。仅在当前代码或领域词汇仍不清楚时探索；遵循项目词汇表和 ADR。先让变更变容易，再做容易的变更。

## 2. 起草切片

每个工单：

- 贯穿所需层次的狭窄端到端路径，而非某一层的横向切片。
- 可独立演示或验证，并适合一个全新上下文窗口。
- 只声明真实阻塞项；没有阻塞即表示可开始。
- 描述用户行为和验收，不写易过期的文件路径或代码片段。

**宽泛重构是例外。** 使用 expand、migrate、contract：在旧形式旁增加新形式；按可独立保持绿色的批次迁移调用方；最后删除旧形式。每个 migrate 批次都被 expand 阻塞。contract 被所有 migrate 批次阻塞。若批次不能独立保持绿色，使用集成分支和最终 integrate-and-verify 工单。

若多个工单图仍成立，使用 `/plan-arbiter`。若大型图的前沿或阻塞关系需要检查，使用 `/visual-plan`。

## 3. 确认

用编号列表展示**标题**、**阻塞于**和**交付内容**。询问粒度、边关系以及是否拆分或合并。迭代到用户批准。

## 4. 发布

每个工单发布一个事项，阻塞者优先。不要修改或关闭父事项。

- **本地：** 写入 `.scratch/<feature-slug>/tickets/<NN>-<slug>.md`，从 `01` 编号。每个文件列出阻塞工单编号和标题。
- **跟踪器：** 每个工单创建一个问题。有原生子问题和阻塞关系时使用它们，否则写明确链接。应用已配置的 `ready-for-agent` 角色。

前沿由所有阻塞项已完成的工单组成。

```markdown
# <NN> -- <工单标题>
**构建内容：** <用户视角的端到端行为>
**阻塞于：** <工单编号和标题，或 None -- 可立即开始>
**状态：** ready-for-agent
## 验收标准
- [ ] <可观察标准>
```

跟踪器问题存在父项时添加 `## Parent`，之后是 `## What to build`、`## Acceptance criteria` 和 `## Blocked by`。
不要内联实现细节。对于 `/prototype` 代码，添加指向其持久位置的上下文指针。
