---
title: /wayfinder
description: 通过问题跟踪器中的决策工单规划跨会话工作。
type: skill
sidebar:
  label: /wayfinder
---
![/wayfinder 技能示意图](/diagrams/skills/wayfinder.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/wayfinder.excalidraw)

当目标大到无法在一个上下文窗口内完成，并且通往**目的地**的道路仍不明朗时使用。Wayfinder 通过**决策工单**寻找路线——这类问题的解决结果是做出决策，而不是拆分出待执行的构建任务。目的地可以是规范、决策，也可以是实现路径尚不明确的变更。

## 只规划，不执行
Wayfinder 仅用于规划。每个工单解决一项决策；当执行前不再有任何待决事项时，地图就完成了。想要开始执行，说明已经到达地图的边界。Notes 应仅记录规划偏好和决策支持工作；Notes 不授权实施或交付。

## 不变原则
- 通过**名称**（标题）指代地图和工单，而不是仅使用 id 或 slug。需要时为名称添加链接。
- 地图是**索引**，不是存储库：决策保存在相应工单中；地图只保留一句话摘要和指针。
- 如果存在 `CLAUDE.md`，先读取它；否则读取 `AGENTS.md`。按照该文件中的 **Issue tracker** 指针操作，然后读取 **Wayfinding operations**。绝不要假定文档路径。如果文件和指针都不存在，则使用本地 Markdown 后备方案。
- 开始工作前，将工单分配给负责推进的开发者以认领工单；这必须是会话中的第一次写入操作。已打开且未分配表示尚未认领。
- 在可用时，使用跟踪器原生的阻塞/依赖功能；仅当原生阻塞功能不可用时，才使用显式的 `Blocked by:` 行作为后备方案。
- 每个会话在主上下文中最多解决一个工单。明确委派或
  `/swarm` 可以授权并行处理已就绪的研究工单；仅调用 wayfinder 并不构成授权。
- 对于获准并行推进的地图，在各轮工单之间应用 `/efficient-frontier`，
  并由协调者负责综合结果。
- 在信任地图之前，使用 `/agent-watchdog` 审核其他会话已解决的工单、认领状态、分支或前沿摘要。

## 地图结构
地图是一个带有 `wayfinder:map` 标签/标记的问题或文件。

```markdown
## Destination
<what reaching the end of this map looks like -- the spec, decision, or change this effort is finding its way to>
## Notes
<domain; skills every session should consult; standing planning preferences for this effort>
## Decisions so far
- [<closed ticket title>](link) -- <one-line gist of the answer>
## Not yet specified
<in-scope future questions or risks not sharp enough to ticket yet>
## Out of scope
<work ruled beyond this destination>
```

地图正文中不列出开放工单；请在问题跟踪器中查询开放的子工单/前沿工单。

## 工单
每个决策工单都是一个子问题/文件，其中包含一个聚焦的问题，规模应适合一个 10 万 token 的智能体会话：

```markdown
## Question

<the decision or investigation this ticket resolves>
```

每个工单要么是 **HITL**——人在回路中，与能够代表自己表达意见的人协作处理；要么是 **AFK**，由智能体独立推进。HITL 工单只能通过实时交流解决；智能体不得自行回答自己在深度提问中提出的问题。

工单类型：

- **研究**（AFK）：在主上下文中通过
  `/research` 阅读文档、API、规范、源代码或其他一手资料。链接引用了来源的 Markdown 摘要。仅在明确委派或调用 `/swarm` 后使用研究通道。
- **原型**（HITL）：制作一个成本较低、便于获取反馈的产物，包括 `/prototype` UI 或逻辑代码。链接该产物。
- **深度提问**（HITL）：对话。始终调用 `/grilling` 和 `/domain-modeling`。当问题主要依赖判断时，默认使用此类型。
- **任务**（HITL 或 AFK）：决策能够继续推进前所需的手动工作。在安全的情况下自动化；否则向人类提供检查清单。它之所以应当存在，是因为它能解除决策阻塞，而不是因为它能交付目的地。

答案不属于正文的一部分。解决工单时记录答案。资产应以链接形式引用，不要粘贴。

## 战争迷雾
不要绘制当前尚不可见的内容。**尚未明确**用于记录疑似在范围内、但还不够明确，无法分配的问题或风险。工单则用于明确的问题，即使该问题目前被阻塞。尚未明确的内容不包括已经决定的事项、已经创建工单的事项，以及范围之外的事项。

## 范围之外

迷雾只会朝着目的地聚集。超出目的地的工作属于**范围之外**：它不是迷雾，并且除非重新定义目的地，否则永远不会升级为工单。如果发现某个工单实际上超出目的地，应将其关闭，在 Out of scope 中添加一行并说明原因，且不要将其记录为路线决策。

## 绘制地图

1. 命名 Destination。运行 `/grilling` 和 `/domain-modeling`，明确这张地图要通往什么目标。
2. 绘制前沿。以广度优先的方式对整个空间进行深度提问，找出开放决策和第一步。**如果这一步没有发现任何迷雾**，则不需要地图；停止并询问用户接下来如何处理。
3. 创建地图，其中包含 Destination、Notes、空的 Decisions so far、Not yet specified 和 Out of scope。
4. 仅创建当前能够明确描述的工单。在可用时，通过跟踪器原生的子工单/子问题关系关联每个工单；仅当原生层级功能不可用时，才使用正文链接或任务列表链接。重新读取地图，确认每个工单都显示为子工单，然后在第二轮操作中配置阻塞关系。
5. 在主上下文中就地解决一个已就绪的 AFK Research 工单。如果用户明确
   授权了委派或调用了 `/swarm`，则启动彼此独立且已就绪的研究通道；每个通道
   首先认领自己的工单，遵循 `/research` 指定的产物位置，并且不得凭空创建根
   文件或分支。
6. 完成这一个已就绪的研究工单后停止；本会话中不要再解决其他工单。

## 按地图推进工作

1. 以低分辨率加载地图；不要加载每个工单的正文。
2. 选择工单：使用指定名称的工单，或选择第一个开放、未阻塞、未认领的前沿工单。首先认领它。
3. 解决该工单，仅在需要时深入查看相关工单或已关闭工单。调用 Notes 中指定的技能；不确定时，使用 `/grilling` 和 `/domain-modeling`。
4. 将答案记录为解决评论或答案部分，关闭/解决工单，然后向 Decisions so far 追加一个上下文指针。
5. 添加新发现的工单和阻塞边；清除已升级为明确事项的 Not yet specified 条目，确保每项事实只存在于一个位置。如果工单超出 Destination，则将其判定为 Out of scope，而不是把它作为路线的一部分予以解决。

其他会话可能同时编辑跟踪器；写入前读取跟踪器的当前状态。

## 交接

地图清晰后，将其交给 `/to-spec`，把链接的决策整合成一个可实施的计划，然后交给 `/to-tickets`。只有当工作确实很小时，才跳过这一整合步骤。

首先重新检查你的认领状态。展示前沿之前，重新读取解决答案、Decisions-so-far 摘要、链接的资产和跟踪器状态。在要求人类处理后续工单前，修正所有过时或缺乏依据的表述。

最后提供可复制粘贴的后续步骤：为下一个推荐工单提供一条命令；当并行会话安全时，再为每个开放、未阻塞、未认领的前沿工单提供一条固定命令。
