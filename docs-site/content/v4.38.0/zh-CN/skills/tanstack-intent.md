---
title: /tanstack-intent
description: >-
  当提及、引用或处理 TanStack 软件包时，使用 TanStack Intent。在回答问题或更改 Router、Query、Table 或其他
  TanStack 代码之前，加载与版本匹配的指南。
type: skill
sidebar:
  label: /tanstack-intent
---
![/tanstack-intent 技能示意图](/diagrams/skills/tanstack-intent.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/tanstack-intent.excalidraw)

在回答、规划、审查或编辑之前，询问 TanStack Intent 哪些已安装软件包的文档适用。当提及、引用或处理 TanStack 软件包时，即使任务未指定本地 TanStack 技能，也应执行此操作。

## 加载软件包指南

1. 根据请求、导入语句和最近的 `package.json`，识别每个相关的 `@tanstack/*` 软件包。使用已安装的依赖项，而不是凭记忆判断主版本。
2. 在软件包根目录中，查找其随附的技能：

   ```bash
   bunx @tanstack/intent@latest list --json
   ```

3. 根据返回的 `skills[].packageName`、`description` 和 `use` 字段，将每项任务与相应技能进行匹配。严格按照返回的内容加载每个匹配的 `use` ID：

   ```bash
   bunx @tanstack/intent@latest load "$use_id"
   ```

4. 应用技能前，加载该技能指定的所有 `requires`。对于组合用法，加载涉及的每个所有者的指南，例如 Table 与 Query，或 Router 与 Query。

当仓库不使用 Bun 时，请使用仓库的命令运行工具。不要猜测技能 ID，也不要选择名称相似的框架软件包。

## 权威性

- 已安装且与版本匹配的 Intent 指南决定 TanStack API 语法、版本状态、迁移步骤以及特定于框架的行为。
- 只有在 Intent 加载后，本地 `/tanstack-router` 和 `/tanstack-table` 指南才可补充仓库策略和确定性检查。
- 如果本地指南或钩子与已安装的 Intent 技能冲突，应将其视为工具链缺陷。遵循软件包指南并修复工具链，而不是通过变通代码绕过冲突。
- 如果软件包未安装或没有提供匹配的技能，请说明 Intent 无法提供与版本匹配的指南，然后使用 `/read-the-damn-docs` 查阅 TanStack 官方来源。切勿在不作说明的情况下凭记忆填补空缺。

有关项目设置，请阅读 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/tanstack-intent/SETUP.md)。完成凭证需列出已加载的 `package@version` 和 `use` ID。
