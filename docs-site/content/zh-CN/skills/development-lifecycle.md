---
description: 从高级目标出发，完成 React、TypeScript 和 UI 实现，并进行自我验证。
related:
  - /skills/tdd
  - /skills/review
search:
  boost: 3
  keywords:
    - development lifecycle
    - work
    - implementation
    - development workflow
sidebar:
  label: /development-lifecycle
title: /development-lifecycle
type: skill
---
![/development-lifecycle 技能示意图](/diagrams/skills/development-lifecycle.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/development-lifecycle.excalidraw)

进行多步骤实现或发布时，请阅读 [Poteto 适配指南](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#execution)。

作者入口：`/work`。负责一个结果。编辑前阅读[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)，明确归属、隔离和终点。遵循[沟通约定](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#admit-work-by-priority)及[依赖加载规则](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 结果契约 [#outcome-contract]

编辑前：

- **目标** -- 高级最终状态。
- **约束** -- 无法推断的限制、保留给用户的决策、不可逆的边界。
- **验证** -- 能够区分真正完成与表面可行的检查或可观察行为。
- **停止条件** -- 请求的终点，以及确实需要用户介入的阻碍。

说明契约；构建、修复或实现请求应立即继续。
在该终点范围内[自动补齐使用方仓库的审查保障](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md)。

## 执行循环 [#loop]

**检查 -> 操作 -> 验证 -> 重复**

### 检查 [#inspect]

阅读工单、正文、标签和评论；明确标题和引用。通过查阅、探查、可逆假设或暂停来解决盲点和易变的未知项；遵循仓库惯例和已验证的规模。

编写前阅读适用范围的规范，并从脚本、配置和 CI 中确定仓库原生的格式化、lint、类型检查和受影响测试命令。记录相关的基线失败；沿用已安装的工具链。

处理 T3 检出或 Effect 代码时，以 `work` 为入口解析[原生上下文](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context)；在整个循环中使用返回的目标项目指南和范围检查。

加载[变更证据路由](https://github.com/malinskibeniamin/skills/blob/main/shared/change-evidence.md)及相关负责技能。评估可信风险；仅在视觉对比有用或明确要求时于编辑前捕获基线。复用现有测试、辅助工具和有效证据。

依据固定评估反复优化时，加载 [hill-climb](https://github.com/malinskibeniamin/skills/blob/main/hill-climb/SKILL.md)。

[Figma/图片](https://github.com/malinskibeniamin/skills/blob/main/jakubkrehel-skills/build-design/SKILL.md)。

### 操作 [#act]

代码库属于用户；对本次变更负责，而不是进行无关的重新设计。诊断常规工具故障并重试安全的检查；对结果不确定的写入，先读取状态再决定是否重试。等待开放问题的答复时，继续不依赖该答复的工作；尊重有意设置的访问边界。

一个负责人；委派和后台工作需要明确授权。遵循本地惯例，采用能正常工作的最小改动。对可信且尚未覆盖的回归使用 [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)；其他情况用现有检查或探针即可。仅重新规划受影响部分；避免推测性抽象和顺手清理。

每完成一批逻辑完整的编辑，先运行限定范围的格式化或自动修复及 lint，再运行相关的类型检查和测试。只有文件内容和检查覆盖范围完全相同时，才可复用已完成的钩子结果。检查自动修复的差异；修复失败并重新运行。当按文件限定范围不可靠时，保留整个项目的类型检查。

更改导入边或处理循环依赖／barrel 文件诊断时，请使用[基于依赖图的检查循环](https://github.com/malinskibeniamin/skills/blob/main/shared/check-loop.md#import-cycles-and-barrels)。

### 验证 [#verify]

交回每个实现回合前，针对受影响范围运行仓库要求的格式化、lint、类型、测试、构建和静态检查门禁；内循环的局部检查绝不替代必需的最终门禁。对重要的可运行行为加载 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；验证其实际入口以及一个可信的失败或恢复路径。审查目标、约束和可信风险：检查通过并不证明构建了正确的东西。失败成为下一步操作；修复并重复。单独报告无关的基线失败，绝不将其描述为全部通过。

修复原因，而不是修改门禁来掩盖问题。绝不通过类型逃生舱、抑制检查、跳过或削弱测试、扩大排除范围、降低严格程度或隐藏失败退出码来获得通过结果。错误的检查需要证据和明确的工具变更理由，并用应失败和应通过的案例证明修正后的规则仍能检测目标缺陷。

缺少可重复的入口：使用一次性验证工具证明行为，然后将长期存在的缺口交由 `/create-verification-skill` 处理。

## 边界 [#boundaries]

仅对用户保留的决定，或不可逆的生产、法律、隐私、破坏性及高安全风险操作询问。只有长期任务需要检查点时才复用现有笔记；常规工作无需证据或检查清单文件。

## 完成 [#completion]

阅读并执行[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)：内联自审、适用证据、发布以及请求的 CI/反馈跟进。复用当前验证；所有退出条件满足后，在请求的终点停止。[重构](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md#refactor-branch)。
