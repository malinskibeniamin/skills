---
title: /work-automation-kit
description: 安装规划和项目管理工作流：规范、工单拆分、跟踪器文档、分类处理。
type: skill
sidebar:
  label: /work-automation-kit
---
![／work-automation-kit 技能示意图](/diagrams/skills/work-automation-kit.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/work-automation-kit.excalidraw)

安装工作流技能，并搭建跟踪器标签、领域上下文和 ADR 布局。提示词循环：探索 -> 展示 -> 确认 -> 写入。

## 安装 [#install]

安装一次：

```bash
for skill in grilling domain-modeling triage diagnosing-bugs prototype \
  implement-spec pr retro tdd codebase-design review \
  to-questionnaire to-spec to-tickets handoff writing-for-agents visual-plan \
  visual-recap plan-arbiter agent-watchdog read-the-damn-docs efficient-frontier
do
  bunx skills@latest add "malinskibeniamin/skills/$skill" --agent claude-code -y
done
```

使用 Jira 时，可通过 `acli` 选装 `setup-atlassian-workflow`。

## 项目上下文 [#project-context]

阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/work-automation-kit/REFERENCE.md)，然后：

1. 检查远程仓库、智能体规则、`docs/agents/`、术语表/ADR、是否已安装 triage，以及 monorepo 特征。
2. 首先推荐跟踪器；仅当选择会产生不同流程时才询问。
3. 已安装 triage 时，询问是否保留五个默认规范角色标签（建议：是）；仅在用户回答否时收集替代值。否则跳过标签。
4. 非 monorepo 默认选择单上下文，无需询问。仅对 monorepo 提供多上下文选项，然后确认布局。
5. 写入前确认文档草稿；复用 `templates/`。
6. 选择一个指令文件：存在 `CLAUDE.md` 时优先编辑它，否则编辑 `AGENTS.md`；两者都不存在时，询问要创建哪一个。写入已批准的：
   - `docs/agents/issue-tracker.md`，存在 `/wayfinder` 时包含 `## Wayfinding operations`；
   - 仅在有 triage 时写入 `docs/agents/triage-labels.md`；
   - `docs/agents/domain.md`；
   - 所选文件的 `## Agent skills` 区块，包含 `### Issue tracker`、摘要/链接，以及按条件添加的标签和领域指引。
7. 写入后验证 `### Issue tracker` 及其链接，以及标签、Wayfinding 操作和上下文布局。
