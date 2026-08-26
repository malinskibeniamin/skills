---
title: /swarm
description: "通过工作树通道并行执行相互独立的批量工作。"
type: skill
sidebar:
  label: /swarm
---
![／swarm 技能示意图](/diagrams/skills/swarm.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/swarm.excalidraw)

# Swarm

把相互独立的批量工作拆分到多个通道，逐一验证后再集成。Swarm 执行已有目标；它不替代规划，也不负责交付。并行工作必须由用户通过 `/swarm` 或直接请求明确选择；其他技能不构成授权。

`/work` 负责生命周期，`/grilling` 解决选择，`/go` 负责发布。

## 启动

1. 检查仓库规则、状态、分支或 PR、相关文档和当前目标。
2. 对长时间或高成本批次，在启动前及批次之间使用 `/efficient-frontier`。除非用户另有要求，最多同时运行三个智能体。
3. 协调者保留编排、关键路径、集成和判断。仅委派边界明确的搜索、实现、测试或证据归纳工作。
4. 选择工作区策略：
   - 默认：共用分支、工作树和 PR。
   - 用户要求隔离：每个通道使用一个描述性工作树和分支。
   - 冲突风险高：分离作用域或串行写入。
5. 展示简洁清单后启动：

   ```text
   Swarm manifest
   Policy: shared | worktrees | hybrid
   - swarm-<lane>: <mission> | scope: <paths> | skills: </skill...>
   ```

6. 只创建不同的通道。协调者集成结果、解决冲突发现、执行最终验证并关闭智能体。

## 任务包

每个通道收到：

```yaml
agent_name: swarm-<area>-<mission>
role: explorer | worker | reviewer | teacher
mission: one concrete outcome
skills: [only relevant skills]
context: rules, decisions, branch or PR, paths
workspace_policy: shared | worktree | hybrid
write_scope: exact paths or report-only
forbidden: duplicate work, unrelated files, commits or pushes unless requested
termination: deliverable and stop condition
model_policy: inherit unless evidence or the user requires an override
output schema: status, summary, changed_files, tests_run, findings, blockers, next_action
```

Worker 只能写入其作用域。共享通道必须有不同的所有权；工作树通道使用描述性分支；创建后代智能体需要单独授权。

## 通道规则

- 使用 `config/model-routing.json`；不要让不同模型重复同一实现。
- 每个写入作用域只能有一个实现负责人；每个变更的技能或钩子也要指定相应评估或评估负责人。
- TDD 通道在实现证据前返回 RED -> GREEN 或失败测试证据。
- 按模块或接缝拆分架构工作；按独立公共行为拆分测试。
- 仅在作用域不重叠时拆分 `/visual-review` 与 `/ux-copy`。
- 审查通道可按规范、标准、韧性、安全、性能、测试和 UX 拆分。
- 诊断通道可按复现、假设、插桩和回归证明拆分。
- 综合判断和用户保留决策由协调者负责。

## 集成协议

读取产物和变更文件，不只看摘要。有意拒绝或协调重叠。建议冲突时，展示证据、选项和协调者的选择。集成后运行聚焦检查；TDD 工作必须先有 RED 证据再有 GREEN。报告清单、采纳与拒绝的工作、测试、阻塞项和下一步。

## 兼容性

Codex 与 Claude Code 必须依据明确提示和产物工作。没有原生子智能体时，输出任务包供手动启动。
