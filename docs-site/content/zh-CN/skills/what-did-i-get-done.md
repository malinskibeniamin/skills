---
description: 将一段时间内由当前用户提交的 Git 提交汇总为简洁的状态更新。适用于准备周度回顾、复盘、已交付工作总结或任意指定日期范围的总结。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - what did i get done
sidebar:
  label: /what-did-i-get-done
title: /what-did-i-get-done
type: skill
---
![“/what-did-i-get-done”技能示意图](/diagrams/skills/what-did-i-get-done.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/what-did-i-get-done.excalidraw)

## 工作流程 [#workflow]

1. 确定具体日期范围；如果知道上次更新的时间，以此作为起点。
2. 读取该日期范围内由当前 Git 用户邮箱对应用户提交的提交记录。
3. 排除合并提交和未提交的更改。
4. 将最重要的已交付变更整合为简洁的状态更新。
5. 根据已说明的计划或明确承诺描述接下来的工作；如果没有已知信息，写出“Next work not specified.”。

- 极度简洁且信息密集。
- 优先呈现实质性的行为或架构变更。
- 忽略仅涉及外观的变更（格式调整、导入调整、小幅重命名）。
- 不要推断意图或动机。以功能角度描述变更。

## 输出 [#output]

始终分成两个部分回答，并使用以下原样标题：

- `What did you work on since the last update?`
- `What are you going to work on next?`

每个部分最多五个简洁要点。所有内容都放在这两个部分内；优先筛选重要信息，不必凑满五点。在第一部分注明实际日期范围。周度回顾或复盘时，在已完成工作的要点内简短标明可能的分类（缺陷修复、技术债务或全新功能）。
