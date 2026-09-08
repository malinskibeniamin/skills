---
title: /stacked-prs
description: 使用 gh stack 创建和管理相互依赖的 GitHub 拉取请求。适用于堆叠式 PR、依赖分支链、增量审查层，或将大型变更拆分为有序 PR。
type: skill
sidebar:
  label: /stacked-prs
---
![/stacked-prs 技能示意图](/diagrams/skills/stacked-prs.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/stacked-prs.excalidraw)


使用 `gh stack`；[REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/stacked-prs/REFERENCE.md) 涵盖命令、外部链接模式和恢复。

## 约定

- 每一层都可相对于其父分支进行独立审查。
- 一个 Conductor 工作区负责一个堆栈；不相关的工作使用另一个堆栈。
- 测试每一层，审查 `<parent>...HEAD`，然后报告 `gh stack view --json`。
- 遵循所请求的计划、本地、推送、草稿、开放或合并终点。

## 确定模式

检查 `gh`、身份验证、仓库支持、当前分支、远程仓库、工作区整洁状态以及 `git worktree list --porcelain`。如果缺少扩展，请提供 `gh extension install github/gh-stack`；未经许可不得安装。存在多个远程仓库时，传递 `--remote origin`。

默认使用原生模式：一个工作区负责整个堆栈并切换分支。在运行结构性命令之前，执行：

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/stack-worktree-conflicts.sh"
```

退出码 2 会报告 `branch<TAB>path`；不要抢占分支、移除工作树或执行级联操作。仅在有意采用每层一个工作树的设置时使用外部链接模式：
`gh stack link --base <trunk> --remote origin <bottom> ... <top>`。在执行级联操作前，先协调这些工作树。

## 规划和开发

展示一个自底向上的表格，列出目标、分支、父分支、范围和验证方式。依赖项应位于其使用者所在层或更低层。仅确认由代理提出的边界。

结构性命令要求工作树保持整洁。使用 `gh stack init --base <trunk> <bottom>` 开始。按照 RED -> GREEN -> REFACTOR 实现、验证并提交。使用 `gh stack add <next>` 添加一个内聚的关注点。使用明确的分支和文件添加命令，不要使用 `git add -A`。

使用 `gh stack checkout <branch>` 和 `gh stack view --json`；避免使用无参数命令和 TUI 命令。

## 审查和发布

```bash
BASE=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff "$BASE"...HEAD
git log "$BASE"..HEAD --oneline
```

发布前验证并实际试用每一层。提交整个堆栈时默认创建草稿：`gh stack submit --auto --remote origin`；仅在用户要求时添加 `--open`。提交单个 PR 的请求绝不授权发布其他层。

对每一层应用 [PR 证据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)：`/quantify-impact`、嵌入式前后对比，以及针对可见变更且通过的视觉测试。与其父分支进行比较；提交前准备正文，提交后进行验证。级联操作会使证据失效。

## 处理反馈、同步和合并

在反馈所属的分支上修复问题并进行验证。级联操作会重写上层分支。对于当前工作区中由用户拥有的堆栈，可直接执行变基，并使用 force-with-lease 推送，无需再次请求许可；在回执中报告此次操作。当归属不明确，或将更改默认分支、共享分支、他人拥有或正被并行使用的分支时才询问。使用 `gh stack rebase --upstack --remote origin`，然后运行 `gh stack push --remote origin`；`gh stack sync --prune --remote origin` 适用相同的边界。

使用 `gh stack rebase --continue` 继续处理冲突；仅在用户要求时中止。外部链接模式必须先协调工作树。

绝不能将合并作为发布的附带操作。明确的合并意图仅涵盖指定的连续范围。重新检查批准、检查项、历史记录、评论和待办事项；使用 `gh stack merge <stack-or-pr> --yes --merge-method <squash|rebase|merge>`，绝不使用 `gh pr merge`。

报告主干、按顺序排列的各层、当前层、PR 状态/URL、验证结果、冲突、重写操作，以及下一项自底向上的操作。
