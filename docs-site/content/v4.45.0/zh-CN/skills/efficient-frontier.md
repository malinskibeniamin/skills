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

委派时阅读 [Poteto 适配指南](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/POTETO-NATIVE.md#delegation)。
遵循[工具选择规则](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/communication.md#protect-attention-while-working)。

角色由 `config/model-routing.json` 定义；不要在提示词中加入主观评分。

1. Opus 5.5 `xhigh`：日常工作、计划、代码和 UI。Fable 5.2 `xhigh`：`quality_first.hard`。先补齐上下文、工具和检查；任务很长或单次测试失败本身不是升级理由。
2. Sol `xhigh` 通过 `/codex` 审查；不可用时，使用明确标注的干净上下文 Opus `xhigh` 审查，并说明缺少跨模型家族覆盖。
3. Opus 负责 UI、文案和 API 设计（taste >= 8）；不可用时报告受阻。
4. 琐碎任务：在当前 Opus 上直接处理；用户选用 Codex 后的执行、计算机操作和调查：Sol。
5. 仅使用 Opus/Fable/Sol；绝不使用 `max`。报告 Fable 不可用；只有所有者选择时才以 Opus 替代。
6. 跨模型家族审查需要用户明确授权；路由不是启动智能体的许可。
7. `ultra`：明确委派或 `/swarm`；仅限 API 的功能见[参考文档](https://github.com/malinskibeniamin/skills/blob/v4.45.0/codex/REFERENCE.md#routing-notes)。

保留所选模型和终点；确认宿主的模型标识与访问权限。路由不授权递归调用、新线程、付费额度或静默切换。未获委派授权时直接处理。任务简报限定目标、输入、排除项、证据和停止条件；最终验收由所有者负责。
使用 Fable、交接任务或修改提示词时，阅读[模型提示指南](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/model-prompting.md)。

## 容量 [#capacity]

`/stay-within-limits`：使用宿主计量，否则容量未知；绝不从 token 数或费用推断，也不降低质量。

## 升级 [#promotion]

所有者选定的 `xhigh` 不代表评估胜出。未经请求的变更：运行 `agent-evals/context-ablation/`；每次只改变一组上下文，固定任务和评分，只在质量相同时选择更低成本，并将胜出方案记录到路由配置。

[委派资料包](https://github.com/malinskibeniamin/skills/blob/v4.45.0/efficient-frontier/references/builder-upstream.md)。
