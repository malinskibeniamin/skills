---
title: /efficient-frontier
description: 应用由评测支撑的模型路由，并为经明确授权的智能体协作批次设定预算，同时不将判断权从负责人手中移走。
type: skill
sidebar:
  label: /efficient-frontier
---
![“/efficient-frontier”技能示意图](/diagrams/skills/efficient-frontier.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/efficient-frontier.excalidraw)

选择模型前，阅读[工具选择规则](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#protect-attention-while-working)。

`config/model-routing.json` 决定路由；不要把主观评分复制到提示词中。

1. 所有者：Opus 5.5 `xhigh`，负责日常工作、计划、代码和 UI。
2. Sol `xhigh` 通过 `/codex` 审查 PR；如果不可用，使用明确标注、采用干净上下文的 Opus `xhigh` 审查，并说明缺少跨模型家族覆盖。
3. UI、文案和 API 设计由 Opus 负责，taste >= 8。如果不可用，报告 UI 路径受阻，不要默默替换模型。
4. 琐碎任务由日常模型 Opus 直接处理。用户选用 Codex 时，由 Sol `xhigh` 执行任务、操作计算机或调查。
5. 仅选择 Opus/Sol 组合；绝不使用 `max`。如果两者都不可用，报告此路径受阻。历史评分不能覆盖所有者的偏好。
6. 跨模型家族审查需要明确授权；模型偏好本身不允许启动代理。
7. `ultra` 需要明确委派或 `/swarm`。Pro 模式、持久化推理、程序化工具和显式缓存仅限 API，除非运行环境开放这些功能。

由一位负责人实施；未委派时自行执行各路径。已授权路径有范围明确的目标、输入、排除项、证据和停止条件。负责人保留架构、优先级、风险、综合和验收责任。

## 容量

容量以 `/stay-within-limits` 主机计量为准；否则未知。绝不根据 token 或成本推断。容量只能排除路径，不能降低质量。

## 晋级

当前的 `xhigh` 默认值是所有者的明确选择，不是基于基准测试的晋升。
在未经请求的默认值变更前运行 `agent-evals/context-ablation/`：每次改变一个上下文组，保持任务和评分不变，只在质量相当的结果中选择更低成本。将胜出策略记录到 `config/model-routing.json`。

仅在编写已授权的委派任务包时，读取 [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md)。
