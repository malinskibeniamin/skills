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

审计前阅读[审计协议](https://github.com/malinskibeniamin/skills/blob/v4.45.0/agent-watchdog/references/audit.md)；审计复杂或含义不明确时，阅读 `references/builder-upstream.md`。
使用已获授权的来源和宿主实际提供的工具。自行开展调查；额外智能体、监控、生产访问和写入操作都需要单独授权。

## 模式 [#modes]

- **仅监控：**监控会话、PR、分支、CI 或转录记录，直至进入终止状态；不要编辑。
- **审计：**对比请求、证据、差异、测试、CI、评论和声明；不要编辑。
- **审计并修复：**先审计，再进行范围有限且已获授权的修复。
- **比较：**依据同一请求评估智能体或会话。
- **接管：**明确要求接管受阻的工作；遵循[接管规则](https://github.com/malinskibeniamin/skills/blob/v4.45.0/agent-watchdog/references/takeover.md)执行至请求的终点，不限于原先的方法。

如果编辑权限不明确，默认仅进行审计。

## 工作流程 [#workflow]

接管使用其参考文档；其他模式按以下步骤执行：

1. 确定目标、原始请求和约束；先形成自己的假设。
2. 检查一手证据；对照智能体的差异、检查和声明。
3. 注明此前已接触过哪些材料；同一上下文中的调查不构成独立审查或跨模型家族审查。
4. 分类为 `Gap|Bug|Verification miss|Scope drift|No issue`。
5. 仅修复已获授权的缺漏；绝不还原无关工作或擅自移动分支。
6. 报告确切证据、需要行动的差异、风险和下一步；传递提示、处理已完成工作树及组织输出时，遵循审计协议。
