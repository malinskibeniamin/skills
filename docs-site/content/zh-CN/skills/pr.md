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
2. 将已发布的描述与**完整 PR 差异**、原始目标及当前验证结果对照，而非只看最近一轮对话或提交。对于堆叠 PR，逐一对照父分支评估受影响的层。 按照[视觉标注](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations)检查截图、标记和图例是否过时。
3. 单独加载 [quantify-impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md)。重新评估业务价值及产品或代码库影响；复用仍有效的证据，重跑已失效的比较，并删除缺乏依据的主张。价值未知时明确写出 `not established`。
4. 对已获授权的修改或交付，一并刷新受影响的截图、标记及图例；保留人工开头（意图过时时提醒作者编辑），刷新代理草拟的开头，就地替换过时的代理条目，简明说明受益方、价值、证据及实质风险。更新[人工审查交接](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff)，包括审查人指派、恢复及检测缺口。保留人工意图和必需证据；链接详情，跳过准确描述，省略会话日志。
5. 编辑后重新读取托管平台上的正文，确认其描述的是已发布的源分支状态。只读请求仅报告偏差，不编辑。明确要求仅本地修改或禁止推送时，暂缓发布；绝不将未发布的工作描述为已交付。

## 正文模板 [#body-template]

使用简洁易懂、描述结果且符合仓库规范的标题。标题和开头一句属于人类作者：保留其提供的措辞。代拟时，明确标记标题和开头为等待人工编辑的代理草稿；不得声称由人类撰写或已获认可。已获授权的草稿 PR 可以继续发布。维护时保留人工文本；意图变化时指出问题，不要悄悄改写。

顺序为：一句话说明变更及原因 -> UI 变更前后截图表 -> 有帮助时附可点击原型 -> 一个默认折叠的 `<details>` 中的代理说明。原型链接也可紧邻表格之前。不适用的视觉或原型部分应省略，不要发布占位内容。使用以下结构：

```markdown
<one human-authored line about the change and why, or an explicitly labeled agent draft>

| Before | After |
| --- | --- |
| ![Previous state](<hosted-before-image>) | ![New state](<hosted-after-image>) |

[Try the prototype](<reviewer-accessible-url>) — <states/variants; access requirement>

<details>
<summary>Agent-generated description</summary>

- Lane / Review: <beneficiary, scope, closest-review paths and owner routing/gaps>
- Testing: <commands, observed results, real-entrypoint evidence and gaps>
- Risk / Rollback: <failure modes, blast radius, recovery, detection and gaps>

<verified model/harness attribution when required>

</details>
```

