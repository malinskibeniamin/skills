---
title: /commit-push-pr
description: 提交、推送并创建便于审查的 PR，或执行明确授权的合并。适用于交付请求；--no-pr 会在推送后停止。
type: skill
sidebar:
  label: /commit-push-pr
---
![/commit-push-pr 技能示意图](/diagrams/skills/commit-push-pr.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/commit-push-pr.excalidraw)


阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)，了解 PR 的详细要求。

仅在明确要求时合并：[合并约定](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md)。

## 前置检查 [#preflight]

1. 检查状态、差异、当前分支、日志以及此分支上的 PR；变基前执行[变基前检查](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#pre-rebase-check)。
2. 确定终点：仅提交、推送（`--no-pr`）或 PR。仅提交会跳过远程仓库和 `gh` 前置检查。
3. 推送/PR 需要远程仓库；PR 还需要已通过身份验证的 `gh` 和默认分支。
4. 对于 PR，运行 `gh stack view --json`；检查目标分支和堆栈。普通 PR 仅负责一层，绝不运行 `gh stack submit`。
5. 直接执行审查；不要仅仅因为未调用某个具名技能而阻塞。
6. 可运行的 PR 工作需要当前的 `/dogfood` PASS；BLOCKED 需要用户豁免。
7. 按用途暂存请求的路径；如果归属不明确，请询问。

## 提交 [#commit]

1. 保持在功能分支上；如果位于默认分支，则创建 `type/description`。
2. 对于每个逻辑一致的分组，先执行 `git add <explicit paths>`，再使用 `type(scope): terse description` 提交：小写、5-72 个字符、末尾不加句号。
3. 明确的仅提交意图会在检查工作树是否干净并提供摘要后于此处停止。
4. 推送/PR：显示 `origin/<branch>..HEAD`，然后推送并设置跟踪关系。
5. 重写当前用户拥有的分支后，直接使用 `--force-with-lease`，无需再次请求许可。绝不使用普通强制推送；重写默认分支、共享分支、他人拥有或正被并行使用的分支需要明确许可。

## 拉取请求 [#pull-request]

`--no-pr` 绝不会创建 PR。推送后刷新现有 PR 的证据/正文；否则在推送并检查工作树是否干净后结束。推送前准备本地视觉证据。

创建 PR 即授权验证、提交、推送以及对当前用户分支执行租约保护的变基；绝不授权合并或修复无关问题。

1. 使用 `"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"` 确定目标分支。后续工作继续提交到当前 PR；否则创建 PR，并设置负责人、标签及模板。创建草稿 PR 无需另行征求批准。若要发布整个堆栈，请使用 `/stacked-prs`。
2. 每个 PR 都要运行 `/quantify-impact`；包含简明的价值说明或经验证的指标，不要进行流于形式的基准测试。
3. 每项可见更改都需要参考资料中规定的清单、前后对比截图和视频、已审查的快照以及通过的视觉测试。如缺少证据，则阻止发布，除非用户明确豁免。
4. 公开仓库（`gh repo view --json visibility`）：推送前，从提交、标题、正文和证据中清除内部组织、仓库、产品、人员名称及私有链接。
5. 包含实际使用验证回执。重新阅读正文，验证审查者能否访问图片，并输出 URL。更新/重新打开 PR 时遵循相同的前置条件；编辑会使受影响的证据失效。

除非用户明确要求，否则不要运行 `/visual-recap` 或 `/make-pr-easy-to-review`。

## 完成 [#completion]

1. 获取一次 CI 状态快照：`gh pr checks <number>`；如果不存在 CI，请注明。
2. 报告失败；CI 修复需要 `/go`、发布、明确要求持续跟进，或后续请求。
3. 报告状态、剩余差异、分支、提交、PR、CI 和下一步操作。
4. 遵循 CLAUDE.md 中的状态及意图/影响约定。只要 PR 已存在，就在最后的状态行中附上完整的 PR URL，包括更新时。

绝不要暂存无关工作、推送混合范围的更改，也不要隐瞒失败。如果 `gh pr create` 失败，请显示错误和恢复命令。
