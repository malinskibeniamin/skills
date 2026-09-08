---
title: /commit-push-pr
description: 提交、推送并创建便于审查的 PR。适用于仅提交、提交并推送、创建 PR 或更新现有分支；--no-pr 会在推送后停止。
type: skill
sidebar:
  label: /commit-push-pr
---
![/commit-push-pr 技能示意图](/diagrams/skills/commit-push-pr.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/commit-push-pr.excalidraw)


阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)，了解审查前提条件、提交、标签、正文和证据。

## 前置检查

1. 检查 `git status -sb`、`git diff HEAD`、当前分支、近期日志以及此分支上的任何 PR。
2. 确定终点：仅提交、推送（`--no-pr`）或 PR。仅提交会跳过远程仓库和 `gh` 前置检查。
3. 推送/PR 需要远程仓库；PR 还需要已通过身份验证的 `gh` 和默认分支。
4. 对于 PR，运行 `gh stack view --json`；检查目标分支和堆栈。普通 PR 仅负责一层，绝不运行 `gh stack submit`。
5. 直接执行适用的审查维度；不要仅仅因为未调用某个具名技能而阻塞。
6. 可运行的 PR 工作需要当前的 `/dogfood` PASS；BLOCKED 需要用户豁免。
7. 按用途暂存；仅暂存请求的路径。如果归属不明确，请询问。

## 提交

1. 保持在功能分支上；如果位于默认分支，则创建 `type/description`。
2. 对于每个逻辑一致的分组，先执行 `git add <explicit paths>`，再使用 `type(scope): terse description` 提交：小写、5-72 个字符、末尾不加句号。
3. 明确的仅提交意图会在检查工作树是否干净并提供摘要后于此处停止。
4. 推送/PR：显示 `origin/<branch>..HEAD`，然后推送并设置跟踪关系。
5. 重写当前用户拥有的功能分支后，如有需要，可直接使用 `--force-with-lease`，无需再次请求许可。绝不使用普通强制推送；重写默认分支、共享分支、他人拥有或正被并行使用的分支需要明确许可。

## 拉取请求

`--no-pr` 绝不会创建 PR。推送后刷新现有 PR 的证据/正文；否则在推送并检查工作树是否干净后结束。推送前准备本地视觉证据。

创建 PR 即授权验证、提交、推送以及对当前用户分支执行租约保护的变基；绝不授权合并或修复无关问题。

1. 使用 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"` 确定目标分支。复用现有的分支 PR，或基于该目标分支创建一个 PR，并设置负责人、标签及参考模板。若要发布整个堆栈，请使用 `/stacked-prs`。
2. 每个 PR 都要运行 `/quantify-impact`；包含简明的价值说明或经验证的指标，不要进行流于形式的基准测试。
3. 每项可见更改，无论多小，都需要参考资料中规定的清单、嵌入式前后对比图、已审查的快照以及通过的视觉测试。如缺少证据，则阻止发布，除非用户明确豁免。
4. 包含当前的实际使用验证回执。重新阅读正文，验证审查者能否访问图片，并输出 URL。更新/重新打开 PR 时遵循相同的前置条件；编辑会使受影响的证据失效。

除非用户明确要求，否则不要运行 `/visual-recap` 或 `/make-pr-easy-to-review`。

## 完成

1. 获取一次 CI 状态快照：`gh pr checks <number>`；如果不存在 CI，请注明。
2. 报告现有失败。在此快照之后进行修复和监控需要 `/go`、发布、明确要求持续跟进，或后续请求。
3. 报告 `git status`、剩余差异、分支、提交、PR、CI 和下一步操作。
4. 使用仓库标记约定，以一行状态结束：`done`、`awaiting decision` 或 `blocked`。

绝不要暂存无关工作、未经确认就推送混合范围的更改，也不要隐瞒失败。如果 `gh pr create` 失败，请显示错误和恢复命令。
