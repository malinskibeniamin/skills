---
title: /codex
description: 通过 Codex CLI 将任务委派给 GPT-5.6。适用于规格明确的实现、独立审查、计算机操作、调查、数据分析或大量消耗令牌的机械性工作。
type: skill
sidebar:
  label: /codex
---
![／codex 技能示意图](/diagrams/skills/codex.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/codex.excalidraw)

**宿主环境门控：**此路径由 Claude 托管。在原生 Codex 中，除非用户明确要求委派或使用并行智能体，否则应直接在当前上下文中工作。不要递归启动 `codex exec`；保留所选模型和推理强度；不要重写 Codex 配置。

每个会话检测一次能力：

```bash
codex exec -m gpt-5.6-sol "reply OK"
```

如果不可用，请使用当前可用的最强 GPT，并明确标注。若 CLI 不可用，则跳过此路径并记录原因。

## 路由变体

| 变体 | 强度 | 用途 |
|---|---|---|
| Sol | `xhigh`；有评测依据或明确选择时使用 `max` | 代码、UI、审查、规划、计算机操作 |
| Terra | 取决于能力 | 通过评测门控的非代码工具循环 |
| Luna | 取决于能力 | 通过评测门控的低风险工具循环 |

选择之前请阅读 `config/model-routing.json`。不要根据价格或名称推断变体质量。有关跨提供商门控和 CLI 机制，请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/codex/REFERENCE.md)。

## 提示词约定

Codex 看不到本次对话的任何内容。每个提示词都应注明仓库和分支、目标、范围和排除项、验收标准、适用的技能规则和范例、确切的验证命令、证据格式以及停止条件。仅发送差异和当前任务的局部上下文；排除机密信息和无关文件。

**引导载荷：**对于实现工作，将匹配的路径专属规则和匹配的 `exemplars/` 文件直接写入提示词。

## 模式

- **实现：**`codex exec -m gpt-5.6-sol -c 'model_reasoning_effort="xhigh"'`；在工作树中隔离并发写入。
- **审查：**优先使用与作者不同的模型系列。由 Sol 编写的工作可以使用 Claude 的高质量替代模型；后备方案是明确标注的、使用干净上下文的 Sol 审查。使用 `-s read-only` 模式和 P0-P3 级别的证据。
- **对抗式交流（在 Claude 托管的工作流中自动进行）：**获得授权时使用不同的模型系列；将结果视为一条评估路径，而非最终裁决。
- **计算机操作：**注明 URL/应用、状态和证据。
- **调查/分析：**使用 `-s read-only` 并提供精简报告。

## 工作流

1. 通过宿主环境和授权门控。
2. 从 `config/model-routing.json` 中选择质量合格的路由。
3. 编写自包含的提示词约定。
4. 使用明确的超时时间或参考文档中的后台运行模式执行。
5. 集成之前，核实引用的文件、命令和高风险结论。

需要大量判断的架构设计、综合分析、产品、安全和最终审查工作由前沿协调器负责。Sol 可以负责面向用户的输出，但必须满足相同的视觉证据门控。
