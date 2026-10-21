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

作者入口：`/work`。负责一个结果；自动选择辅助技能。编辑前阅读[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)，明确归属、隔离和终点。遵循[沟通约定](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)及[依赖加载规则](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

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

根据源证据解决盲点或易变的未知项。遵循现有惯用方式和已验证的规模；将事项分类为查阅、原型验证、可逆假设或暂停触发条件。

处理 T3 检出或 Effect 代码时，以 `work` 为入口解析[原生上下文](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context)；在整个循环中使用返回的目标项目指南和范围检查。

编辑前加载[变更证据路由](https://github.com/malinskibeniamin/skills/blob/main/shared/change-evidence.md)及适用的负责技能。按比例评估影响；可见编辑前先捕获基线，包括细小文案和共享 UI 的影响。

### 操作 [#act]

一个负责人；委派和后台工作需要用户明确授权。做出最小且明显的改动；优先删除或复用，再考虑增加机制。对于重要行为，加载 [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)，在公开契约层面执行 RED -> 最小 GREEN -> REFACTOR；静态连接或保持行为不变的删除可以只进行针对性验证。证据发生变化时，重新规划受影响的部分。除非相邻清理工作会阻碍验证，否则仅将其作为问题报告。

### 验证 [#verify]

运行仓库中适用的测试、类型检查、代码检查、构建和静态检查。对重要的可运行行为加载 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；验证其实际入口以及一个可信的失败或恢复路径。根据目标、约束和可信风险审查结果。失败成为下一步操作；修复并重复。

缺少可重复的入口：使用一次性验证工具证明行为，然后将长期存在的缺口交由 `/create-verification-skill` 处理。

## 边界 [#boundaries]

仅对用户保留的决定，或不可逆的生产、法律/隐私、破坏性、高安全风险操作询问。将证据和暂停条件保存在已忽略的 `.context/implementation-notes.md`。

## 完成 [#completion]

阅读并执行[作者交付](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)：内联自审、适用证据、发布以及请求的 CI/反馈跟进。复用当前验证；所有退出条件满足后，在请求的终点停止。[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md)包含针对任务的探针。
