---
title: "/pr"
description: "在撰写 PR 描述时使用。"
type: skill
sidebar:
  label: "/pr"
---
![展示 /pr 技能的图表](/diagrams/skills/pr.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/pr.excalidraw)


使用此模板撰写 PR 描述：

```markdown
## Summary

<diagram, diff-sketch, or tree>

## Evidence

- **Before:** <screenshot/output/failing test run>
  **After:** <screenshot/output/passing test run>

## Merge Danger

**Door:** <one-way or two-way>

<optional: description>

**Blast Radius:** <one-word description>

<optional: potential ramifications of merge>
```

## 各部分

省略所有开场白并保持文字简短。使用 `CONTEXT.md` 中用户的领域语言。

### 摘要

选择能清晰表达要点的最小视图。

从 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/v4.39.0/pr/SUMMARY-VIEWS.md) 中的视图里选择：伪代码、调用树、组件树、文件树、Mermaid、diff 或完整代码块。

#### 指南

将每个可视化内容放在其所支持的简短文字旁边。只保留回答用户当前问题或解决当前讨论点的选项所需的调用、文件、属性、状态和边界。

你可以使用其中一种，也可以使用多种，但不太可能全部使用。请自行判断，不要让过多信息淹没用户。

### 证据

证明变更有效的具体证据。展示变更前后的对比。

当环境已准备就绪且变更是可视的，截图是最高等级的证据。

基于执行的证据次之：测试结果、控制台输出。用伪代码展示此前失败、现在通过的具体测试。

### 合并风险

说明这是单向门还是双向门。双向门可以退回，单向门不能。易于回滚的 PR 风险更低。涉及破坏性操作或难以逆转的决策的变更属于单向门。

影响范围是此 PR 所引入变更的潜在影响或波及面。考虑所有可能性，例如布局偏移、对使用方造成的破坏、移动端适配等。
