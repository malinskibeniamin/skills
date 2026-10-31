---
title: /tanstack-table
description: >-
  通过 TanStack Intent 加载已安装软件包的指导后，应用仓库特定的 TanStack Table
  强制规则。适用于构建、审查或迁移表格和数据网格。
type: skill
sidebar:
  label: /tanstack-table
---
![／tanstack-table 技能示意图](/diagrams/skills/tanstack-table.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/tanstack-table.excalidraw)

首先遵循 `/tanstack-intent`。发现已安装的 Table 适配器和核心软件包，
然后加载所有与任务匹配的 `use` ID。Intent 负责提供当前 API 语法、版本状态、
迁移指导、状态语义以及框架特定模式。

## 本地强制规则

`tanstack-table-check` 钩子是受版本限制的回归基线，而不是 API
文档。它会解析最近声明或安装的软件包版本，并且仅对 V9 项目应用
其 V9 检查。已安装的 Intent 指导仍具有权威性。

如果该钩子与已加载的软件包指导冲突，请停止并修复测试工具及其评估。
不要为了满足该钩子而绕过官方 API 或保留过时的本地说明。

完成证据包括已安装的软件包版本、已加载的 Intent `use` ID、
针对 Table 的测试、类型检查和代码检查。
