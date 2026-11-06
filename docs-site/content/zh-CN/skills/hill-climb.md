---
description: 通过有界评估循环优化明确的目标。适用于 hill-climb 请求，或依据可执行评估、基准测试、视觉对比反复改进的任务；不用于一次性评审。
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["hill climb"]}
sidebar: {"label":"/hill-climb"}
title: "/hill-climb"
type: "skill"
---
![「/hill-climb」技能示意图](/diagrams/skills/hill-climb.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/hill-climb.excalidraw)

优化产物，而不是迎合评审者。优先使用可执行证据，并校准视觉判断。

## 与现有负责技能协作 [#compose-with-existing-owners]

按说明加载下列[负责技能](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)，共享一套循环和预算：

- [开发生命周期](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/SKILL.md)负责实现与交付。报告、计划和评审请求保持只读，仅允许写入明确请求的计划产物；[improve](https://github.com/malinskibeniamin/skills/blob/main/improve/SKILL.md) 可以建议爬坡，但不能自行启动。
- [Quantify impact](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/SKILL.md) 负责指标、最低有价值改进幅度和噪声。
- 对于 UI，[视觉评审](https://github.com/malinskibeniamin/skills/blob/main/visual-review/SKILL.md)负责渲染证据与专项指南路由；[dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md) 负责真实行为以及故障与恢复检查。
- 仅在明确授权后，[council](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/council/SKILL.md) 或 [sol-loop](https://github.com/malinskibeniamin/skills/blob/main/tstack-skills/sol-loop/SKILL.md) 才能依据[宿主兼容约定](https://github.com/malinskibeniamin/skills/blob/main/shared/TSTACK.md#review-evidence-for-council-and-sol-loop)提供只读评审轮次。仅加载 hill-climb 不授予委派权限。否则应在主上下文中评审，并明确标注。[Efficient frontier](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md) 负责已授权的模型路由与可用容量。

## 编辑前定义爬坡目标 [#define-the-hill-before-editing]

使用已有的任务约定，或在当前上下文中简要记录：

- **目标：**受益者、期望结果、主要指标或明确的评分维度、验收条件，以及最低有价值改进幅度。数字本身不等于价值。
- **护栏：**受保护的行为、无障碍性、安全性、允许编辑的范围和资源限制。保留无关改动以及用户最初要求的交付终点。
- **验证：**评估器命令或视觉评估流程、测试数据、环境、原始修订版本，以及当前最佳的已接受候选版本（当前最优版本）。保留这两个参照。
- **停止：**请求的交付终点、评估预算和停滞规则。未指定预算时，最多执行三次候选迭代，并在该预算内预留确认步骤。更严格的评审、时间、用量或成本限制仍然优先；嵌套的辅助流程共享同一预算。

如果没有可信的评估器，就在授权范围内构建最小的验证器，或指出缺少的前提。不要用容易达成的代理指标替代请求的结果。如果基线已经满足目标，确认后直接停止，不做推测性修改。

## 校准评估器 [#calibrate-the-evaluator]

选择适用的分支，并在可比轮次中固定输入：

| 分支 | 基线与证据 |
|---|---|
| 可执行正确性／评估 | 复现有代表性的失败，并保留有效对照。固定断言、预期答案和支持的路由；可行时保留留出用例，用于最终确认。 |
| 性能／资源 | 使用[优化实验协议](https://github.com/malinskibeniamin/skills/blob/main/quantify-impact/REFERENCE.md#optimization-experiments)：相同负载与环境、配对测量、噪声，以及相对原始版本和当前最优版本的行为保真护栏。 |
| 视觉质量 | 在可比的路由、数据、视口、缩放、主题和交互状态下，采集原始版本、候选版本及有用的参考产品。选择与任务相关的维度，例如层级、可读性和反馈；保留行为与无障碍检查。 |

进行已授权的独立视觉评审时，使用新的上下文，并提供相同的产物、评估标准、意图、限制、检查结果和未解决的问题。不要透露期望的数字评分、之前的评分或偏好的赢家；可行时为候选版本使用中性标签。要求提供有证据的比较和具体缺陷。仅在明确要求时提供数字评分，而且始终只作为参考。主上下文内的自评既不是盲评，也不是独立评审。

重新评估未改变的参照，以检测评审漂移。如果相同输入得到明显不同的判断，应调查原因或报告不确定性，而不是宣称获胜。修复评估器，或改变评估标准、测试数据、模型、环境，都需要重新建立基线后再比较。不要把新评分拼入旧趋势，也不要为通过评估而削弱测试。

## 开始爬坡 [#climb]

1. **提出假设：**选择一个有证据的瓶颈或具体质量缺陷，预测小规模、可逆的修改如何改善目标而不破坏护栏。
2. **修改：**仅通过负责该任务的现有工作流实施这项干预。保留可恢复的当前最优版本；评审进行时，不要编辑其评估范围内的输入。
3. **评估：**对确切的候选版本运行相关检查和已固定的评估器。复用有效证据，并如实记录无效样本、失败和无法覆盖的范围。
4. **保留或回退：**只有相对原始版本及当前最优版本都保持护栏，并取得有证据、有价值的改进时，才能接受候选。只回退失败实验中自己负责的改动，保留先前已验证的改进和他人的工作。平局、带噪评分和缺失结果都不是改进。
5. **记录：**维护简明的轮次记录：候选身份、假设、证据／差异、护栏结果、保留／回退决定，以及未解决的问题。只有运行确实需要时，才使用被忽略或临时的存储位置；不要例行生成审计转储，也不要每轮都创建一个 PR。

满足有证据支持的验收条件、耗尽预算、连续两个候选都没有收益，或遇到外部阻塞／保留决策时，应提前停止。更高的评分本身不能解决实质缺陷。停滞或预算耗尽意味着目标未达成，而非批准。保留并报告最佳的已验证候选，不要默默扩大范围或提高目标。

优化提示词或工具描述时，先在已声明的路由中建立行为正确性。然后将通过的测试集固定为护栏，逐步减少上下文，并重跑对照与留出用例。将两个阶段分开；如果更短的指令使工具选择变差，该候选就应淘汰。使用[面向代理的写作指南](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL.md)；模型或上下文路由的变更仍需遵守 [efficient frontier 的评估门槛](https://github.com/malinskibeniamin/skills/blob/main/efficient-frontier/SKILL.md#promotion)。

## 确认并交接 [#confirm-and-hand-off]

使用一批新的、预先固定的评估来确认结果，而不只是依赖选出赢家的探索性样本。重跑受影响的功能／视觉检查，并与原始版本核对。明确说明缺少的独立评审覆盖；共识或目标评分不能替代验证或人工批准。

报告结果及目标状态、原始版本到最终版本的证据、保留与回退的实验、剩余限制，以及循环停止的原因。通过现有的交付负责技能继续到用户要求的终点；hill-climb 本身不增加创建 PR、合并、部署或监控的授权。

来源：[Theo 的讲解](https://x.com/theo/status/2118465321032106235)，13:04–20:44（对照比较与评分漂移），26:21–30:27（先评估，再压缩）。
