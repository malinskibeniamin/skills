---
description: 将当前会话压缩为交接文档，供其他代理或新会话使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - handoff
sidebar:
  label: /handoff
title: /handoff
type: skill
---
![／handoff 技能示意图](/diagrams/skills/handoff.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/handoff.excalidraw)

分别调用 Skill 工具："agent-watchdog" 用于其他执行的声明；"plan-arbiter" 用于竞争方案。其他宿主：[加载依赖](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 步骤

1. 使用宿主临时目录（`$TMPDIR`，否则 `/tmp`；Windows `%TEMP%`），不要写入工作区。Unix：`handoff_file=$(mktemp "${TMPDIR:-/tmp}/handoff-XXXXXX")`。
2. 按[继续执行契约](https://github.com/malinskibeniamin/skills/blob/main/shared/progress-evidence.md#continuation)保留请求的终点。参数只聚焦下一步，不替换任务或授予权限。
3. 不要复制现有产物；改用链接。遮蔽敏感数据。标明不确定性及影响复现的省略内容。
4. 返回路径和 1-2 句摘要。尚无有效进展时，写一份简短的起始说明。

仅当用户明确请求后台代理时：检查 `command -v claude`，再用 `claude --bg --name "<name>" "<summary>"` 代替文件，并包含 `/agent-watchdog`。失败时返回命令和摘要，不声称已启动。

## 模板

```markdown
# Handoff
契约：<原始目标、请求的终点/停止限制、保留的决策>
状态：<仓库/工作树/分支、HEAD/基准、未提交范围、PR/议题、检查证据>
决策/产物：<链接、证据限制、重放数据包/命令>
下一步：<重点、操作、未决事项、验证/交付>
建议技能：<后续技能及原因>
```
