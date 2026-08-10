---
title: /stay-within-limits
description: 检查明确请求的智能体批次所对应的 Claude 订阅窗口证据。
type: skill
sidebar:
  label: /stay-within-limits
---
![‌/stay-within-limits 技能示意图](/diagrams/skills/stay-within-limits.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/stay-within-limits.excalidraw)

此项需显式使用的兼容性技能保留了主机计量程序。模型选择、
质量门槛和批次路由现在由 `/efficient-frontier` 和
`config/model-routing.json` 负责。

仅当主机提供最新的 Claude Code 配额快照时，才使用 `select-review-profile.sh`。
`ccusage` 记录的是成本历史，而不是订阅容量证据。证据缺失或已过期
意味着 Claude 容量未知；不要猜测重置时间。

阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/stay-within-limits/REFERENCE.md)，了解快照捕获和选择器机制。返回
观测到的窗口及其新鲜度，然后让 `/efficient-frontier` 选择满足质量要求的
路由。显式使用绝不授予委派权限。

在此仓库中，运行 `bash stay-within-limits/select-review-profile.sh`。
