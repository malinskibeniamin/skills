---
title: /codex
description: 通过 Codex CLI 将任务委派给 GPT-6.1 Sol。适用于规格明确的实现、独立审查、计算机操作、调查、数据分析或大量消耗令牌的机械性工作。
type: skill
sidebar:
  label: /codex
---
![／codex 技能示意图](/diagrams/skills/codex.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/codex.excalidraw)

**宿主环境门控：**此路径由 Claude 托管。在原生 Codex 中，除非用户明确要求委派或使用并行智能体，否则应直接在当前上下文中工作。不要递归启动 `codex exec`；保留所选模型和推理强度；不要重写 Codex 配置。

仅在委派获授权后检测能力：`codex exec -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"' "reply OK"`。如果不可用，使用明确标注、采用干净上下文的 Opus 5.5 `xhigh` 审查，并说明缺少跨模型家族覆盖。仅选择 Opus 5.5 和 GPT-6.1 Sol；如果两者都不可用，报告此路径受阻。

## 路由

| 变体 | 用途 |
|---|---|
| Sol，`xhigh`（`gpt-6.1-sol`；绝不使用 `max`） | 首选 PR 审查者；明确选用时执行任务、操作计算机或调查 |
| Opus 5.5，`xhigh`（`claude-opus-5-5`） | 日常工作、UI、计划、代码、琐碎任务；明确标注的干净上下文审查后备 |

阅读 `config/model-routing.json`；不要根据名称或价格推断质量。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md) 规定提供商门控和 CLI 机制。

## 提示词约定

Codex 看不到本次对话的任何内容。每个提示词都应注明仓库和分支、目标、范围和排除项、验收标准、适用的技能规则和范例、确切的验证命令、证据格式以及停止条件。仅发送差异和当前任务的局部上下文；排除机密信息和无关文件。

**引导载荷：**对于实现工作，将匹配的路径专属规则和匹配的 `exemplars/` 文件直接写入提示词。

## 模式

- **实现：**`codex exec -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"'`；在工作树中隔离并发写入。
- **审查：** Sol `xhigh`：`codex exec -s read-only -m gpt-6.1-sol -c 'model_reasoning_effort="xhigh"'`；提供 P0–P3 证据。不要用猜测的用量阈值改变所有者选定的推理等级。
- **对抗审查：** 仅限 Claude 宿主且已获授权；只是一条审查路径，不是最终结论。
- **计算机操作：**注明 URL/应用、状态和证据。
- **调查/分析：**使用 `-s read-only` 并提供精简报告。

## 工作流

1. 通过宿主环境和授权门控。
2. 从 `config/model-routing.json` 中选择质量合格的路由。
3. 编写自包含的提示词约定。
4. 使用明确的超时时间或参考文档中的后台运行模式执行。
5. 集成之前，核实引用的文件、命令和高风险结论。

架构、综合分析、产品、安全和最终判断由协调器负责。默认情况下，Codex 模型不负责面向用户的 UI、文案或 API 设计。这些界面由 Opus 5.5 负责；如果不可用，报告此路径受阻。
