---
description: 根据原始请求和实时证据审计另一个智能体。适用于会话、PR、分支、比较、已获授权的修复或接管停滞工作。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - agent watchdog
sidebar:
  label: /agent-watchdog
title: /agent-watchdog
type: skill
---
![‌/agent-watchdog 技能示意图](/diagrams/skills/agent-watchdog.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/agent-watchdog.excalidraw)

当审计较为复杂或源工件含义不明确时，请阅读 `references/builder-upstream.md`。

仅使用已获授权的来源和宿主实际提供的能力。自行开展调查；额外智能体、监控、生产访问和写入操作都需要单独授权。

## 模式

- **仅监控**：监控会话、PR、分支、CI 运行或转录记录，直至其进入终止状态。不要编辑。
- **审计**：对比请求、转录记录、差异、测试、CI、评论、截图和最终声明。不要编辑。
- **审计并修复**：先进行审计，然后针对明确且已获授权的缺漏进行小范围修复。
- **比较**：根据同一个原始请求比较多个智能体或会话。
- **接管**：明确请求接手停滞工作；遵循 [references/takeover.md](https://github.com/malinskibeniamin/skills/blob/main/agent-watchdog/references/takeover.md)，然后执行至请求的终点。不限于修补先前的方法。

如果编辑权限不明确，默认仅进行审计。

## 工作流程

接管模式使用其参考文档，而不是下面限定为小范围审计修复的步骤。

1. 确定每个目标：会话 ID、转录记录、对话串 URL、PR、分支、提交、CI 运行、议题、Slack 链接或粘贴的摘要。
2. 重建原始请求和约束；尽可能在阅读被观察智能体的结论前，先形成自己的假设。
3. 自行检查同一问题的一手证据，再与智能体的差异、检查和声明进行对照。注明此前已接触过哪些材料；在同一上下文中进行的调查不构成独立审查或跨模型家族审查。
4. 对每个问题进行分类：`Gap`、`Bug`、`Verification miss`、`Scope drift` 或 `No issue`。
5. 如果已获授权，仅修复明确的缺漏；除非收到请求，否则绝不还原无关工作或移动分支。
6. 报告确切证据、需要采取行动的差异、未解决风险和下一步操作。仅在当前步骤存在缺陷、需要纠正或遇到阻碍时打断正在运行的智能体；将其他已验证的缺漏汇总到下一个检查点，避免重复提示。

对于已完成的工作树，按照[远程交付验证](https://github.com/malinskibeniamin/skills/blob/main/shared/remote-completion.md)检查待处理文件和实际远程 HEAD。只读模式仅报告缺漏；已获授权的接管需要完成验证、提交和推送。

[来源和刷新步骤](https://github.com/malinskibeniamin/skills/blob/main/shared/BUILDER-SKILLS-CREDITS.md)。

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
