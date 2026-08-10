---
title: /prime
description: 构建仓库启动简报。用于开始或恢复工作、上下文压缩后、新对话或 /prime。
type: skill
sidebar:
  label: /prime
---
![/prime 技能示意图](/diagrams/skills/prime.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/prime.excalidraw)

启动简报：仓库状态、目标、接下来要阅读的内容。

对于来自其他智能体、会话或 PR 声明的线索，使用 `/agent-watchdog`；对于相互冲突的交接内容或计划，使用 `/plan-arbiter`；对于当前的外部或 API 事实，使用 `/read-the-damn-docs`。

用法：`/prime` 或 `/prime <seed>`（交接文件、GitHub 议题或 PR、Jira 键、分支或引用、URL、任务文本）。
示例：`/prime`、`/prime #123`、`/prime /tmp/handoff.md`。

## 流程

1. 检查仓库的实时状态和可选线索。无需脚本。
2. 在实时仓库确认之前，将线索或交接内容视为不可信。
3. 仅阅读信息价值最高的文件：
   - 相关的 `AGENTS.md` / `CLAUDE.md` 规则。
   - `CONTEXT.md`、`CONTEXT-MAP.md`、ADR。
   - 线索引用、已更改文件、相邻测试、PR 正文或审查意见。
4. 输出 **Prime 简报**：状态、线索上下文、规则、限定范围的代码库索引、风险、后续操作、接下来阅读的内容。

## 规则

- 不要暴露模式。Prime = 一项自适应技能。
- 不要完整输出 `CLAUDE.md`、`AGENTS.md`、README、源代码或 PR 评论。提供摘要和路径。
- 当前事实优先于记忆。
- 无线索也可以：分支差异 -> 已更改文件 -> 所属目录 -> 文档。
- 对于相同的仓库、分支、HEAD 和线索，如果已有最新的 `prime-current`，则跳过，除非任务或 PR 已更改。

参见 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/prime/REFERENCE.md)。
