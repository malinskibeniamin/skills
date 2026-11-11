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

完整的 [Matt Pocock 源文件](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/engineering/pr/SKILL.md)和[原始署名](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/engineering/pr/CREDITS.md)已随整套技能固定版本。此本地适配保留下述 PR 描述、证据及当前会话 PR 所有权规则。


阅读[保护读者注意力的约定](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)。

## 现有 PR [#existing-pr]

在会话开始或恢复时、范围、实现或证据发生实质变化后，以及交接前：

1. 查找与此对话、会话或聊天明确关联的已打开 PR；否则通过 `gh pr view` 检查当前分支。核实打开状态、仓库、源分支、基分支和归属；绝不选择无关的近期 PR。没有已打开的 PR 就无需维护，也不意味着可以创建 PR。
2. 将已发布的描述与**完整 PR 差异**、原始目标及当前验证结果对照，而非只看最近一轮对话或提交。对于堆叠 PR，逐一对照父分支评估受影响的层。 按照[视觉标注](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations)检查截图、标记和图例是否过时。
3. 单独加载 [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)。重新评估业务价值及产品或代码库影响；复用仍有效的证据，重跑已失效的比较，并删除缺乏依据的主张。价值未知时明确写出 `not established`。
4. 对已获授权的修改或交付工作，一并刷新受影响的截图、标记和图例；更新开头一句话，使其概括当前完整变更，并就地替换过时条目，简明说明受益方、价值、决定性证据及实质风险。保留作者意图和必需证据；链接到详情，跳过准确的描述，不追加会话日志。
5. 编辑后重新读取托管平台上的正文，确认其描述的是已发布的源分支状态。只读请求仅报告偏差，不编辑。明确要求仅本地修改或禁止推送时，暂缓发布；绝不将未发布的工作描述为已交付。

## 正文模板 [#body-template]

使用以下模板编写 PR 描述：

```markdown
<one sentence capturing the entire change and why it matters>

- Review: <optional focus or decision; omit if none>
- Testing: <decisive checks and observed results; before -> after; gaps>
- Risk: <affected contracts, failure modes, rollout limits, and how to revert>
```

## 各部分 [#sections]

开头一句话是必需的首读摘要，而非多余的开场白；遵循 [PR 注意力预算](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#match-the-artifact)。下方只保留必要的补充细节。以下主题是给作者的指导，不是 PR 必须包含的标题。较长的记录应通过链接提供或折叠展示；必需的可视化媒体应紧接开头一句话内嵌展示。使用 `GLOSSARY.md` 中用户的领域语言。

### 摘要 [#summary]

仅在有帮助时补充审阅重点，不要重复开头一句话。区分核心变更与生成或机械性文件；指出有用的审查入口，不逐一罗列文件。区分已观察到的结果和预期。

将 PR 正文作为操作者的简明摘要：行为与价值、关键证据、领域决策、剩余风险与恢复方式，以及下一步操作；通过链接提供详情，方便恢复工作。单独的 HTML 或可视化回顾产物需要明确请求；仍须审查完整差异并提供必需的可视化证据。

从 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md) 中选择最小视图。

#### 决策变更 [#changed-decisions]

如果相对已记录的计划或结果契约，范围、契约、验证方式或发布风险发生实质性变化，请说明这些偏离。复用现有笔记或意图图：
先前选择 -> 新证据 -> 当前选择 -> 对审阅的影响。
对于请求或计划未明确、由代理作出的重要选择，执行[决策差异审计](https://github.com/malinskibeniamin/skills/blob/main/shared/decision-deltas.md)，直接调用 PR 工作流时也适用。
PR 内容应独立完整；省略空洞的变更历史，绝不要虚构先前计划或共识。

会话摘录只提供可选上下文。仅使用相关、获准共享、已脱敏且审阅者可访问的摘录；否则提供安全、独立完整的理由说明。
不要只为提供链接而扩大共享范围或执行权限。会话长度或交互轮数既不能证明正确性，也不能证明认真程度；请根据当前差异和执行证据核实相关说法。

将可视化放在其支持的文字旁。只显示关键调用、文件、属性、状态和边界。

省略无法增进理解的视图。

### 证据 [#evidence]

提供证明变更有效的具体证据。优先简述命令和结果；仅在有助于解释变更时展示前后对比，不将媒体视为自动要求。说明未运行的检查和剩余不确定性；测试通过不能证明人类审查或共识。

仅在差异难以定位时使用[视觉标注](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations)。广泛的 UI 工作可在有助于理解时使用 [UI 变更图](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#ui-change-maps)；避免重复截图和独立总结文件。

对于后端、API、Protobuf、契约、架构、数据流或工作流变更，如果截图或视频未能解释受影响的行为，必须在开头一句之后内联加入[后端图表](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md)，并更新过时的维护图表。优先使用 Excalidraw；渲染或托管失败时使用内联 Mermaid。保留测试证据：图表用于解释，不证明正确性。[视觉证据契约](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)规定了适用范围内的例外和检查已发布正文的完成门禁。

按 [commit-push-pr 视觉证据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)选择媒体。只有交互或动效需要，或用户要求时才录制真实流程；其他情况下静态图片和命令结果足够。证据的价值在于回答的问题，不在于媒体等级。测试结果应简洁、真实，不要重构或虚构。

### 合并风险 [#merge-danger]

说明回滚路径，并将变更归类为单向门或双向门。双向门容易退回；破坏性或难以逆转的决策属于单向门。

列明受影响的用户、调用方、契约和可信的故障模式，包括共享使用方。
