---
title: /triage
description: "让问题在分诊角色之间流转，并准备可由智能体执行的工作。"
type: skill
sidebar:
  label: /triage
---
![/triage 技能示意图](/diagrams/skills/triage.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/triage.excalidraw)

通过小型角色状态机移动问题。对于已配置的外部 PR，PR 是附带代码的问题；通过跟踪器解析裸编号。
使用领域词汇表和相关 ADR。通过 `/read-the-damn-docs` 阅读当前外部文档；用 `/plan-arbiter` 仲裁竞争方案，用 `/visual-plan` 展示大型史诗。

## 评论不变量

每条发布的分诊评论必须以下列内容开头：

```markdown
> *此内容由 AI 在分诊期间生成。*
```

## 跟踪器与角色

从仓库说明和远程地址检测跟踪器：

- GitHub：按 [tracker-github.md](https://github.com/malinskibeniamin/skills/blob/main/triage/tracker-github.md) 使用 `gh`。
- Jira：按 [tracker-jira.md](https://github.com/malinskibeniamin/skills/blob/main/triage/tracker-jira.md) 使用 `acli`。
- 两者都可能时，询问哪个拥有该事项。

每个已分诊事项恰好有一个类别（`bug` 或 `enhancement`）和一个状态：`needs-triage`、`needs-info`、`ready-for-agent`、`ready-for-human` 或 `wontfix`。
将标准角色映射到现有标签或状态。状态冲突必须先决策再修改。

## 待关注队列

按最旧优先查询：

1. 无标签或无状态事项。
2. `needs-triage` 事项。
3. 报告者有新活动的 `needs-info` 事项。

包含已配置的外部事项，并将每行标记为 `[PR]` 或 `[issue]`；协作者的活跃 PR 不属于发现工作。明确指定的 PR 始终在范围内。显示数量，由维护者选择。

## 分诊一个事项

1. **收集。** 阅读正文、评论、标签或状态、报告者、日期、旧分诊记录，以及 PR 差异。不要重复已回答的问题。
2. **探索。** 按领域概念搜索冗余或已有实现。检查 `.out-of-scope/` 中的旧拒绝记录。
3. **建议。** 给出类别、状态、理由和代码证据；等待方向。
4. **验证主张。** 复现缺陷，或检出并测试 PR。报告已确认、失败或证据不足。根因和 RED/GREEN 计划见 [TDD 修复计划模式](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md#tdd-fix-plan-mode)。
5. **必要时追问。** 对未决判断或领域语言使用 `/grilling`。
6. **应用。** 就绪状态使用 [AGENT-BRIEF.md](https://github.com/malinskibeniamin/skills/blob/main/triage/AGENT-BRIEF.md)，`needs-info` 使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md)。对于 `wontfix`：
   - 已实现：链接实现并关闭，不写拒绝历史；
   - 缺陷：解释后关闭；
   - 增强：按 [OUT-OF-SCOPE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/OUT-OF-SCOPE.md) 记录，链接并关闭。
   除非要记录部分进展，应用 `needs-triage` 时不评论。

## 覆盖与恢复

对于明确状态覆盖，先说明变更再执行，跳过追问。仅在没有智能体简报却移动到 `ready-for-agent` 时询问是否编写。
恢复时读取旧记录和新回复，再展示当前状态，不重复提问。

完整模板和状态转换见 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/triage/REFERENCE.md)。
