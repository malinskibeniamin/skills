---
description: 在撰写 PR 描述，或持续更新当前会话中已打开 PR 的范围、业务价值和证据时使用。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - pr
sidebar:
  label: /pr
title: /pr
type: skill
---
![展示 /pr 技能的图表](/diagrams/skills/pr.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/pr.excalidraw)

完整的 [Matt Pocock 源文件](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/engineering/pr/SKILL.md)和[原始署名](https://github.com/malinskibeniamin/skills/blob/main/vendor/mattpocock/upstream/skills/engineering/pr/CREDITS.md)已随整套技能固定版本。此本地适配保留下述 PR 描述、证据及当前会话 PR 所有权规则。


阅读[保护读者注意力的约定](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)。

## 现有 PR [#existing-pr]

在会话开始或恢复时、范围、实现或证据发生实质变化后，以及交接前：

1. 查找与此对话、会话或聊天明确关联的已打开 PR；否则通过 `gh pr view` 检查当前分支。核实打开状态、仓库、源分支、基分支和归属；绝不选择无关的近期 PR。没有已打开的 PR 就无需维护，也不意味着可以创建 PR。
2. 将已发布的描述与**完整 PR 差异**、原始目标及当前验证结果对照，而非只看最近一轮对话或提交。对于堆叠 PR，逐一对照父分支评估受影响的层。检查当前 PR 头提交的[部署预览](#deploy-previews)。按照[视觉标注](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations)检查截图、标记和图例是否过时。
3. 单独加载 [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)。重新评估业务价值及产品或代码库影响；复用仍有效的证据，重跑已失效的比较，并删除缺乏依据的主张。价值未知时明确写出 `not established`。
4. 对已获授权的修改或交付，一并刷新受影响的截图、标记及图例；保留人工开头（意图过时时提醒作者编辑），刷新代理草拟的开头，就地替换过时的代理条目，简明说明受益方、价值、证据及实质风险。更新[人工审查交接](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff)，包括审查人指派、恢复及检测缺口。保留人工意图和必需证据；链接详情，跳过准确描述，省略会话日志。
5. 编辑后重新读取托管平台上的正文，确认其描述的是已发布的源分支状态。只读请求仅报告偏差，不编辑。明确要求仅本地修改或禁止推送时，暂缓发布；绝不将未发布的工作描述为已交付。

## 部署预览 [#deploy-previews]

创建、更新或交接 PR 时，查看当前头提交的部署、检查、状态结果或提供商的机器人评论。将 `**Deploy preview (<app/provider>):** <full URL>` 放在 PR 正文和交接信息的首行。填写实际应用地址，不要使用部署日志、控制台或 localhost 地址。若有多个预览，按应用和提供商标注。

若预期的预览正在等待、部署失败或不可用，首行改为说明状态及原因；在当前头提交部署完成之前，将旧提交的地址标为过时。推送后、部署完成后及交接前重新检查，替换现有条目而不是重复添加。在 URL 旁注明访问要求；找到 URL 并不代表应用可正常运行。仅当没有且不预期有预览时才省略此行。

## 正文模板 [#body-template]

使用简洁易懂、描述结果且符合仓库规范的标题。标题和说明变更及原因的那一行属于人类作者：保留其提供的措辞。代拟时，明确标记标题和开头为等待人工编辑的代理草稿；不得声称由人类撰写或已获认可。已获授权的草稿 PR 可以继续发布。维护时保留人工文本；意图变化时指出问题，不要悄悄改写。

顺序为：部署预览（如适用） -> 一句话说明变更及原因 -> UI 变更前后截图表 -> 有帮助时附可点击原型 -> 一个默认折叠的 `<details>` 中的代理说明。原型链接也可紧邻表格之前。不适用的视觉或原型部分应省略，不要发布占位内容。使用以下结构：

```markdown
**Deploy preview (<app/provider>):** <full URL or explicit state/reason; omit when inapplicable>

<one human-authored line about the change and why, or an explicitly labeled agent draft>

| Before | After |
| --- | --- |
| ![Previous state](<hosted-before-image>) | ![New state](<hosted-after-image>) |

[Try the prototype](<reviewer-accessible-url>) - <states/variants; access requirement>

<details>
<summary>Agent-generated description</summary>

- Lane / Review: <beneficiary, scope, closest-review paths and owner routing/gaps>
UI packaging: <已发布录屏 URL，或按 package-my-work 明确说明非 UI 原因/所有者豁免>

- Testing: <commands, observed results, real-entrypoint evidence and gaps>
- Risk / Rollback: <failure modes, blast radius, recovery, detection and gaps>

<verified model/harness attribution when required>

</details>
```

验证失败或受阻、实质风险、回滚成本高或检测缺口，应在详情之前提供简短的**可见警告**。折叠常规记录，不要隐藏阻碍。在代理说明中评估[人工审查交接](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff)的全部五项标准，无需新增五个套话标题。保留必需的引用、验收标准及仓库专有字段。

UI 变更按照[视觉证据契约](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)提供可比的真实基版本与候选版本截图。说明比较不可用或不适用的原因；不得编造变更前状态或将占位 URL 当作证据。非 UI 变更省略截图表，保留适用的图表证据。原型补充而非替代截图或测试。

### 可点击的审查原型 [#clickable-review-prototypes]

当交互、难以到达的状态或备选方案适合动手审查时，遵循[原型托管和验证指南](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#prototype-hosting-and-verification)。

## 描述与风险 [#description-and-risk]

撰写或更新正文前，阅读[补充描述指南](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#supporting-description)，了解证据、决策变化和风险。
PR 正文是供操作人员使用的精简摘要；额外总结产物必须由用户明确要求。
符合条件的非 UI 契约需要[后端图表](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md)；UI 录屏仍须遵循 `package-my-work`。
说明回滚路径，并判断变更是单向门还是双向门。
列出受影响的用户、调用方、契约及可信故障模式，包括共享消费者。
