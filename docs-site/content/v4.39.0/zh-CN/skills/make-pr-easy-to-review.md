---
title: /make-pr-easy-to-review
description: 清理嘈杂的 PR 历史并添加审查指引，同时不改变代码行为。
type: skill
sidebar:
  label: /make-pr-easy-to-review
---
![“/make-pr-easy-to-review”技能示意图](/diagrams/skills/make-pr-easy-to-review.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/make-pr-easy-to-review.excalidraw)

整理 PR，让审查者能够快速理解其意图、重要文件和风险。默认目标是在不改变行为的前提下提高可审查性。

## 工作流程

1. 根据用户提供的 URL 或当前分支确定目标 PR。
2. 检查提交、差异大小、变更路径、生成的文件以及 PR 描述。
   对于堆叠式 PR，与 `baseRefName` 进行比较，记录其所在层级和相邻 PR，并将
   历史记录操作限制在其所属分支内。
3. 找出影响可审查性的问题：嘈杂的提交、过时的描述、无关变更、机械性变更与逻辑变更混杂、缺少测试或审查切入点不明确。
4. 在重写历史记录或强制推送前提出方案。对堆叠提交进行重新排序、合并或
   级联调整，需要获得针对整个堆叠的明确批准。
5. 应用安全的改进，然后验证工作树或差异仍与预期代码一致。

## 历史记录清理

仅当用户提出要求或同意方案时才重写历史记录。重写前：

```bash
gh pr view <PR> --json title,headRefName,baseRefName,state,commits
git fetch origin <headRefName> <baseRefName>
ORIGINAL_TREE=$(git rev-parse origin/<headRefName>^{tree})
```

良好的提交分组通常遵循依赖顺序：

1. 架构/存储或生成的 API 定义。
2. 核心逻辑。
3. 接线与集成。
4. UI 或表层行为。
5. 测试。

重写后，验证内容一致性：

```bash
echo "Original tree: $ORIGINAL_TREE"
echo "Current tree:  $(git rev-parse HEAD^{tree})"
git diff origin/<headRefName> --stat
```

如果工作树发生了意外变化，请勿推送。

## 审查指引

如需视觉化上下文（图表、文件映射、带注释的演练），请运行 `/visual-recap`——不要在此重复。这项技能只优化 PR 文本本身：

- 当 `/quantify-impact` 生成了有意义的证据时，首先放置其 `## Proven impact` 块（`Metric | Before | After | Delta`），随后提供确切的命令/环境。如果度量没有实际作用，则保留常规的价值摘要；不要伪造空表格。如果证据未达到阈值，请注明 `Value not proven`，而不是将其隐瞒。
- 添加与实际差异相符的 TL;DR。
- 将核心文件与生成的或机械性变更的文件分开。
- 明确指出有风险的行为变更、迁移顺序、发布计划和测试覆盖情况。
- 当问题跟踪器、仪表板或设计文档有助于解释意图时，添加相应链接。

## 约束条件

- 绝不将有意义的行为变更隐藏在“清理”中。
- 除非用户明确要求，否则不要绕过钩子。
- 如果 PR 规模过大，无法通过添加说明使其易于审查，应建议将其拆分，而不是围绕问题进行粉饰。
