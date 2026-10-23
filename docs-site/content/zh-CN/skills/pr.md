---
description: 在撰写 PR 描述，或持续更新当前会话中已打开 PR 的范围、业务价值和证据时使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - pr
sidebar:
  label: /pr
title: /pr
type: skill
---
![展示 /pr 技能的图表](/diagrams/skills/pr.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/pr.excalidraw)


阅读[保护读者注意力的约定](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)。

## 现有 PR [#existing-pr]

在会话开始或恢复时、范围、实现或证据发生实质变化后，以及交接前：

1. 查找与此对话、会话或聊天明确关联的已打开 PR；否则通过 `gh pr view` 检查当前分支。核实打开状态、仓库、源分支、基分支和归属；绝不选择无关的近期 PR。没有已打开的 PR 就无需维护，也不意味着可以创建 PR。
2. 将已发布的描述与**完整 PR 差异**、原始目标及当前验证结果对照，而非只看最近一轮对话或提交。对于堆叠 PR，逐一对照父分支评估受影响的层。
3. 单独加载 [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)。重新评估业务价值及产品或代码库影响；复用仍有效的证据，重跑已失效的比较，并删除缺乏依据的主张。价值未知时明确写出 `not established`。
4. 对已获授权的修改或交付工作，就地更新过时描述。保持简洁：改了什么、谁受益、为何重要、决定性证据及实质风险。替换过时条目；链接到详情，而非追加会话日志。保留人工撰写的意图和必需证据；已经准确时不作修改。
5. 编辑后重新读取托管平台上的正文，确认其描述的是已发布的源分支状态。只读请求仅报告偏差，不编辑。明确要求仅本地修改或禁止推送时，暂缓发布；绝不将未发布的工作描述为已交付。

## 正文模板 [#body-template]

使用以下模板编写 PR 描述：

```markdown
## Summary

<outcome and why it matters to the affected user or caller>
<reviewer focus or specific question; say if no special input is needed>
<smallest useful diagram, diff-sketch, or tree>

## Evidence

<frontend: before/after flow video playing inline (user-attachments URL), then screenshot table>

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <affected users, callers, or contracts>

<rollback path and unresolved risks, when applicable>
```

## 各部分 [#sections]

省略所有开场白并保持文字简短。使用 `GLOSSARY.md` 中用户的领域语言。

### 摘要 [#summary]

区分核心变更与生成或机械性文件；指出有用的审查入口，不逐一罗列文件。

先说明价值和审阅重点，而不是罗列变更。区分已观察到的结果和预期。
然后选择能说明要点的最小视图；省略无法增进理解的可视化。

从 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md) 中选择最小视图。

#### 决策变更 [#changed-decisions]

如果相对已记录的计划或结果契约，范围、契约、验证方式或发布风险发生实质性变化，请说明这些偏离。复用现有笔记或意图图：
先前选择 -> 新证据 -> 当前选择 -> 对审阅的影响。
PR 内容应独立完整；省略空洞的变更历史，绝不要虚构先前计划或共识。

会话摘录只提供可选上下文。仅使用相关、获准共享、已脱敏且审阅者可访问的摘录；否则提供安全、独立完整的理由说明。
不要只为提供链接而扩大共享范围或执行权限。会话长度或交互轮数既不能证明正确性，也不能证明认真程度；请根据当前差异和执行证据核实相关说法。

#### 指南 [#guidance]

将可视化放在其支持的文字旁。只显示关键调用、文件、属性、状态和边界。

仅使用能增进理解的视图。

### 证据 [#evidence]

提供变更有效的具体证据，展示变更前后对比。列明未运行的检查和剩余不确定性；测试通过不代表人工审查或共识。

对于后端架构、数据流、API 契约或工作流变更，请遵循[后端图表](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md)指南并调用 `excalidraw-diagram`。提供聚焦的前后对比和可编辑源文件链接；更新相关的持续维护图表。图表失败时报告警告并继续，绝不阻塞 PR，也不能替代测试证据。

对于任何前端变更，内嵌播放的真实 UI 流程变更前后对比视频（包含点击、输入和最终状态，绝不能只是静止页面）加上截图，是最高等级的证据，且必须提供。将其放在摘要之后，让审阅者在阅读变更说明前就能看到变更。按照 [commit-push-pr 可视化证据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5) 中的说明录制、合成并托管视频。

基于执行的证据次之：测试结果、控制台输出。用伪代码展示此前失败、现在通过的具体测试。

### 合并风险 [#merge-danger]

说明回滚路径。双向门容易退回；破坏性或难以逆转的决策属于单向门。

列明受影响的用户、调用方、契约和可信的故障模式，包括共享使用方。
