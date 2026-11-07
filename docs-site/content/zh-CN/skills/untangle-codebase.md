---
description: "梳理整个代码库或指定范围内泄漏的抽象、复制粘贴逻辑、临时变通方案和多余封装，同时保持预期行为。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["untangle codebase"]}
sidebar: {"label":"/untangle-codebase"}
title: "/untangle-codebase"
type: "skill"
---
![技能示意图 /untangle-codebase](/diagrams/skills/untangle-codebase.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/untangle-codebase.excalidraw)

改编自 [caldoai/skills](https://github.com/malinskibeniamin/skills/blob/main/vendor/caldoai/skills/untangle-codebase/SKILL.md)；
参见[来源与更新](https://github.com/malinskibeniamin/skills/blob/main/untangle-codebase/CREDITS.md)。此工作流取代上游自动启动子智能体、无限循环整理以及顺带修改错误行为的授权。

## 范围与基线

确立结果契约：目标范围（未指定时为整个项目自有代码库）、保持行为的边界、验证方式和请求的终点。
保留无关工作与公共契约。仅规划或审查的请求保持只读；实现遵循仓库的
[交付契约](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)，包括明确的仅本地或禁止推送限制。
导入或讨论此技能并不等于调用。

仅提出一次以下可选附加工作，并遵从请求中已有的选择：

| 附加工作 | 内容 |
| --- | --- |
| 注释 | 删除仅重复代码含义的注释。 |
| 测试 | 删除无法捕获真实缺陷的测试，并修复无缺陷时仍失败的测试。 |

未指定时询问选择；选择前继续结构整理，不执行这两项附加工作。
重构过程中为保留覆盖而必须进行的测试更新，不属于可选精简。

使用[仓库导航](https://github.com/malinskibeniamin/skills/blob/main/shared/repo-navigation.md)确定入口、使用方、领域规则与现有检查。
通过公共接口记录基线及一个可信的失败与恢复场景。生成产物和第三方快照仍由各自维护方负责。

## 先诊断，再编辑

问：**这些部分是否应该一起变化？** 在范围内列出有证据支持的问题：

- **隐藏关联：** 重复知识、隐式共享状态、调用顺序约定，以及按技术层分散的功能逻辑。
- **不必要关联：** 调用方依赖内部细节、稳定领域依赖多变实现、只服务某个调用方的参数，以及将变化泄漏给调用方的浅层抽象。
- **冗余：** 仅转发调用的封装、推测性的扩展点或配置，以及看似未使用的代码。
- **特殊情况：** 单一值分支、调用方特例、吞掉的错误、休眠、重试、禁用测试和临时变通方案。追溯它们保护的需求或外部约束；存在本身并不等于缺陷。

为每个发现保留位置、受影响调用方、具体变化或失败场景，以及能发现错误修复的验证。
必要时使用 Git 共同变更历史和依赖证据；缺少图边不能证明代码已无用。
删除或共享前遵循[死代码与重复逻辑诊断](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#dead-code-and-duplication)。
决策记录留在现有任务笔记或临时目录，默认不新增仓库报告。

## 围绕需求重新设计

将相关问题归入最小的根因修复。把共同变化的知识放到其负责模块中，分开独立的变更原因。
优先使用稳定领域接口，而非多变实现细节。选择模块边界时使用
[代码库设计](https://github.com/malinskibeniamin/skills/blob/main/codebase-design/SKILL.md)。

与保持现状比较：指出方案消除的协调成本或失败，以及必须保留的契约。
封装可能负责校验、授权、可观测性或兼容；相似代码可能代表不同领域规则。
除非证据支持迁移，否则保留这些责任。更多辅助函数、更少行数或特殊情况，本身不能证明设计更好。

例如，对话框的任意焦点延迟和全局跳过焦点恢复标志，可能都源于缺少统一的焦点恢复责任方。
同时替换前应验证嵌套对话框与键盘流程，而不是分别删除两个变通方案。

## 分步实现与验证

1. 每次结构变化前建立相关行为检查；优先复用测试，未覆盖风险使用 [TDD](https://github.com/malinskibeniamin/skills/blob/main/tdd/SKILL.md)。
2. 迁移受影响调用方，再移除已替代的内部实现，以及需求已由新设计满足的变通方案。保留外部必需兼容性。
3. 每步后按[适度验证](https://github.com/malinskibeniamin/skills/blob/main/shared/verifiability.md#proportionate-verification)重放预期及失败路径。新发现的缺陷单独报告；附带的行为变化必须明确纳入范围，不得混入保持行为的重构。
4. 如果选择了注释清理，删除实现复述，保留外部约束和有用不变量；仅在移除过时变通方案时同步删除其说明。
5. 如果选择了测试整理，加载[测试审计](https://github.com/malinskibeniamin/skills/blob/main/test-audit/SKILL.md)，最后再精简。替代行为检查通过前保留回归覆盖。说明每个删除的测试为何无法捕获独立回归；将脆弱的内部断言改写为公共接口检查，而非删除必要覆盖。

## 审查与结束

在主上下文内审查隐藏关联、不必要关联、冗余及特殊情况。
仅在明确获得委派同意后，按宿主的模型与隔离规则使用子智能体；加载此技能不构成同意。
使用 [dogfood](https://github.com/malinskibeniamin/skills/blob/main/dogfood/SKILL.md)检查可运行行为，再对完整差异执行[审查](https://github.com/malinskibeniamin/skills/blob/main/review/SKILL.md)。

修复已确认且在范围内的问题；首次范围内审查无问题、基线行为保留且必需检查通过时结束。
保留合理例外；报告未知项、覆盖缺口和范围外机会，不扩大任务。
总结根因修复、保留的约束、验证及剩余限制，然后仅完成请求的交付终点。
未经测量，不宣称速度、token 消耗或缺陷数量得到改善。
