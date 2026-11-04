---
description: 提交、推送并创建便于审查的 PR，或执行明确授权的合并。适用于交付请求；--no-pr 会在推送后停止。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - commit push pr
sidebar:
  label: /commit-push-pr
title: /commit-push-pr
type: skill
---
![/commit-push-pr 技能示意图](/diagrams/skills/commit-push-pr.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/commit-push-pr.excalidraw)

阅读 [Poteto](https://github.com/malinskibeniamin/skills/blob/main/shared/POTETO-NATIVE.md#execution)。

使用 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md)和[依赖加载规则](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

仅在明确授权时合并：[合并约定](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/merge.md)。

## 前置检查 [#preflight]

1. 检查状态、差异、分支、日志和 PR；推送或创建 PR 时，对自己负责且落后于基分支的 PR 执行[自动变基](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#automatic-rebase)。
2. 确定终点：仅提交、推送（`--no-pr`）或 PR。仅提交会跳过远程仓库和 `gh` 前置检查。
3. 推送/PR：[自动配置审查保障](https://github.com/malinskibeniamin/skills/blob/main/shared/review-enforcement.md)；遵守更窄的终点范围。
4. 对于 PR，运行 `gh stack view --json`。仅负责一层；绝不隐式运行 `gh stack submit`。
5. 使用负责该项工作的技能进行审查；已授权的评审委员会保留实际覆盖范围，不得仅因技能调用形式而阻止交付。
6. 对可运行的 PR 工作，加载 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)；要求当前的 PASS。BLOCKED 需要用户豁免。
7. 按用途暂存；如果归属不明确，请询问。

## 提交 [#commit]

使用 Changesets 的仓库在检查后加载 [changesets](https://github.com/malinskibeniamin/skills/blob/main/t3code-skills/changesets/SKILL.md)。

1. 保持在功能分支上；如果位于默认分支，则创建 `type/description`。
2. 对每个逻辑一致的分组，先执行 `git add <explicit paths>`，再使用 `type(scope): description` 提交：小写、5-72 个字符、末尾不加句号。
3. 明确要求仅提交时，检查工作树是否干净后在此停止。
4. 推送/PR、任何 CI 修复或变基：显示 `origin/<branch>..HEAD`，然后推送并设置跟踪关系。
5. 重写用户拥有的功能分支后，直接使用 `--force-with-lease`，无需再次请求许可。绝不使用普通强制推送；重写默认分支、共享分支、他人拥有或正被并行使用的分支需要明确许可。

## 拉取请求 [#pull-request]

`--no-pr` 绝不会创建 PR。推送后执行[现有 PR 维护](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md#existing-pr)，然后检查工作树。准备证据。

1. 基分支：`"${CLAUDE_PLUGIN_ROOT:-.}/scripts/resolve-pr-base.sh"`。后续工作保留在当前 PR，并维护[元数据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/references/metadata.md)，包括草稿状态。创建草稿 PR 无需批准；堆栈使用 `/stacked-prs`。
2. 每个 PR 都应分别加载 [PR](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/file-pr/SKILL.md)、[影响评估](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)和[正文](https://github.com/malinskibeniamin/skills/blob/main/pr/SKILL.md)；保留草稿状态并说明价值。
3. 可见变更：建立清单，按照[视觉标注](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations)自动为前后对比截图和视频添加编号标记及变更图例，审查快照，并确保视觉测试通过。无需另行请求标注。缺少证据时，必须在发布前获得用户的明确豁免。
4. 公开仓库（`gh repo view --json visibility`）：推送前，从提交、标题、正文和证据中清除内部组织、仓库、产品、人员名称及私有链接。
5. 包含实际试用验证回执；回读正文并检查图片访问权限。编辑会使证据失效。

维护：[维护负责方](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md#automatic-pr-maintenance)。开始监视前选择原生通道；不要重复运行派发器。

除非用户明确要求，否则不要运行 `/visual-recap` 或 `/make-pr-easy-to-review`。

## 完成 [#completion]

1. 读取 CI：`gh pr checks <number>`；缺失、等待中或已跳过的检查不代表通过。
2. 自动修复适用的反馈、CI 问题和冲突；验证并推送，通过一个已授权的通道持续维护。
3. 报告 head、PR、检查、审查缺口以及继续执行的方式或阻碍；遵守更窄的停止条件。
4. 遵循 CLAUDE.md：意图/影响/状态，并在最后的状态行附上完整 PR URL，包括更新时。

保留无关工作；明确说明失败和恢复方式。
