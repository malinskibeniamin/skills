---
title: /development-lifecycle
description: 从高级目标出发，完成 React、TypeScript 和 UI 实现，并进行自我验证。
type: skill
sidebar:
  label: /development-lifecycle
---
![/development-lifecycle 技能示意图](/diagrams/skills/development-lifecycle.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/development-lifecycle.excalidraw)

负责一个结果。使用[沟通规则](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)和[依赖加载规则](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 结果契约 [#outcome-contract]

编辑前：

- **目标** -- 高级最终状态。
- **约束** -- 无法推断的限制、保留给用户的决策、不可逆的边界。
- **验证** -- 能够区分真正完成与表面可行的检查或可观察行为。
- **停止条件** -- 请求的终点，以及确实需要用户介入的阻碍。

说明契约；构建、修复或实现请求应立即继续。

## 执行循环 [#loop]

**检查 -> 操作 -> 验证 -> 重复**

### 检查 [#inspect]

根据源证据解决盲点或易变的未知项。遵循现有惯用方式和已验证的规模；将事项分类为查阅、原型验证、可逆假设或暂停触发条件。

编辑前，加载 [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)并寻找有用的证据。对于任何可见改动，使用 [PR 视觉证据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)捕获基准状态并盘点影响面。细微的文案、样式改动以及共享 UI 的影响也包括在内。

### 操作 [#act]

一个负责人；委派和后台工作需要用户明确授权。做出最小且明显的改动；优先删除或复用，再考虑增加机制。对于重要行为，加载 [tdd](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)，在公开契约层面执行 RED -> 最小 GREEN -> REFACTOR；静态连接或保持行为不变的删除可以只进行针对性验证。证据发生变化时，重新规划受影响的部分。除非相邻清理工作会阻碍验证，否则仅将其作为问题报告。

### 验证 [#verify]

运行仓库中适用的测试、类型检查、代码检查、构建和静态检查。对重要的可运行行为加载 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；验证其实际入口以及一个可信的失败或恢复路径。根据目标、约束和可信风险审查结果。失败成为下一步操作；修复并重复。

缺少可重复的入口：使用一次性验证工具证明行为，然后将长期存在的缺口交由 `/create-verification-skill` 处理。

## 边界 [#boundaries]

仅在涉及保留给用户的决策，或不可逆的生产、法律/隐私、破坏性或高安全性操作时询问。对当前用户拥有的分支，可直接提交、推送、执行变基，并使用 `--force-with-lease`，无需再次请求许可。未经明确许可，绝不合并、使用普通强制推送、创建额外的 PR，或重写默认分支、共享分支、他人拥有或正被并行使用的分支。

在 main/master/develop 分支上编写代码前，使用 `scripts/mux-worktree.sh <type>/<branch-name>` 创建隔离的工作树。[ETHOS：工作树隔离]

将长期工作中的证据和暂停触发条件记录在被 git 忽略的 `.context/implementation-notes.md` 中。

## 完成 [#completion]

所有退出条件通过后，于请求的终点停止。验证或交付时阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/REFERENCE.md)；请求通过 Git 交付时加载 [commit-push-pr](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/SKILL.md)。
