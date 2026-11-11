---
description: 为日常工作选择 Opus，为高难度技术工作选择 Fable，为审查选择 Sol；保留所选模型，并要求明确授权才能委派。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - efficient frontier
sidebar:
  label: /efficient-frontier
title: /efficient-frontier
type: skill
---
![“/efficient-frontier”技能示意图](/diagrams/skills/efficient-frontier.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/efficient-frontier.excalidraw)

仅在用户明确要求委派时，阅读 [Poteto 适配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#delegation)。

选择模型前，阅读[工具选择规则](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#protect-attention-while-working)。

`config/model-routing.json` 决定路由；不要把主观评分复制到提示词中。

1. 所有者：Opus 5.5 `xhigh`，负责日常工作、计划、代码和 UI。
   对 `quality_first.hard` 中列出的高难度任务使用 Fable 5.2 `xhigh`：重大迁移或重构、复杂架构或研究、长周期技术工作，或已观察到的 Opus 能力不足。先补齐上下文、工具和检查；任务长或一次测试失败本身不足以触发升级。
2. Sol `xhigh` 通过 `/codex` 审查 PR；如果不可用，使用明确标注、采用干净上下文的 Opus `xhigh` 审查，并说明缺少跨模型家族覆盖。
3. UI、文案和 API 设计由 Opus 负责，taste >= 8。如果不可用，报告 UI 路径受阻，不要默默替换模型。
4. 琐碎任务由日常模型 Opus 直接处理。用户选用 Codex 时，由 Sol `xhigh` 执行任务、操作计算机或调查。
5. 仅使用 Opus/Fable/Sol；绝不使用 `max`。报告 Fable 高难度任务路径不可用的情况；只有负责人明确选择时，才能在该路径改用 Opus。负责人偏好优先于历史评分。
6. 跨模型家族审查需要明确授权；模型偏好本身不允许启动代理。
7. `ultra` 需要明确委派或 `/swarm`。Pro 模式、持久化推理、程序化工具和显式缓存仅限 API，除非运行环境开放这些功能。

由一位负责人实施；未委派时自行执行各路径。已授权路径有范围明确的目标、输入、排除项、证据和停止条件。负责人保留架构、优先级、风险、综合和验收责任。

保留会话中明确选定的模型。任务符合高难度条件时，只在宿主支持选择的情况下选择 Fable 角色；这不授权递归调用、新建会话线程、使用付费额度或悄悄切换模型。确认宿主实际提供的模型及其精确标识符；报告缺失的路径，而不是使用会解析为其他模型的别名。
处理 Fable 任务、进行模型交接或修改 Claude 提示词时，请阅读[模型提示指南](https://github.com/malinskibeniamin/skills/blob/main/shared/model-prompting.md)。

## 容量 [#capacity]

容量以 `/stay-within-limits` 主机计量为准；否则未知。绝不根据 token 或成本推断。容量只能排除路径，不能降低质量。

## 晋级 [#promotion]

当前的 `xhigh` 默认值是所有者的明确选择，不是基于基准测试的晋升。
在未经请求的默认值变更前运行 `agent-evals/context-ablation/`：每次改变一个上下文组，保持任务和评分不变，只在质量相当的结果中选择更低成本。将胜出策略记录到 `config/model-routing.json`。

[任务包和来源](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/references/builder-upstream.md): 仅用于已获授权的委派。
