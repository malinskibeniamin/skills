---
title: /prototype
description: 为尚未解决的逻辑、交互或视觉问题构建一次性证据。适用于在正式投入前，通过可运行的证据消除对行为或 UI 的不确定性。
type: skill
sidebar:
  label: /prototype
---
![“/prototype”技能示意图](/diagrams/skills/prototype.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/prototype.excalidraw)

原型用于回答一个明确的问题。它是证据，而不是早期的生产分支。

选择成本最低且能如实验证问题的形式：

- 逻辑/状态不确定性 -> 一个小型可执行状态模型；参见 [LOGIC.md](https://github.com/malinskibeniamin/skills/blob/main/prototype/LOGIC.md)。
- UI/交互不确定性 -> 几个具有实质差异的变体；参见
  [UI.md](https://github.com/malinskibeniamin/skills/blob/main/prototype/UI.md)。
- API/工具不确定性 -> 针对沙箱或固定测试数据执行一次最小调用。

尽可能将可运行的产物放在 `.context/prototypes/<question>/` 下；只有实际运行时必须加载它们时，才放在目标旁边。清楚标记所有放入代码树的产物。

## 保留策略

将完成的原型作为可运行的**第一手资料**保留下来，但绝不要把仅供原型使用的代码合并到主分支：

- 当请求的交付目标授权提交时，将产物提交到独立的
  `prototype/<name>` 分支，并在议题或决策记录中留下上下文指针。
- 否则，将其保留在 `.context/prototypes/<question>/` 下并报告路径。在清理可交付的差异前，将所有放入代码树的产物移动或复制到该目录。不要删除它。

在议题、ADR、实现说明或实现提交中记录问题、证据和结论。主分支只保留经过验证的生产决策。

## 约束

1. 优先使用标准库和现有依赖项；不要搭建与
   问题无关的脚手架。
2. 使用一条命令即可运行。
3. 仅使用内存或临时存储。
4. 展示相关状态和观察结果。
5. 在采信结论前，通过决定性路径及可能的
   边界运行一次 `/dogfood`；不要对每次中间编辑都进行实际试用。
6. 在决定性路径回答问题后，应用上述保留策略。

如果原型与计划相矛盾，请在进行生产实现前重新审视受影响的决策。
