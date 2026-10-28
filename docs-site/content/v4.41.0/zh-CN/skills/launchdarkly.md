---
description: 通过 ldcli 检查 LaunchDarkly 标志：存在状态、受众、影响范围、生命周期与 Integration 和 Production 清理候选。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - launchdarkly
sidebar:
  label: /launchdarkly
title: /launchdarkly
type: skill
---
![Diagram of the /launchdarkly skill](/diagrams/skills/launchdarkly.svg)

[Open the editable Excalidraw source](/diagrams/skills/launchdarkly.excalidraw)


LaunchDarkly 操作仅使用官方 `ldcli`。先读[CLI 预检](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/ldcli.md)，复用现有身份验证，不输出令牌或配置。审计请求只允许读取：“能否清理此标志？”是在寻求建议，并不授权修改定向、弃用、归档、删除标志或移除代码。

## 范围 [#scope]

从请求或仓库配置确定项目。否则查看 `ldcli projects list --help`，列出项目并询问选择；不要默认使用 `default`。声称覆盖整个账户之前，必须完成分页。

**仅检查 Integration (`integration`) 和 Production (`production`)。** 使用 `ldcli environments list` 确认准确键值。必需环境缺失或无权访问意味着未知，而不是空或关闭。清理启发式忽略测试、staging、preproduction、development 等未使用环境。若项目采用其他键值，先确认映射再调整命令，不得悄悄替换环境。

## 检查标志 [#inspect-a-flag]

先读 `ldcli flags get --help`，再获取两个环境的完整配置。报告是否存在、创建时间、归档/弃用状态、定向开关和实际返回值。区分标志不存在与身份验证、权限、项目、环境错误。不存在并不授权创建；仅在用户提出要求时遵循[CLI 修改流程](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/ldcli.md#change)。

回答“谁能看到？”时，追踪默认变体、指定上下文、按顺序执行的规则、分群、百分比/实验发布和前置依赖。仅有 `on: true` 不代表所有人都获得该功能。通过 `variations[].value` 解析索引，不能假设索引零表示启用。避免无必要地暴露上下文标识符。将功能受众与控制台权限、维护者区分开。对于多变量标志，先确定哪个值表示启用，否则报告未知。

进行依赖、代码引用或归档分析时，阅读[生命周期与证据](https://github.com/malinskibeniamin/skills/blob/v4.41.0/launchdarkly/references/lifecycle.md)。

## 统计长期启用的清理候选 [#count-long-enabled-cleanup-candidates]

在本技能安装目录中，使用 Bun 执行：

```bash
bun run scripts/audit.ts --project <project-key>
```

命令会分页获取清单，通过 `--summary 0` 获取完整定向，并用 `ldcli` 检查指定范围的变更历史。不会写入 LaunchDarkly。原始输出只保存在本地，不得提交或放入公开 PR。

按 UTC `auditedAt` 判断，每个未归档标志仅统计一次，且必须同时满足：

- 创建时间**严格早于 30 × 24 小时前**。
- **Integration 和 Production** 均开启定向，所有可能的默认、规则、指定目标及正权重发布结果都返回布尔值 `true`。
- 选定配置和标志历史在**过去 14 × 24 小时内**没有变更。恰好位于截止时间的变更也应排除。使用选定环境的资源标识过滤历史，避免未使用环境的编辑导致误排除；影响所选范围的共享元数据变更仍计入。

未解析的前置依赖、非布尔启用值、格式错误或缺失的定向、不可访问的历史均为**未知**，不是已确认候选。声称精确总数之前必须解决。候选指的是**移除标志判断，同时保留已发布功能**，不等于关闭功能，也不等于现在就能安全归档。

## 返回证据 [#return-evidence]

先给出 `candidateCount`、项目、两个环境键、UTC 审计时间和 `scannedCount`。列出候选键及 `createdAt`、`lastTargetingChangeAt`；后者不是全局最后修改时间。说明被忽略的环境和未知项。`exactCount: null` / 退出码 2 代表下界；退出码 1 代表清单获取失败，没有可靠数量。只汇总完整的项目报告；权限受限的令牌不能证明已覆盖整个账户。

另列归档阻碍。读取快照并非原子操作，行动前应重新审计。报告完成后停止，除非用户明确要求修改。
