---
description: 为尚未解决的逻辑、交互、视觉或实现问题构建一次性证据。适用于在做出决定前，用可运行的证据消除不确定性。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - prototype
sidebar:
  label: /prototype
title: /prototype
type: skill
---
![“/prototype”技能示意图](/diagrams/skills/prototype.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/prototype.excalidraw)

面临重要的产品或设计选择时，请阅读 [Poteto 适配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#product-and-planning)。

用户明确要求界面工作台时，可推荐 `variant`（设计备选）、`state-machine`（可达状态）或 `break`（极端场景）。阅读[界面保留规则](https://github.com/malinskibeniamin/skills/blob/main/shared/INTERFACES.md#workbench-retention)及相应分支；这些技能只能由用户调用，不是自动依赖。保留可运行的原型，不要将临时路由或切换器放入生产 PR。

原型用于回答一个明确的问题。它是证据，而不是早期的生产分支。

选择成本最低且能如实验证问题的形式：

- 逻辑/状态不确定性 -> 一个小型可执行状态模型；参见 [LOGIC.md](https://github.com/malinskibeniamin/skills/blob/main/prototype/LOGIC.md)。
- UI 与交互 -> 应用内探索或[可分享的审查网站](https://github.com/malinskibeniamin/skills/blob/main/prototype/UI.md#shareable-review-prototype)；设计尚未确定时提供有实质差异的变体。
- API/工具不确定性 -> 针对沙箱或固定测试数据执行一次最小调用。
- [对比实现](#compare-implementations).

尽可能将可运行的产物放在 `.context/prototypes/<question>/` 下；只有实际运行时必须加载它们时，才放在目标旁边。清楚标记所有放入代码树的产物。

## 对比实现 [#compare-implementations]

选取一个有代表性的工作负载，并通过同一个公开入口运行。固定现有实现、候选实现和测试数据的版本，将评估工具独立于两种实现。使用[差分测试](https://github.com/malinskibeniamin/skills/blob/main/tdd/DIFFERENTIAL-TESTING.md)核对可观察的行为、错误和持久化副作用，使用[quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md#optimization-experiments)进行成对测量，并设定最低有意义的改进幅度和停止条件。如果无法在隔离环境中验证决定性的行为，应报告这一缺口，不要仅凭微基准测试决定是否采用候选方案。

## 保留策略 [#retention]

将完成的原型作为可运行的**第一手资料**保留下来，但绝不要把仅供原型使用的代码合并到主分支：

- 当请求的交付目标授权提交时，将产物提交到独立的
  `prototype/<name>` 分支，并在议题或决策记录中留下上下文指针。
- 否则，将其保留在 `.context/prototypes/<question>/` 下并报告路径。在清理可交付的差异前，将所有放入代码树的产物移动或复制到该目录。不要删除它。

在议题、ADR、笔记或提交中记录问题、证据和结论。主分支只保留经过验证的生产决策。

## 约束 [#constraints]

1. 默认使用标准库和现有依赖项。经授权的对比可以在隔离环境中使用候选运行时或库；保持项目依赖项不变。
2. 使用一条命令即可运行。
3. 仅使用内存或临时存储。
4. 展示相关状态和观察结果。
5. 在采信结论前，通过决定性路径及可能的
   边界运行一次 `/dogfood`；不要对每次中间编辑都进行实际试用。
6. 在决定性路径回答问题后，应用上述保留策略。

如果原型与计划相矛盾，请在进行生产实现前重新审视受影响的决策。
