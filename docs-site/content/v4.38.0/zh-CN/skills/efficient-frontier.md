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
2. 默认使用 `xhigh` 级别的 GPT-5.6 Sol；Sol 可以负责 UI、实现、规划、审查和计算机操作。
3. 仅当上下文消融结果证明效果有所提升，或用户明确选择时，才对困难的质量优先型工作使用 `max`。
4. 将 Terra 和 Luna 视为需要通过评测准入的模型。在版本化行为评测批准相应用途之前，不要将产品代码或审查工作交给它们。
5. Fable 或 Opus 可在可用且质量达标时负责工作。除非用户明确授权使用不同模型系列进行一轮审查，否则审查工作仍由主要负责人承担。
6. `ultra` 表示多智能体团队，需要明确委派或使用 `/swarm`。专业模式、持久化推理、程序化工具调用和显式缓存控制仅限 API 使用，除非当前运行框架提供这些功能。

由一名负责人执行实现。未经明确委派时，直接执行所有有用的工作分支。获得委派授权后，为每个工作分支指定一个边界明确的目标、输入、排除项、证据约定和停止条件。架构设计、优先级排序、风险管理、成果整合和最终验收仍由协调者负责。

## 容量

可通过明确的 `/stay-within-limits` 主机计量流程检查 Claude 订阅容量。容量未知时，应报告为未知。绝不要根据本地令牌数或成本推断容量。容量可以排除某条路由，但不能降低质量门槛。

## 晋级

更改默认设置前，运行 `agent-evals/context-ablation/`。每次比较一个上下文组，保持任务和评分标准不变，并且只在质量相当的结果中选择成本更低的方案。将胜出的策略记录在 `config/model-routing.json` 中。

仅在编写已授权的委派任务包时，读取 [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/efficient-frontier/references/builder-upstream.md)。
