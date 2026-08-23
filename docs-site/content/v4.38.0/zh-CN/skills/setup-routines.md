---
title: /setup-routines
description: 配置 Claude Code 例程，用于 PR 审查、代码库健康检查、问题分类和文档偏差检测。
type: skill
sidebar:
  label: /setup-routines
---
![《/setup-routines》技能示意图](/diagrams/skills/setup-routines.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/setup-routines.excalidraw)

配置 [Claude Code 例程](https://claude.ai/code/routines)——由定时计划、GitHub 事件或 API 触发的云端托管自动化会话。例程会克隆仓库，并作为完整的 Claude Code 会话运行。钩子和 CLAUDE.md 规则会自动执行约束。

## 工作原理

```
Routine fires -> clones repo -> SessionStart hooks -> CLAUDE.md loads
-> routine prompt executes -> PostToolUse hooks enforce on every edit
-> Stop hooks run quality gates -> session ends
```

### 约束模型

钩子 = 约束层 | 例程提示词 = 任务层。规范在仓库中演进
（钩子 + CLAUDE.md），例程提示词保持稳定。每个例程
会话都会运行与交互式开发会话相同的 PostToolUse/Stop 门禁，
因此例程无法交付开发者在本地无法交付的代码。
对于例程输出，请添加 `/agent-watchdog` 审计步骤。仅当
例程请求明确要求该产物时，才添加 `/visual-recap`。


例程是由定时计划/webhook/API 触发的云端托管会话——
即使笔记本电脑关闭，也必须能够继续运行的周期性自动化任务。

## 可用模板

| 模板 | 触发器 | 功能 |
|---|---|---|
| [pr-review](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/pr-review.md) | `pull_request.opened` | 根据规范审查 PR，并发布行内评论 |
| [pr-feedback-resolve](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/pr-feedback-resolve.md) | `pull_request.review_submitted` | 读取未解决的讨论串、修复代码、回复并标记为已解决 |
| [issue-triage](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/issue-triage.md) | `issues.opened` | 探索代码库、分类、添加标签并发布调查结果 |
| [weekly-health](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/weekly-health.md) | 定时计划：每周 | 运行质量检查、衡量偏差并创建健康报告议题 |
| [docs-drift](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/routines/docs-drift.md) | 定时计划：每周 | 根据近期变更检测过时文档，并创建修复 PR 或议题 |

## 设置

### 1. 前提条件

- 可访问网络的 Claude Code（[claude.ai/code](https://claude.ai/code)）
- 已连接 GitHub（在 CLI 中运行 `/web-setup`）
- Pro、Max、Team 或 Enterprise 方案

### 2. 选择例程

| 如果你已具备 | 推荐例程 |
|---|---|
| 已安装任意钩子 | pr-review |
| resolve-pr-feedback 技能 | pr-feedback-resolve |
| triage 技能 | issue-triage |
| 质量门禁钩子/脚本 | weekly-health |
| REFERENCE.md 或其他文档 | docs-drift |

### 3. 通过网页创建（推荐）

1. [claude.ai/code/routines](https://claude.ai/code/routines) -> **新建例程**
2. 输入名称（例如“PR 审查 -- [仓库名称]”）
3. 粘贴 `routines/*.md` 中的模板——自定义 `OWNER`/`REPO` 占位符
4. 选择仓库和环境
5. 添加触发器（GitHub 事件 | 定时计划 | API）
6. 检查连接器——移除不需要的连接器
7. 创建

### 4. 通过 CLI 创建

```bash
/schedule daily codebase health check at 9am
```

CLI = 仅支持定时例程。GitHub/API 触发器 -> 使用网页界面。

### 5. 自定义提示词

模板 = 起点。可自定义：

- **项目特定检查**：引用钩子强制执行的模式
- **标签**：与议题标签分类体系保持一致
- **范围边界**：“仅审查 `src/`”或“跳过生成的文件”
- **连接器操作**：“将摘要发布到 #engineering Slack”

有关自定义示例和 API 触发器设置，请参阅 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/REFERENCE.md)。

### 6. 测试

在信任触发器之前，先手动运行一次：

1. 网页：在例程详情页面点击**立即运行**
2. CLI：`/schedule run`
3. 通过返回的 URL 实时查看会话
4. 检查输出——如果例程偏离目标，请调整提示词
请参阅 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/setup-routines/REFERENCE.md)：约束模型、触发器/API/自定义设置和故障排除。
