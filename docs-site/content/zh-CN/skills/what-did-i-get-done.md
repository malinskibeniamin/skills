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

读取指定日期范围内由当前 Git 用户邮箱对应用户提交的提交记录；如果知道上次更新的时间，以此作为起点。
排除合并提交和未提交的更改。优先呈现已交付的行为或架构变更，忽略格式调整、导入调整和小幅重命名。
描述功能，不推断动机。

## 输出 [#output]

始终只使用以下两个原样标题：

- `What did you work on since the last update?`
- `What are you going to work on next?`

每个部分最多五个简洁要点。第一部分注明实际日期范围；周度回顾或复盘时，简短标明可能的分类（缺陷修复、技术债务或全新功能）。
接下来的工作只依据已说明的计划或承诺；否则写出 "Next work not specified."。
