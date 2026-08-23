---
title: /agent-watchdog
description: 根据原始请求和实时证据审计另一个智能体。适用于会话、转录记录、PR、分支、日志、比较或已获授权的修复。
type: skill
sidebar:
  label: /agent-watchdog
---
![‌/agent-watchdog 技能示意图](/diagrams/skills/agent-watchdog.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/agent-watchdog.excalidraw)

当审计较为复杂或源工件含义不明确时，请阅读 `references/builder-upstream.md`。

## 模式

- **仅监控**：监控会话、PR、分支、CI 运行或转录记录，直至其进入终止状态。不要编辑。
- **审计**：对比请求、转录记录、差异、测试、CI、评论、截图和最终声明。不要编辑。
- **审计并修复**：先进行审计，然后针对明确且已获授权的缺漏进行小范围修复。
- **比较**：根据同一个原始请求比较多个智能体或会话。

如果编辑权限不明确，默认仅进行审计。

## 工作流程

1. 确定每个目标：会话 ID、转录记录、对话串 URL、PR、分支、提交、CI 运行、议题、Slack 链接或粘贴的摘要。
2. 重建约定：原始请求、范围变更、约束、隐含的验收标准、最终声明和注意事项。
3. 检查证据，而非凭感觉判断：已更改的文件、周边代码、实际命令输出、CI、截图、未解决的评论和部署日志。
4. 对每个问题进行分类：`Gap`、`Bug`、`Verification miss`、`Scope drift` 或 `No issue`。
5. 如果已获授权，仅修复明确的缺漏；除非收到请求，否则绝不还原无关工作或移动分支。
6. 报告状态，并列出确切的文件、命令、未解决的风险和下一步操作。

## 输出

```md
## Agent watchdog
Target: <artifact>
Mode: watch|audit|audit-and-fix|compare
Contract: <what the user asked>
Evidence checked: <files/commands/CI/comments>
Findings:
- <Gap|Bug|Verification miss|Scope drift|No issue>: <evidence and required action>
Fixes made: <if any>
Still open: <blockers or risks>
```
