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

1. 负责人：Opus 5.5 `high`（UI、代码、计划）。
2. 第二路径：通过 `/codex` 使用 Sol `medium`（明确规格的执行、电脑操作、调查）；不可用 -> 明确标注的 Astra `high`，绝不使用更便宜的 GPT。
3. Astra `high` 审查 PR，必要时使用 Opus 5.5 `high`；Codex 剩余用量 >=50% 时才使用 `xhigh`。
4. UI、文案、API 设计：taste >= 8 且由 Claude 负责，否则使用明确标注的 Astra 备用。
5. 琐碎工作：Luna `high`（小幅修改、无冲突的 rebase、机械式 CI 修复、只读列表）；冲突、诊断、判断 -> Sol。
6. Fable 5.1（最高 `high`）：明确请求，仅限特殊工作。`xhigh`：上下文消融证据或用户选择；绝不使用 `max`。
7. 由用户明确授权不同模型系列的检查。
8. `ultra` 需要明确委派或 `/swarm`。Pro 模式、持久化推理、程序化工具、显式缓存：仅限 API，除非环境已提供。

由一位负责人实施；未委派时自行执行各路径。已授权路径有范围明确的目标、输入、排除项、证据和停止条件。负责人保留架构、优先级、风险、综合和验收责任。

## 容量

容量以 `/stay-within-limits` 主机计量为准；否则未知。绝不根据 token 或成本推断。容量只能排除路径，不能降低质量。

## 晋级

更改默认设置前，运行 `agent-evals/context-ablation/`。每次比较一个上下文组，保持任务和评分标准不变，并且只在质量相当的结果中选择成本更低的方案。将胜出的策略记录在 `config/model-routing.json` 中。

仅在编写已授权的委派任务包时，读取 [references/builder-upstream.md](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md)。