验证失败或受阻、实质风险、回滚成本高或检测缺口，应在详情之前提供简短的**可见警告**。折叠常规记录，不要隐藏阻碍。在代理说明中评估[人工审查交接](https://github.com/malinskibeniamin/skills/blob/main/shared/review-contract.md#human-review-handoff)的全部五项标准，无需新增五个套话标题。保留必需的引用、验收标准及仓库专有字段。

UI 变更按照[视觉证据契约](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)提供可比的真实基版本与候选版本截图。说明比较不可用或不适用的原因；不得编造变更前状态或将占位 URL 当作证据。非 UI 变更省略截图表，保留适用的图表证据。原型补充而非替代截图或测试。

### 可点击的审查原型 [#clickable-review-prototypes]

当交互、难以到达的应用状态或备选方案适合动手审查时，链接到 [UI 原型](https://github.com/malinskibeniamin/skills/blob/main/prototype/UI.md#shareable-review-prototype)。在轻量网站直接使用真实应用组件、字体、设计令牌及主题提供器；通过明确标注的测试数据隔离 Electron、原生代码和后端边界。审查者无需检出分支或配置完整应用环境即可进入相关状态。设计问题尚未确定时，提供具有实质差异的方案，以及可分享的变体和状态 URL；已确定的小改动无需变体或新原型。

仅使用目标仓库已记录、获批准且受 SSO 保护的 Quick Site 或等效私有预览流程部署。查找该流程的命令和配置；[Shopify Quick](https://shopify.engineering/quick) 仅是灵感，并不提供基础设施访问权或通用部署命令。托管或 SSO 不可用时，保留可运行产物、说明缺口并使用截图；不得默默转为公开发布或新增托管、认证基础设施。核实审查者访问权限、链接目标状态和资源加载；声称受 SSO 保护前，确认退出登录后无法访问。明确标识模拟行为和未经验证的访问权限。将 URL 和产物绑定到审查版本；相关变更后刷新或标记过时。遵守[原型保留策略](https://github.com/malinskibeniamin/skills/blob/main/prototype/SKILL.md#retention)。


## 各部分 [#sections]

开头一句是必需的首读摘要，不是引言；遵守 [PR 注意力预算](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md#match-the-artifact)。下方只保留补充细节。以下主题是作者指引，不是必需标题。按模板折叠代理详情；必需视觉媒体内嵌在开头及必要警告之后。使用 `GLOSSARY.md` 中的用户领域语言。

### 摘要 [#summary]

仅在有帮助时补充审阅重点，不要重复开头一句话。区分核心变更与生成或机械性文件；指出有用的审查入口，不逐一罗列文件。区分已观察到的结果和预期。

将 PR 正文作为操作者的简明摘要：行为与价值、关键证据、领域决策、剩余风险与恢复方式，以及下一步操作；通过链接提供详情，方便恢复工作。单独的 HTML 或可视化回顾产物需要明确请求；仍须审查完整差异并提供必需的可视化证据。

从 [SUMMARY-VIEWS.md](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md) 中选择最小视图。

#### 决策变更 [#changed-decisions]

如果相对已记录的计划或结果契约，范围、契约、验证方式或发布风险发生实质性变化，请说明这些偏离。复用现有笔记或意图图：
先前选择 -> 新证据 -> 当前选择 -> 对审阅的影响。
PR 内容应独立完整；省略空洞的变更历史，绝不要虚构先前计划或共识。

会话摘录只提供可选上下文。仅使用相关、获准共享、已脱敏且审阅者可访问的摘录；否则提供安全、独立完整的理由说明。
不要只为提供链接而扩大共享范围或执行权限。会话长度或交互轮数既不能证明正确性，也不能证明认真程度；请根据当前差异和执行证据核实相关说法。

将可视化放在其支持的文字旁。只显示关键调用、文件、属性、状态和边界。

省略无法增进理解的视图。

### 证据 [#evidence]

提供变更有效的具体证据。优先简述命令及结果；UI 变更按正文模板提供前后比较，其他变更仅在有帮助时附媒体。说明未执行的检查和不确定性；测试通过不代表人工审查或共识。

仅在差异难以定位时使用[视觉标注](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#visual-annotations)。广泛的 UI 工作可在有助于理解时使用 [UI 变更图](https://github.com/malinskibeniamin/skills/blob/main/pr/SUMMARY-VIEWS.md#ui-change-maps)；避免重复截图和独立总结文件。

对于后端、API、Protobuf、契约、架构、数据流或工作流变更，如果截图或视频未能解释受影响的行为，必须在开头一句之后内联加入[后端图表](https://github.com/malinskibeniamin/skills/blob/main/excalidraw-diagram/PR-WORKFLOW.md)，并更新过时的维护图表。优先使用 Excalidraw；渲染或托管失败时使用内联 Mermaid。保留测试证据：图表用于解释，不证明正确性。[视觉证据契约](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)规定了适用范围内的例外和检查已发布正文的完成门禁。

按 [commit-push-pr 视觉证据](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/REFERENCE.md#frontendcustomer-facing-detection--screenshot-table-phase-5)选择媒体。 每次编写的 UI 变更都需要通过 [package-my-work](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/SKILL.md) 提供当前版本片段。其他界面仅在交互、动效需要或用户要求时录制；纯审查保持只读。 证据的价值在于回答的问题，不在于媒体等级。测试结果应简洁、真实，不要重构或虚构。

### 合并风险 [#merge-danger]

说明回滚路径，并将变更归类为单向门或双向门。双向门容易退回；破坏性或难以逆转的决策属于单向门。

列明受影响的用户、调用方、契约和可信的故障模式，包括共享使用方。
在说明恢复方案时，同时按照交接标准评估错误检测；明确列出重要的故障可见性缺口，不要把测试通过或回滚计划当作错误检测的替代品。
