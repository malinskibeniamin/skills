---
title: /handoff
description: 将当前会话压缩为交接文档，供其他代理或新会话使用。
type: skill
sidebar:
  label: /handoff
---
![／handoff 技能示意图](/diagrams/skills/handoff.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/handoff.excalidraw)

如果此次交接用于审查其他代理的运行过程，请转至 `/agent-watchdog`。如果交接的是相互竞争的方案，请将 `/plan-arbiter` 列为下一个技能。
创建一份简洁的交接文档，供其他代理或会话从当前进度继续工作。

## 何时使用

当用户希望执行以下操作时使用：
- 在新会话中继续工作
- 将工作交给其他代理
- 在其他位置开展原型验证或并行工作
- 在不携带完整对话记录的情况下保留可执行的上下文

## 操作流程

1. 创建临时文件：
   ```bash
   handoff_file=$(mktemp -t handoff-XXXXXX.md)
   ```
2. 将交接内容写入该路径。
3. 保持内容精简。不要重复规格、计划、ADR、议题、提交、差异或文档中已记录的产物。通过路径或 URL 引用它们。
4. 如果用户提供了参数，将其视为下一会话的工作重点，并据此调整交接内容。
5. 隐去敏感信息：API 密钥、密码、令牌、机密信息、个人数据、客户数据以及其他任何保密值。仅当隐去内容会影响后续工作时才提及。
6. 如有适用技能，建议下一会话使用。
7. 仅返回交接文件路径以及 1-2 句摘要。
8. **后台代理模式**——用户希望新代理立即接手工作：
   不保存文件，而是启动 `claude --bg --name "<descriptive name>" "<handoff summary>"`
   （先检查 `command -v claude`；如果不可用或启动失败，不要声称代理
   已启动——请输出确切命令和摘要，以便用户运行）。始终传入描述性的
   `--name`；当下一会话必须验证此代理的声明时，在建议技能中包含
   `/agent-watchdog`。

## 交接模板

```markdown
# Handoff

## Next session focus
<What the next agent/session should do first.>

## Current state
<Only facts needed to resume. Include branch, cwd, PR/issue links if relevant.>

## Decisions made
<Bullets. Link to ADRs/plans/issues instead of restating them.>

## Open questions
<Bullets, or "None".>

## Next actions
1. <First concrete action>
2. <Second concrete action>
3. <Verification or shipping step>

## Relevant artifacts
- <path or URL>: <why it matters>

## Suggested skills
- </skill-name>: <why>
```

## 注意事项

- 不要将交接文档用作囊括一切的隐藏摘要。仅包含继续工作所需的上下文。
- 优先使用路径和 URL，而非粘贴内容。
- 隐去机密信息和个人数据。
- 明确指出不确定之处。
- 如果尚未开展任何有用的工作，请如实说明，并编写一份简短的启动说明。
