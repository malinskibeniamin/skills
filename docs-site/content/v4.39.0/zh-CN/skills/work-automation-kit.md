---
title: /work-automation-kit
description: 安装规划和项目管理工作流：规范、工单拆分、跟踪器文档、分类处理。
type: skill
sidebar:
  label: /work-automation-kit
---
![／work-automation-kit 技能示意图](/diagrams/skills/work-automation-kit.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/work-automation-kit.excalidraw)

安装工作流技能，并为每个仓库搭建上下文：

- 问题跟踪器：GitHub、GitLab、本地 Markdown、Jira/Atlassian 或其他工具。
- 分类标签：用于规范角色的项目字符串。
- 领域文档：`CONTEXT.md`、`CONTEXT-MAP.md`、ADR 布局。

由提示词驱动。探索 -> 展示 -> 确认 -> 写入。

## 包含的工作流

依次安装一次以下规划技能：`grilling`、`domain-modeling`、`triage`、
`diagnosing-bugs`、`prototype`、`to-questionnaire`、`to-spec`、`to-tickets`、`handoff`、
`writing-for-agents`、`visual-plan`、`visual-recap`、`plan-arbiter`、`agent-watchdog`、
`read-the-damn-docs` 和 `efficient-frontier`。

通过 `acli` 使用 Jira 时，可选择安装 `setup-atlassian-workflow`。

## 安装

```bash
for skill in \
  grilling domain-modeling triage diagnosing-bugs prototype to-questionnaire to-spec \
  to-tickets handoff writing-for-agents visual-plan visual-recap plan-arbiter \
  agent-watchdog read-the-damn-docs efficient-frontier
do
  bunx skills@latest add "malinskibeniamin/skills/$skill" --agent claude-code -y
done
```

## 可选：Atlassian/Jira
如果团队使用 Jira，请运行 `setup-atlassian-workflow`。

## 项目上下文设置

详情请参阅 `REFERENCE.md`。

1. 检查 `git remote -v`、智能体文档、现有的 `docs/agents/`、上下文文档、ADR、是否已安装 `triage`，以及 monorepo 特征（`pnpm-workspace.yaml`、软件包工作区或包含内容的 `packages/*/src`）。
2. 首先展示推荐的跟踪器；仅当不同选择确实会产生不同流程时才询问。
3. 如果已安装 `triage`，询问一个问题：“保留默认分类标签吗？”（建议：**是**）。如果回答是，则使用五个规范角色名称。仅当用户回答否时，才收集替代值。如果未安装 `triage`，则跳过标签设置。
4. 如果没有 monorepo 特征，**无需询问，直接选择单上下文**。仅对 monorepo 提供**多上下文**选项，然后确认布局。
5. 写入前确认文档草稿。复用 `templates/`。
6. 以确定性方式选择智能体指令文件：如果存在 `CLAUDE.md`，则优先编辑该文件，否则编辑 `AGENTS.md`；如果两者都不存在，则询问要创建哪一个。仅更新选中的文件，然后写入已批准的文档：
   - 安装了 `/wayfinder` 时，`docs/agents/issue-tracker.md` 中应包含 `## Wayfinding operations`
   - 仅在安装了 `triage` 时写入 `docs/agents/triage-labels.md`
   - `docs/agents/domain.md`
   - 在选中的智能体指令文件中添加 `## Agent skills` 区块；该区块必须包含 `### Issue tracker`，其中应有一行摘要和指向 `docs/agents/issue-tracker.md` 的链接，以及按条件添加的分类标签和领域文档指引
7. 验证智能体指令区块中是否存在 `### Issue tracker`，并且该部分链接到选定的跟踪器文档；同时验证所有必需的标签、Wayfinding 操作和领域布局。
