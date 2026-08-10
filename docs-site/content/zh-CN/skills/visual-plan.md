---
title: /visual-plan
description: >-
  使用图表、文件映射、带注释的代码和 UI 审查创建交互式 Agent-Native 可视化计划。适用于规划非简单的产品、UI、架构、数据、API
  或竞争方案。
type: skill
sidebar:
  label: /visual-plan
---
![展示 /visual-plan 技能的图表](/diagrams/skills/visual-plan.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/visual-plan.excalidraw)

本地覆盖规则：将上游 `npx @agent-native/core` 示例转换为 `bunx @agent-native/core`。

## 必需的参考资料

在创建或更新可视化计划之前，请阅读 `references/agent-native-plan.md`。该文件规定了完整的 Agent-Native 计划契约、Plan MCP 用法、块目录要求、可视化界面选择、评论循环、本地文件隐私模式以及文档质量规则。

仅在相关时阅读以下资料：

- `references/connection.md` -- 连接器发现、禁止内联的回退方案、重新连接步骤。
- `references/local-files.md` -- 本地、离线及私密计划模式。
- `references/wireframe.md` -- 线框图 HTML/CSS 规则。
- `references/canvas.md` -- 画布及原型审查界面。
- `references/document-quality.md` -- 独立计划的质量门槛。
- `references/exemplar.md` -- 计划结构示例。

## 本地流程覆盖规则

- 当多个计划或智能体之间存在分歧时，使用 `/plan-arbiter`。
- 如果在实施前仍有未决事项，使用 `/grilling`。
- 除非用户明确批准实施，否则规划过程为只读。
