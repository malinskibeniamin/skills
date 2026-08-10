---
title: /commit-push-pr
description: 提交、推送并创建便于审查的 PR。适用于仅提交、提交并推送、创建 PR 或更新现有分支；--no-pr 会在推送后停止。
type: skill
sidebar:
  label: /commit-push-pr
---
![/commit-push-pr 技能示意图](/diagrams/skills/commit-push-pr.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/commit-push-pr.excalidraw)

阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)，了解审查前提条件、提交类型、标签、正文模板、截图和依赖项升级部分。

## 前置检查

1. 运行 `git status -sb`、`git diff HEAD`、`git branch --show-current`、`git log --oneline -5`，并检查此分支上已创建的任何 PR。
2. 确定请求的终点：仅提交、推送（`--no-pr`）或 PR。仅提交会跳过远程仓库和 `gh` 前置检查。
3. 仅推送/PR：确认存在可访问的远程仓库。仅 PR：使用 `gh repo view` 确定默认分支，然后确认 `gh` 已安装并通过身份验证。
4. 仅 PR：使用 `gh stack view --json` 检测本地堆栈成员关系；如果 PR 已存在，还要检查其 `baseRefName` 和 REST `stack` 对象。普通 PR 终点仅负责当前层。它绝不授权运行 `gh stack submit`，因为该命令可能会发布其他分支。
5. 仅 PR：直接执行适用的审查维度；不要仅仅因为未调用某个具名审查技能而阻塞。
6. 仅 PR：可运行行为需要当前的 `/dogfood` PASS。BLOCKED 需要用户豁免。
7. 按用途对已更改文件进行分组。仅暂存请求的路径；只有在无法安全确定归属时，才询问范围。

## 提交

1. 保持在当前功能分支上。如果位于默认分支，则创建 `type/description`。
2. 对于每个逻辑一致的分组：
   - `git add <explicit paths>`
   - 使用 `type(scope): terse description` 提交
   - 保持小写、5-72 个字符，末尾不加句号
3. 明确的仅提交意图会在检查工作树是否干净并提供提交摘要后于此处停止。
4. 仅推送/PR：显示 `origin/<branch>..HEAD`，然后推送并设置跟踪关系。
5. 只有在获准重写历史后才能使用 `--force-with-lease`。

## 拉取请求

`--no-pr` 或明确的提交并推送请求会在检查工作树是否干净并提供已推送的提交摘要后结束。

否则：

1. 将制作/打开/创建 PR 视为对其前置操作的授权：验证、提交并推送当前分支。它不授权合并、强制推送或修复无关问题。
2. 使用 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"` 确定明确的目标分支。复用现有的分支 PR，或基于该目标分支创建一个 PR，并设置负责人、标签及参考正文模板。若要明确发布整个堆栈，请改为遵循 `/stacked-prs`。
3. 对于面向客户的更改，请为每个视图添加一行截图/界面审查记录。
4. 对于可运行的更改，请包含当前的实际使用验证回执。
5. 输出 PR URL。

除非用户明确要求额外的产物或历史记录工作，否则不要运行 `/visual-recap` 或 `/make-pr-easy-to-review`。

## CI 与完成

1. 使用 `gh pr checks <number>` 获取一次 CI 状态快照。如果不存在 CI，请注明。
2. 如果检查已失败，请报告；在此快照之后进行修复和监控需要 `/go`、发布、明确要求持续跟进，或后续请求。
3. 运行 `git status` 和 `git diff`；报告未提交的工作。
4. 汇总分支、提交、PR、CI 和剩余操作。
5. 以一行状态结束：`🟢 done — PR opened; CI <state>`、`🟡 awaiting decision — <decision>` 或 `🔴 blocked — <external blocker and needed input>`。

绝不要暂存无关更改、未经确认就推送混合范围的更改，也不要隐瞒失败的命令。如果 `gh pr create` 失败，请显示错误和恢复命令。
