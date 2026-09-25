---
title: /efficient-frontier
description: 应用由评测支撑的模型路由，并为经明确授权的智能体协作批次设定预算，同时不将判断权从负责人手中移走。
type: skill
sidebar:
  label: /efficient-frontier
---
![“/efficient-frontier”技能示意图](/diagrams/skills/efficient-frontier.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/efficient-frontier.excalidraw)

读取 `config/model-routing.json`。它是模型路由的唯一事实来源；不要在提示词或技能中复述主观模型评分。

质量优先：

1. 选择最符合任务需求和可用运行环境的主要负责人。
2. 默认负责人：`high` 级别的 Claude Opus 5.5，负责 UI、代码、规划和审查。
3. 第二路径：通过 `/codex` 使用 `medium` 级别的 GPT-6 Sol，负责规格明确的执行、独立审查、计算机操作和调查。如果 Sol 不可用，请使用 `high` 级别的 Astra 并注明后备；绝不使用更便宜的 GPT 模型。
4. 面向用户的工作（UI、文案、API 设计）需要品味评分 taste >= 8 且由 Claude 负责；仅当没有可用的 Claude 负责人时，才使用明确注明的 Astra 作为后备。
5. 琐碎工作交给 `high` 级别的 GPT-6 Luna：小改动、无冲突的 rebase、机械性的 CI 修复、只读的检索或列表。遇到冲突、需要诊断或判断时，升级到 Sol。
6. Fable 5.1（最高 `high`）仅在用户明确要求处理特殊工作时使用。仅当上下文消融结果支持，或用户明确选择时，才使用 `xhigh`/`max`。
7. 除非用户明确授权使用不同模型系列进行一轮审查，否则审查工作仍由主要负责人承担。
8. `ultra` 表示多智能体团队，需要明确委派或使用 `/swarm`。专业模式、持久化推理、程序化工具调用和显式缓存控制仅限 API 使用，除非当前运行框架提供这些功能。

由一名负责人执行实现。未经明确委派时，直接执行所有有用的工作分支。获得委派授权后，为每个工作分支指定一个边界明确的目标、输入、排除项、证据约定和停止条件。架构设计、优先级排序、风险管理、成果整合和最终验收仍由协调者负责。

## 容量

可通过明确的 `/stay-within-limits` 主机计量流程检查 Claude 订阅容量。容量未知时，应报告为未知。绝不要根据本地令牌数或成本推断容量。容量可以排除某条路由，但不能降低质量门槛。

## 晋级

更改默认设置前，运行 `agent-evals/context-ablation/`。每次比较一个上下文组，保持任务和评分标准不变，并且只在质量相当的结果中选择成本更低的方案。将胜出的策略记录在 `config/model-routing.json` 中。

仅在编写已授权的委派任务包时，读取 [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md)。
