---
title: /visual-recap
description: 为 PR、分支、提交或差异创建交互式可视化回顾。
type: skill
sidebar:
  label: /visual-recap
---
![/visual-recap 技能示意图](/diagrams/skills/visual-recap.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/visual-recap.excalidraw)

本地覆盖规则：将上游的 `npx @agent-native/core` 示例替换为 `bunx @agent-native/core`。

## 必需参考资料

创建回顾之前，请阅读 `references/agent-native-recap.md`。该文件定义了完整的可视化回顾创建规范、禁止内联规则、Plan MCP URL 规则、差异到块的映射、脱敏、安全可见性、本地文件隐私模式以及审查反馈循环。

仅在相关时阅读以下内容：

- `references/connection.md` —— 连接器发现、重新连接步骤和禁止内联时的回退方案。
- `references/local-files.md` —— 无托管数据库/仅本地回顾模式。
- `references/wireframe.md` —— 可见差异的 UI 线框图规则。

## 本地执行环境覆盖规则

- 当用户明确调用 `/visual-recap` 时，为指定的 PR、分支、提交或差异创建回顾，或将回顾链接到该目标。
- 创建回顾属于额外的产物工作；`/commit-push-pr` 和 `/go` 不会自动调用它。
- 对于有实质意义的架构或数据流变更，使用 `/excalidraw-diagram` 创建 `.excalidraw` 源文件以及 PNG 或 SVG。将 Agent-Native 回顾作为主要审查界面：仅当当前块目录支持媒体时嵌入渲染后的资源；否则使用其 `diagram` 块，并在交付说明中包含源文件和导出文件的路径。对于简单图形或画布不可用的情况，优先使用内置的 Mermaid 方案。
- 确保回顾以实际差异为依据。对密钥进行脱敏，不要推断变更行中不存在的事实。
- 如果明确请求的目标不具备有意义的可视化结构，请返回相关证据，而不是凭空编造回顾。
