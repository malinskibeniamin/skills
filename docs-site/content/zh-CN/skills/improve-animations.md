---
description: "审计现有网页 UI 动效，为具体改进或独立可执行的实施计划确定优先级。用于动效路线图；实现和差异审查由 animate 负责。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["improve animations"]}
sidebar: {"label":"/improve-animations"}
title: "/improve-animations"
type: "skill"
---
![技能示意图 /improve-animations](/diagrams/skills/improve-animations.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/improve-animations.excalidraw)

找出应当保留的动效中最有价值的修复。改编自 Emil Kowalski；
参见[来源与兼容规则](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md)。
审计/规划请求只返回发现，不编辑源代码。仅在明确要求时保存计划。
明确的实施请求通过 [animate](https://github.com/malinskibeniamin/skills/blob/main/animate/SKILL.md) 和项目交付检查继续执行，
留在当前上下文中；不自动启动执行器、智能体或工作树。

## 审计 [#audit]

1. 梳理请求涉及的界面、已安装的动效库及版本、组件基础构件、现有 token、输入路径和产品情境。
   判断预期频率，不编造使用次数。尊重已记录的权衡，确认每个引用位置。
2. 加载 [animate](https://github.com/malinskibeniamin/skills/blob/main/animate/SKILL.md) 及其
   [实现参考](https://github.com/malinskibeniamin/skills/blob/main/animate/REFERENCE.md)。
   审计目的/频率、缓动/时长、物理感/原点、可中断性、渲染成本、无障碍、token 一致性及真正错失的机会。
   在当前上下文中完成这些维度。不必要的动效交给
   [remove-animations](https://github.com/malinskibeniamin/skills/blob/main/remove-animations/SKILL.md)，不要继续润色。
3. 对照实际状态变化和既有决定核实发现。区分可复现缺陷、实现建议和未经测量的性能怀疑。
   按用户影响和投入排序，展示严重程度、类别、`file:line`、证据及修复方案。
   空结果也有效，不强行添加动效或凑固定数量的发现。
4. 用户要求计划时，使每份计划可独立执行：当前修订、问题/当前代码片段、精确目标和 token 值、
   仓库范例、有序编辑步骤、范围/依赖、回滚及针对性的验证命令。
   包含快速反向操作、键盘/触摸、减少动态效果和真实体验检查；说明仍需哪些设备证据。
   对照当前代码重新核实过时计划。

对于 `remove-animations -> improve-animations -> animation-performance`，
先做减法，再评估保留的动效，最后分析剩余的帧性能问题。
这条顺序保留用户要求的终点；审计不授权修复。

帧瓶颈由 [animation-performance](https://github.com/malinskibeniamin/skills/blob/main/animation-performance/SKILL.md) 负责；
静态代码检查无法证明流畅性。按照
[依赖加载约定](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)加载依赖。
