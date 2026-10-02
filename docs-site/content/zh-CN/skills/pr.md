---
title: /pr
description: 在撰写 PR 描述时使用。
type: skill
sidebar:
  label: /pr
---
![展示 /pr 技能的图表](/diagrams/skills/pr.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/pr.excalidraw)


阅读[保护读者注意力的约定](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)。使用以下模板编写 PR 描述：

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

省略所有开场白并保持文字简短。使用 `CONTEXT.md` 中用户的领域语言。

### 摘要 [#summary]

先说明价值和审阅重点，而不是罗列变更。区分已观察到的结果和预期。
然后选择能说明要点的最小视图；省略无法增进理解的可视化。

从 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md) 中选择最小视图。

#### 指南 [#guidance]

将可视化放在其支持的文字旁。只显示关键调用、文件、属性、状态和边界。

仅使用能增进理解的视图。

### 证据 [#evidence]

提供变更有效的具体证据，展示变更前后对比。列明未运行的检查和剩余不确定性；测试通过不代表人工审查或共识。

对于任何前端变更，内嵌播放的真实 UI 流程变更前后对比视频（包含点击、输入和最终状态，绝不能只是静止页面）加上截图，是最高等级的证据，且必须提供。将其放在摘要之后，让审阅者在阅读变更说明前就能看到变更。按照 [commit-push-pr 可视化证据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5) 中的说明录制、合成并托管视频。

基于执行的证据次之：测试结果、控制台输出。用伪代码展示此前失败、现在通过的具体测试。

### 合并风险 [#merge-danger]

说明回滚路径。双向门容易退回；破坏性或难以逆转的决策属于单向门。

列明受影响的用户、调用方、契约和可信的故障模式，包括共享使用方。
