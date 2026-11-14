---
description: 在每个重要行为切片之后以及交接或发布之前使用，通过真实入口体验可运行工作。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - dogfood
sidebar:
  label: /dogfood
title: /dogfood
type: skill
---
![“/dogfood”技能示意图](/diagrams/skills/dogfood.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/dogfood.excalidraw)


检查行为或验证器时，请阅读 [Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#verification)。

每个重要可运行切片和最终 PR 都要在公共接缝处 dogfood。测试不是 dogfood。

## 清点 [#inventory]

1. 用
   `BASE=$(PR_BASE_REF="${DOGFOOD_BASE_REF:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`
   确定比较基线。
2. 从合并基点检查完整 PR，包括已提交、已暂存、未暂存和未跟踪工作。
3. 在真实入口覆盖变更的可运行分支，包括技能资源/脚本和钩子事件。
   独立文档、测试和评估不要求体验覆盖。

## 循环 [#loop]

运行使用 -> 滥用 -> 修复 -> 重放。

### 使用 [#use]

完成预期路径；检查输出、状态转换、副作用、控制台、网络和日志。

使用形状和基数接近生产的代表性真实规模数据。比较
预期与观察到的数量、顺序、耗时、状态和副作用；暴露累积问题。

对于缺陷，先在未修复行为上重放报告者的精确步骤。无法复现时，
在诊断前请求缺失环境或证据。

### 滥用 [#abuse]

尝试一种可信破坏方式：

- 粗心：空、无效、超大、重复或乱序输入。
- 急躁：重复、双击提交、重载、离开、取消或中断。
- 倒霉：陈旧或缺失数据、依赖缓慢或失败、部分完成。
- 真实数据：稀疏字段、重复 ID、混合版本或租户、长文本、Unicode、
  时区边界、真实基数。
- 性能：对照基线或预算测量响应时间、网络、渲染、CPU 和内存。

观察失败和恢复。

UI 内容/布局风险：使用 Skill 工具调用 "break-ui"。在重放和回执中复用符合数据模式的测试数据与证据；
只测试尚未覆盖的情况。无效输入的验证测试单独进行。

### 修复 [#repair]

缺陷会导致失败。可自动化时，先添加 RED 公共契约测试，
再通过 `/tdd` 修复并运行聚焦检查。编辑会使证据失效。

### 重放 [#replay]

在真实入口重复预期使用和每项破坏尝试。对于缺陷，重放完全相同的
步骤并检查相邻行为。对于有状态缺陷或复现缺口，使用[重放数据包](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md)。
PASS 绑定当前可运行状态。

## 入口 [#entrypoints]

| 变更 | 操作 |
|---|---|
| Web/UI | 运行、导航、操作、重载并检查控制台/网络 |
| CLI/TUI | 调用真实、无效和中断流程 |
| API/worker | 发送真实请求/事件，检查响应与副作用 |
| 库 | 从最小消费者调用公共 API |
| 钩子/自动化 | 用代表性夹具触发真实事件 |
| 技能/智能体 | 在全新真实任务上使用并检查行为 |
| 演示/原型 | 操作到问题获得可观察证据 |

新智能体需要明确授权委派。

如果存在项目本地的 `verify-*` 技能，请使用其中的 doctor、drive、evidence 和 cleanup。
仅在 T3 Code 检出目录中验证 UI 时：先解析[原生上下文](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context)，再加载 [Web/桌面验证](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-t3-app/SKILL.md) 或
[原生移动端验证](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/test-t3-mobile/SKILL.md)。缺少 Browser/Device 工具意味着验证
BLOCKED，而不是安装或切换到另一套验证工具。
验证器漂移交由 `/maintain-verification-skill` 处理；反复缺失的路径在得到证据后交由
`/create-verification-skill` 处理。

React：[运行时检查](https://github.com/malinskibeniamin/skills/blob/main/shared/react-devtools.md)。

## 浏览器和数据任务 [#browser-and-data-tasks]

阅读[浏览器默认设置](https://github.com/malinskibeniamin/skills/blob/main/shared/verification-replay.md#browser-and-data-tasks)。

## 回执 [#receipt]

`Verdict: PASS | FAIL | BLOCKED`；入口/操作/观察：

- **Entrypoint：** 精确命令、URL、事件或消费者。
- **Actions：** 使用流程和破坏尝试。
- **Observations：** 数据、输出、状态、副作用、控制台/网络/日志和耗时。
- **Repairs：** 缺陷、RED 测试、修复和重放结果。
- **Limits：** 未尝试行为及原因。

PASS：每项行为都有直接证据；FAIL：存在已观察缺陷；BLOCKED：缺失访问、
环境、硬件或安全条件。
