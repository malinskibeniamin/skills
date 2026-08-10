---
title: /swarm
description: 用于跨工作树通道执行独立批量工作的并行执行器。
type: skill
sidebar:
  label: /swarm
---
![／swarm 技能示意图](/diagrams/skills/swarm.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/swarm.excalidraw)

将相互独立的批量工作拆分到隔离的通道中，逐一验证，然后合并结果。Swarm
负责执行已有目标；它既不能替代规划，也不负责交付终点。

使用 `/swarm <free-form goal>`。根据用户的文本推断通道。除非缺少必要的上下文，否则启动前不要请求批准。
调用 `/swarm` 或明确请求并行智能体，即表示选择启用 Codex 原生
子智能体。激活任何其他技能均不代表授予此项许可。

## 定位

- `/work` 负责生命周期。
- `/grilling` 确定计划和文档。
- `/swarm` 更快地执行独立通道。
- `/go` 负责验证和交付。

## 启动流程

1. 快速预热：检查当前仓库状态、规则、文档、分支、PR，以及已有的当前目标。在内部使用 `/prime` 风格的简报。
2. 对于耗时长或成本高的 Swarm，在第一轮之前和各轮之间应用 `/efficient-frontier` 使用限额预算。默认限流：除非用户另有说明，否则并行智能体最多为 3 个。
3. 在底层使用 `/efficient-frontier`：由协调者负责统筹、集成和最终审查；委派范围明确的仓库搜索、实现、测试和日志精简通道。
4. 根据文本选择工作区策略：
   - 默认：使用同一分支、工作树和 PR。
   - 如果用户要求使用独立、隔离或每个智能体单独的工作树：为每个通道创建一个工作树和分支。
   - 如果冲突风险较高：拆分写入任务或改为串行执行；在清单中说明原因。
5. 起草一份简短的 Swarm 清单，然后立即启动：
   ```txt
   Swarm manifest
   Policy: shared | worktrees | hybrid
   - swarm-<lane-name>: <mission> | scope: <paths> | skills: </skill...>
   ```
6. 仅生成职责不同的通道。不要创建重复或职责模糊的智能体。
7. 协调者将关键路径保留在本地执行，合并结果，解决相互冲突的发现，完成验证，并关闭智能体。

## 通道设计

每个通道都会收到一个任务包：

```yaml
agent_name: swarm-<area>-<mission>
role: explorer | worker | reviewer | teacher
mission: one concrete outcome
skills: [/prime, /tdd, /review]
context: docs, decisions, branch or PR, relevant paths
workspace_policy: shared | worktree | hybrid
write_scope: exact paths or "report-only"
forbidden: duplicate lanes, unrelated files, commits, pushes unless asked
termination: concrete deliverable and stop condition for this lane
model_policy: inherit by default; override only when useful or user asks
output schema: status, summary, changed_files, tests_run, findings, blockers, next_action
```

除非任务包注明 `report-only`，否则智能体可以读取和写入。在共享策略下，应分配文件所有权，或将大量写入的通道改为串行执行。在工作树策略下，分支名称应具有描述性；创建工作树时，可以遵循 `<owner>/<ticket>/<lane-desc>` 格式。
未经单独授权进行嵌套委派，已生成的通道不得创建下级智能体。

## 技能组合

- 耗时长或成本高的轮次控制：由 `/efficient-frontier` 负责用量检查和暂停／恢复交接。
- 启动通道之前和各轮之间：使用 `/efficient-frontier`；仅在能够获取最新主机配额快照时使用
  `/stay-within-limits`。
- 通道模型选择：使用 `config/model-routing.json`。每个写入范围只能指定一名
  实现负责人；不要将同一项实现作为模型配对而重复执行。在消融测试套件批准之前，受评估门控的
  变体仍不可用。
- 前沿模型令牌规范：由 `/efficient-frontier` 决定哪些工作应委派，哪些工作应保留给协调者。
- 工作通道应从一开始就编写最小且清晰的解决方案；审查通道直接评估语义密度。
- 架构：按上下文、模块、接缝或适配器并行分派 `/improve architecture`。
- TDD：按独立行为或公共接口拆分覆盖范围。在编辑生产代码前进入 RED 阶段；要求结果中提供 RED->GREEN 过程或测试失败证据。
- 技能／测试框架工作：为每个通道分配评估职责。每个发生变更的技能或钩子都需要在范围内配套相应的评估，并由该通道或协调者负责。
- 设计／文案工作：仅当写入范围不重叠时，才拆分 `/visual-review`、`/ux-copy`、无障碍和表达方式通道。
- 审查：拆分为标准、规范、韧性、安全、性能、测试、用户体验和最强论证等维度。
- 诊断：拆分为复现循环、假设、插桩和回归测试。
- 产品：组合 `/grilling` 探索模式、`/prototype` 和 `/steelman` 通道，以提供备选方案和质疑意见。
- 交接：讨论确定后，创建精简的任务包，让每个智能体都从当前决策开始工作。
- 学习：按理论、示例、仓库中的用法、权衡和易错点拆分主题。

## 合并协议

- 阅读每项结果；对于写入通道，不要盲目信任摘要。
- 有意识地应用或保留更改；切勿盲目接受相互重叠的编辑。
- 建议相互冲突时：展示可选方案、证据和协调者的建议。
- 合并后运行针对性检查。对于 TDD 通道，必须先有测试失败证据，再有实现证据。
- 最终输出：清单回顾、已落地的更改、已拒绝／延期的工作、测试、阻碍因素和下一步行动。

## 兼容性

Codex 和 Claude Code 必须基于提示和产物工作，而不能依赖隐藏钩子。可用时使用原生子智能体。如果没有子智能体工具，则将任务包输出为交接文件或命令，以供手动启动。
