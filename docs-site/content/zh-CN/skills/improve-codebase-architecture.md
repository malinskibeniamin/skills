---
title: /improve-codebase-architecture
description: 重新设计模块边界、所有权和状态，使反复出现的错误类别无法发生。
type: skill
sidebar:
  label: /improve-codebase-architecture
---
![/improve-codebase-architecture 技能示意图](/diagrams/skills/improve-codebase-architecture.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/improve-codebase-architecture.excalidraw)

寻找能让整类错误无法发生的架构变更。深化设计，而不是仅仅增加另一项检查或回归测试。

此技能仅适用于架构。通用审计、待办事项、正确性、安全性、性能、依赖项或文档工作属于 `/improve`。实现工作属于 `/development-lifecycle`；此工作流保持只读。

## 术语与标准

运行 `/codebase-design`。准确使用**模块**、**接口**、**实现**、**深度**、**深层**、**浅层**、**接缝**、**适配器**、**杠杆效应**和**局部性**这些术语。

- **删除测试：**删除一个深层模块会把它隐藏的复杂性扩散到调用方。
- **接口就是测试表面：**测试通过稳定接口验证设计。
- **两个适配器才能证明接缝合理：**只有一个适配器时，抽象仍是假设性的。
- **单一事实来源：**派生行为来自由其所有者管理的表示，而不是并行的列表、标志、注册表、验证器或生命周期。
- **结构性不变量：**构造和状态转换使无效状态在下游无法发生或无法表示。

如果存在 `CONTEXT.md` 和相关 ADR，请阅读它们。领域语言为良好的模块和接缝命名；ADR 防止在没有新证据时反复争论持久决策。

## 1. 界定范围并探索

**扫描前先限定范围——YAGNI。**如果用户指定了模块、错误模式或痛点，就采用该范围。否则，使用 `git log --name-only --format=` 查找经常变更的热点；仅在历史记录分散时扩大范围。

默认直接在当前流程中探索。委派需要用户明确同意。优先使用仓库原生的图工具。梳理模块接口、依赖图或调用图、数据所有权、相互竞争的写入方、状态转换、失败路径，以及当前接口上的测试。

## 2. 寻找结构性机会

阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/improve-codebase-architecture/REFERENCE.md)，了解架构分析视角和候选项淘汰规则。优先选择以下设计：用单一事实来源取代并行记账，用经过验证的构造取代重复验证，用显式状态取代非法标志组合，并用一个深层模块接口取代由调用方负责的编排。

对每个可疑点，说明**错误类别**、当前过于宽松的表示、拟议不变量，以及其他调用方为何无法再次造成同一错误。回归测试本身并不构成架构；测试应在目标不变量建立后验证设计。

## 3. 提交候选方案

将自包含的 HTML 报告写入操作系统临时目录：`$TMPDIR/architecture-review-<timestamp>.html`，无法使用时回退到 `/tmp` 或 `%TEMP%`。打开报告并返回绝对路径。阅读 [HTML-REPORT.md](https://github.com/malinskibeniamin/skills/blob/main/improve-codebase-architecture/HTML-REPORT.md)；当可编辑的前后对比图有助于论证时，使用 `/excalidraw-diagram`。

每个候选方案都必须包含文件和证据、错误类别、当前与拟议不变量、所有权变更、模块/接口/接缝变更、前后对比图、局部性/杠杆效应/测试收益、迁移切片、回滚、兼容性风险，以及 `Strong|Worth exploring|Speculative` 置信度。

以**首要建议**结尾。暂时不要提出最终接口。询问要继续探索哪个候选方案。

## 4. 深入质询所选设计

运行 `/grilling`。明确所有权、不变量、模块形态、接缝、适配器、依赖方向、过渡状态、迁移、回滚和可观测测试。

- 新增或细化的领域术语 -> 由 `/domain-modeling` 更新 `CONTEXT.md`。
- 持久性否决 -> 提议记录 ADR。
- 相互竞争的接口 -> 使用 `/codebase-design` 的双方案设计。
- 可审查的可视化提案 -> `/visual-plan`；相互竞争的提案 -> `/plan-arbiter`。
- 实现请求 -> 将可逆的迁移序列交给 `/development-lifecycle`。

完成标准：所选不变量能够说明为什么错误类别无法通过未修改的调用路径再次出现，并且测试验证了该公共契约。
