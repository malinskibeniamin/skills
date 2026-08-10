---
title: /stacked-prs
description: 使用 gh stack 创建和管理相互依赖的 GitHub 拉取请求。适用于堆叠式 PR、依赖分支链、增量审查层，或将大型变更拆分为有序 PR。
type: skill
sidebar:
  label: /stacked-prs
---
![/stacked-prs 技能示意图](/diagrams/skills/stacked-prs.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/stacked-prs.excalidraw)

使用 GitHub 的 `gh stack` CLI，同时遵守执行框架的审查、工作树和交付约定。有关版本相关的命令矩阵、外部链接模式、恢复和状态回执，请阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/stacked-prs/REFERENCE.md)。

## 约定

- **目标：** 每一层都可相对于其下方分支进行独立审查。
- **防护措施：** 一个 Conductor 工作区负责一个堆栈；不相关的工作使用另一个堆栈；全局安装、共享分支重写、发布和合并均须遵循用户意图。
- **验证：** 测试每一层，审查 `<parent>...HEAD`，然后报告 `gh stack view --json`。
- **停止点：** 遵循所请求的计划、本地、推送、草稿、开放或合并终点。

## 1. 确定模式

检查 `gh`、身份验证、仓库支持、当前分支、远程仓库、工作区整洁状态以及 `git worktree list --porcelain`。如果缺少扩展，请提供 `gh extension install github/gh-stack`；未经许可不得安装。此执行框架推送到 `origin`；存在多个远程仓库时，为每个支持的命令传递 `--remote origin`。

默认使用**原生模式**：一个工作区负责整个堆栈并切换分支。在执行 `add`、`checkout`、`rebase`、`sync`、`modify` 或 `push` 之前，运行：

```bash
"${CLAUDE_PLUGIN_ROOT:-.}/scripts/stack-worktree-conflicts.sh"
```

退出码 2 会按 `branch<TAB>path` 格式列出由其他工作树占用的堆栈分支。报告这些分支；不要移除工作树、抢占其分支或在本地执行级联操作。

仅在有意采用每层一个工作树的工作流时使用**外部链接模式**。使用 `gh stack link --base <trunk> --remote origin <bottom> ... <top>` 发布。在执行任何本地级联操作之前，先协调或释放这些工作树。

## 2. 规划和开发

编码前，展示一个自底向上的表格，列出每一层的目标、分支、父分支、允许的范围和验证方式。依赖项应位于同一层或更低层。确认由代理提出的边界；用户明确指定的边界无需再次批准。

结构性命令要求工作树保持整洁。使用 `gh stack init --base <trunk> <bottom-branch>` 接管或创建最底层分支。按照 RED -> GREEN -> REFACTOR 实现、验证并审慎提交。使用 `gh stack add <next-branch>` 添加下一个内聚的关注点。使用明确的分支名称以及标准的 `git add`/`git commit`；避免使用会模糊层级归属的 `-A` 快捷方式。

使用 `gh stack checkout <branch>` 导航，并使用 `gh stack view --json` 检查。无参数命令和 TUI 输出对代理而言并不安全。

## 3. 审查和发布

```bash
BASE=$("${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh")
git diff "$BASE"...HEAD
git log "$BASE"..HEAD --oneline
```

对当前层运行适用的验证和实际试用。发布前检查每个分支；如果提交内容包含非预期或未完成的工作，则停止。明确提交整个堆栈时默认创建草稿：`gh stack submit --auto --remote origin`。仅当用户要求 PR 可供审查时才添加 `--open`。提交单个 PR 的请求绝不授权发布其他尚未提交的层。

## 4. 处理反馈、同步和合并

在反馈所属的分支上修复问题并进行验证。说明级联操作会重写上层分支：使用带租约的强制推送需要明确授权。然后运行 `gh stack rebase --upstack --remote origin`，再运行 `gh stack push --remote origin`。`gh stack sync --prune --remote origin` 适用相同的授权边界。

使用 `gh stack rebase --continue` 继续已解决冲突的操作。仅当用户要求放弃操作时才中止。外部链接模式必须先协调其工作树。

绝不能将合并作为发布的附带操作。明确的合并意图仅授权指定的连续范围。重新检查批准、检查项、线性历史、评论和待办事项；然后使用 `gh stack merge <stack-or-pr> --yes --merge-method <squash|rebase|merge>`，绝不使用 `gh pr merge`。

最后报告主干、按顺序排列的各层、当前层、PR URL/状态、各层验证结果、工作树冲突、已执行的重写操作，以及下一项自底向上的操作。
