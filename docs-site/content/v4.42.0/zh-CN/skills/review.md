---
description: 用于基于证据审查分支、PR、WIP 或发布中由差异引入的缺陷。
related:
  - /skills/development-lifecycle
  - /skills/tdd
search:
  boost: 3
  keywords:
    - review
    - code review
    - pull request
    - pr
sidebar:
  label: /review
title: /review
type: skill
---
![“/review”技能示意图](/diagrams/skills/review.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/review.excalidraw)

审查差异时，请阅读 [Poteto 适配指南](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#review-and-diagnosis)。

界面变更应遵循[界面兼容规则](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/INTERFACES.md#interface-review)，并阅读普通的[已移除信号参考](https://github.com/malinskibeniamin/skills/blob/v4.42.0/vendor/jakubkrehel/skills/interface-review/removed-signals.md)，检查差异两侧丢失的操作线索。加载 `visual-review` 获取渲染证据；不要自动调用单独的用户专用 `interface-review`，也不要创建第二份报告。

审查固定范围。保持唯一负责人；委派需要明确授权。没有明确意图时不编辑、提交、推送或发布。请求的修复仅在指定范围内进入[作者交付](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/delivery-workflow.md)。

按[审查运行模型](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/OPERATING-MODEL.md)选择审查深度和收敛规则；风险改变审查力度，不改变权限。另请阅读[两类审查约定](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/review-contract.md)。

## 审查约定 [#review-contract]

- **目标**：判断差异是否实现预期结果且没有可信缺陷。
- **约束**：只报告差异引入的问题；将标准问题与产品/规格缺口分开；
  生成文件是证据。
- **验证**：追溯来源。亲自通过真实入口试用每项可运行变更；
  测试不能替代体验。
- **停止**：覆盖每个表面；每条发现都需要证据、影响、优先级、修正和验证。

仅当缺少固定点时提问。否则解析
`BASE=$(PR_BASE_REF="${REVIEW_BASE:-}" "${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")`，
固定头部和合并基点的 SHA，再检查这些版本的完整差异和日志。
审查 WIP 时，纳入暂存、未暂存及相关未跟踪内容；说明排除项。
执行变异测试或并发读取前，使用[源码快照](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/REFERENCE.md#source-snapshots-and-mutation-tests)。
给出结论前重新核对快照身份；输入变动会使相关证据失效。

## 证据循环 [#evidence-loop]

**检查 -> 验证 -> 分类 -> 综合。**

### 检查 [#inspect]

1. 阅读请求或规格、规则、完整差异、调用点和行为。不要让 PR 摘要凌驾于代码。读取适用的 `REVIEW.md`、`CODING_STANDARDS.md` 和 `CONTRIBUTING.md`（若存在）。
2. 对每个变化的假设，反向追踪权威生产者、模式、
   存储、消费者和公共表面。按领域概念、字段和输出
   值搜索，不只搜索变更符号。
3. 从[变更证据](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/change-evidence.md)加载适用的负责技能；复用当前产物。
4. 用相关未变代码中的独立产物、基线、
   近期历史、运行时证据和夹具检验意外主张。比较夹具与生产数据形状。
5. 为一种可信碰撞构造行为反例。映射权限和可见
   表面；跳过格式化工具负责的样式和既有缺陷。
6. 询问：即使测试通过，仍可能错在哪里？

### 验证 [#verify]

- 对照源码、模式、第一手文档或可执行检查复现。
- 当安全性取决于一个非本地事实时，使用 `/blast-radius`；携带证据，而非描述。
- 使用具有代表性的真实规模数据，执行预期路径和一个可信的失败或恢复路径。
  观察控制台、网络、日志和响应时间；无法安全运行或不可用时说明阻碍。
- 检查测试完整性：公共行为、RED、断言、覆盖范围以及无固定时长等待。
  除非文本属于公共输出，否则源文本检查不具备覆盖；删除这类检查，或在
  公共接口处替换。语法规则使用静态分析。

仅在差异提供证据时添加表面专项审查：

| 表面 | 检查 |
|---|---|
| 面向客户的 UI/CLI/报告 | 渲染、状态、文案、键盘/a11y、控制台、视口 |
| 安全/隐私/数据丢失 | 攻击者/起始权限、信任边界、凭据从来源到使用位置的流向、可达影响、恢复 |
| 文档/公开行为 | 可发现性、默认值、省略行为、迁移/发布指导；纯内部变更无需发布说明 |
| API/模式/SQL/PostgreSQL | 兼容性、迁移、生成输出、实际方言 |
| Go/并发/工作流 | 所有权、取消、竞态、重试、幂等 |
| 依赖/外部 API | 第一手文档、版本、锁文件、安全通告 |

差异涉及 `.proto` 文件（包括删除和重命名）、Buf 配置或 protobuf 代码生成/运行时契约时，完整加载 [protobuf](https://github.com/malinskibeniamin/skills/blob/v4.42.0/protobuf/SKILL.md)。即使模式本身未变，也要追踪受影响的生成代码和使用方。能力改进建议应保持非阻塞，并与缺陷分开。在[门禁审查](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/GATES.md)中，语义排除不能跳过命中路径的 protobuf 门禁；普通内联审查使用同一技能，无需启用门禁或委派。

按[依赖加载规则](https://github.com/malinskibeniamin/skills/blob/v4.42.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)加载技能。
分别为“product”和“lie-detector”调用 Skill 工具；在当前流程中应用它们的视角。
获授权的审查维度应在前台运行，使用全新上下文和固定范围指针；汇总每份报告。未经委派授权时，在当前上下文中执行。
专项审查角色：[路由规则](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/REVIEWERS.md)。

### 分类 [#classify]

发现必须由差异引入、有实际影响、可复现或有具体路径，定位到最精确的变更行，
并配最小安全修复。

- **P0**：暴露、数据丢失、中断或核心流程不可用。
- **P1**：用户回归、契约破坏、错误成功或严重 a11y 缺陷。
- **P2**：影响较低但有用且范围明确的修正。
- 不在行内评论中报告未来可选工作和润色。

没有测量或结构边界，不报告性能。没有可信风险，不报告边缘情况。
证据也可以支持有理拒绝。

### 综合 [#synthesize]

阅读[沟通规则](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/communication.md)；保留输出格式。
先报告发现数量，包括明确的零。按根因去重；说明缺陷类别及受影响的实例。完成首次完整审查后，重新审查修复差异和先前发现；假设变化时扩大范围。用证据标明每条发现的状态。省略赞美和无关的缺陷搜寻；将价值与缺陷分开。
将产品结论行与缺陷分开报告。

## 深度模式 [#deep-mode]

使用 `--deep` 时沿用同一循环并建立完整适用性清单。阅读
[DEEP-AUDIT.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/DEEP-AUDIT.md)；覆盖全部表面，不自动增加智能体。

## 输出 [#output]

阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/review/REFERENCE.md) 了解术语和结构。报告
`[P0|P1|P2] <file:line> <title> - <evidence, consequence, correction, verify command>`。
附加 `entrypoint, data, actions, observations, timing, limits`、固定点、模式、计数、
`product:` 和 `lie-detector:` 结论行、结论和剩余限制。无发现时只返回这些结论行、结论和剩余限制。
若 protobuf 审查范围包含具体能力改进机会，追加独立的非阻塞建议部分；没有内容就省略。结构化门禁审查保留发现格式，使用其中的建议机会字段。
