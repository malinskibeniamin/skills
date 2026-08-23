---
title: /resilience-review
description: 当可信故障可能导致数据丢失、安全或隐私损害、不可逆操作、契约破坏或用户很可能陷入无法继续的困境时，执行按风险排序的墨菲审查。
type: skill
sidebar:
  label: /resilience-review
---
![《/resilience-review》技能示意图](/diagrams/skills/resilience-review.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/resilience-review.excalidraw)

针对可信风险执行墨菲检查，而不是穷举各种边缘情况。

## 证据优先

当风险有信任边界、不可逆影响、明确规定的契约、已观察到的事故、经证实的规模或用户很可能经历的路径作为依据时，该风险才是可信的。
仅仅“可能发生”并不足够。直接跳过低风险工作，无需额外流程。

梳理操作、状态变更、副作用、依赖项和当前规模。
仅探查相关类别。原生 Codex 会以内联方式执行这些检查，除非用户
明确要求使用智能体或调用 `/swarm`。
- **输入：** 跨越信任边界的格式错误或过期数据。
- **时序：** 可能造成数据损坏或误导的重复或乱序工作。
- **系统：** 导致必要契约被破坏的依赖项故障。
- **状态：** 存在很可能到达路径的不可能状态。
- **恢复：** 普通用户可能陷入无法继续的状态或收到虚假的成功提示。

对于每个可信发现，说明证据、触发条件、预期行为、最小防护措施
以及最小公共契约测试。没有证据就不构成发现。

对于安全、隐私、数据丢失和破坏性操作，应采取故障关闭策略。其他情况下，
与其采用推测性的重试、回退、缓存、标志或
可观测性措施，不如明确失败。

当外部行为决定风险时，使用 `/read-the-damn-docs`。通过 `/diagnosing-bugs`
确认真实缺陷，然后添加一个处于 RED 状态的回归测试。仅对
面向客户的恢复流程使用 `/visual-review`。
## 输出
```md
## Resilience review
Risk surface:
- ...
Evidence:
- ...
Credible findings:
| Scenario | Evidence | Smallest guard | Contract test |
Verdict: PASS | NEEDS_GUARDS | BLOCKED
```

规则：引用文件、路由、表单或 API。对发现进行排序；不要以数量为导向。一个
真实的高影响缺口足以阻止继续推进。假设性的边缘情况不应成为工作项。

参阅 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.38.0/resilience-review/REFERENCE.md)。
