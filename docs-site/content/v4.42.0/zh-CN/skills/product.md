---
description: 让工作始终围绕业务价值展开：单一类别、受益者、当前动因、证据、可触达性、最小可逆切片。适用于每个 PR、计划、自动审查或偏离检查。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - product
sidebar:
  label: /product
title: /product
type: skill
---
![/product 技能示意图](/diagrams/skills/product.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/product.excalidraw)

面临重要的产品或设计选择时，请阅读 [Poteto 适配指南](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/POTETO-NATIVE.md#product-and-planning)。

这项变更是否值得投入成本，能否触达受益者？代码缺陷交给 `/review`，主张
与证据的核对交给 `/lie-detector`。可独立运行，也可在
`/review` 和 `/grilling` 中作为**产品视角**嵌入使用，还可用于自动审查流程。[RULES.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/product/RULES.md) 根据
多少组独立证据共同支持每条规则来划分等级；[CRAFT.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/product/CRAFT.md) 则是
作者用于选择、塑造、测试和交付工作的实践手册。

按照[两类审查约定](https://github.com/malinskibeniamin/skills/blob/v4.42.0/shared/review-contract.md)评估范围和方向。
建议不代表人工认可；未成文的偏好仅供参考。

## 类别 [#lanes]

每项变更只服务于一个主要类别。混合目的应拆分为独立 PR。

| 类别 | 时间投入的价值所在 | 有效证据 |
| --- | --- | --- |
| 维持运行 | 节省资金或避免损失：故障、闲置成本、重复性运维工作、废弃功能入口、计费和升级路径 | 事故或复现、金额、运维工时、已验证的修复 |
| 体验改善 | 提升速度和口碑：CI 和开发反馈循环、延迟、可据此采取行动的错误信息、可运行的文档示例、不稳定测试 | 前后对比数据、为谁解除阻碍、发生频率 |
| 功能 | 创造收入：明确的买家、细分客户群、发布或演示能够实现新的能力 | 明确的需求、可触达的入口、采用信号 |
| 设计品位 | 降低下一次变更的成本：单一事实来源、标准化路径、类级防护、删除 | 已经造成的偏离或维护成本、第二个调用方 |

## 模式 [#modes]

| 模式 | 使用时机 | 输出 |
| --- | --- | --- |
| 计划 | 编码前的议题、规格或计划；`/grilling` 的产品视角 | 结论、Given/When/Then 验收条件、成本最低的证伪方法、切片计划 |
| 编写 | 编写 PR，包括 `/commit-push-pr` | `Lane:` 行，以及回答审查者问题的正文（[CRAFT.md](https://github.com/malinskibeniamin/skills/blob/v4.42.0/product/CRAFT.md)） |
| 审查 | `/review`、自动审查流程、明确请求 | 一行结论，最多三项发现 |
| 跟踪 | 长期分支、堆叠 PR，或范围持续扩大的工作 | `on track`、`drifting` 或 `park`，并指出应削减的范围 |

## 流程 [#procedure]

1. **意图：**阅读计划或 PR 正文、关联议题、提交和完整差异；不要让
   摘要凌驾于代码之上。记录声明的类别（`Lane:` 行），或推断类别并明确说明。
2. **受益者：**指出具体角色，以及这项变更会为其带来什么变化。仅写“用户”或“清理”
   不能明确受益者。
3. **当前动因：**找出触发因素（事故、客户请求、发布、交易、成本激增、
   测得的退化、受阻的使用方）。没有触发因素，就意味着这项工作在与路线图争夺资源。
4. **证据：**实测 > 复现 > 明确指出 > 单纯断言。关于性能、成本和
   可靠性的主张需要数据；假设被证伪后，应结束这项工作。
5. **触达：**追踪价值如何传递到受益者当前使用的入口：UI、API、CLI、文档，
   或已在某处启用的功能开关。已合并但无法触达，暂时不算产生价值。
6. **持有成本：**将运行成本、新增功能面、依赖、值班负担和审查时间，
   与最简单的替代方案进行比较。
7. **切片与安全：**选择最小且能独立产生价值的切片，默认关闭并提供回滚方式，
   保护现有使用方，将不可逆决策留给其负责人。
8. **规则：**始终应用 RULES.md 中的 Justification、Scope 和 Evidence 部分，以及
   对应类别的章节；当差异涉及发布、客户可见输出或
   计费时，还要应用 Delivery、Trust 或 Money。非生成源代码或测试发生变更时，加载 CRAFT.md。
   严格执行 S 和 A；差异明确符合时应用 B；仅在被要求时应用 C。

跟踪模式将分支与其声明的结果进行比较：超出类别的工作标为
`drifting`（指出要削减的内容或后续 PR）；暂时无法落地的价值标为 `park`
（指出重新启动的条件）。

## 结论与严重程度 [#verdicts-and-severity]

- **justified**：每一步都有证据支持。直接批准，无需额外评论。
- **thin**：确有价值，但缺少证据、验收条件、触达路径或发布方案；完成
  指定修复后交付。
- **unjustified**：没有受益者或触发因素、功能面建立在猜测之上，或成本超过收益；
  重新考虑范围，或暂时搁置并明确重新启动的条件。

- **P1 Value**：虚假成功或静默无效操作；漏收费或重复收费；线上路径中断
  且无关闭开关；未经负责人同意做出不可逆决策；不实的
  公开声明。
- **P2 Value**：缺少受益者、触发因素、证据、验收条件或发布方案；功能面建立在猜测之上；
  混合多个类别。
- **P3**：提示性建议；自动化流程绝不发布此类评论。

绝不单凭设计品位阻止交付。规则等级决定其适用强度；严重程度仅由
此列表决定。

## 自动审查 [#automated-review]

无额外评论意味着价值依据清晰：**justified** 的变更只输出一行结论。
否则，发布一条顶层 Value 评论，最多包含三项 P1 或 P2 发现，每项都要说明
规则 ID、后果和最小修复。不要复述 PR。仅涉及价值的发现
只发表评论，绝不请求更改；由负责人决定。根据实际内容判断机器人的发现是否成立。

## 输出 [#output]

```
product: <ktlo|qol|feature|taste> (<declared|inferred>) -- <justified|thin|unjustified> -- <beneficiary>; trigger: <why now>; evidence: <strongest proof>
- [P1|P2 Value] <rule id> <gap> - <consequence> - <smallest fix>
```

计划模式还会补充验收场景和成本最低的证伪方法。跟踪模式将
`on track`、`drifting` 或 `park` 放在结论位置。
说明此次审查未能验证哪些内容，以及应由谁做出最终决定。
