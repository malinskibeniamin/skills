---
title: /resolving-merge-conflicts
description: 解决正在进行的 Git 合并或变基冲突。
type: skill
sidebar:
  label: /resolving-merge-conflicts
---
![“/resolving-merge-conflicts”技能示意图](/diagrams/skills/resolving-merge-conflicts.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/resolving-merge-conflicts.excalidraw)

当冲突上下文涉及其他智能体的分支或认领内容时，使用 `/agent-watchdog`；当审查源材料后仍存在可行的语义冲突解决方案时，使用 `/plan-arbiter`。

1. **查看合并或变基的当前状态。**检查 Git 历史记录和存在冲突的文件。

2. **查找每项冲突的第一手资料。**深入了解每项更改的原因及其原始意图。阅读提交消息，查看 PR，并检查原始议题或工单。

3. **逐个解决冲突区块。**尽可能保留双方的意图。如果二者不兼容，请选择符合本次合并既定目标的一方，并注明相应取舍。如果第一手资料表明合并或变基本身有误，或者预期结果仍不明确，请停在具体冲突处并询问是否中止；未经批准，切勿中止。

4. 找出项目的**自动化检查**并运行它们——通常依次运行类型检查、测试和格式化。修复因合并而出现的所有问题。

5. **完成合并或变基。**暂存所有内容并提交。如果正在变基，请继续执行变基流程，直到所有提交均完成变基。
