---
description: "移除或减少多余的网页 UI 动效：重复显现、装饰性循环、延迟的键盘操作和反复播放的数据动画。仅做减法；保留的动效由 animate 负责。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["remove animations"]}
sidebar: {"label":"/remove-animations"}
title: "/remove-animations"
type: "skill"
---
![技能示意图 /remove-animations](/diagrams/skills/remove-animations.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/remove-animations.excalidraw)

移除拖慢任务、却无法解释有意义变化的动效。
改编自 Emil Kowalski；参见[来源与兼容规则](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/EMIL-SKILLS-CREDITS.md)。
审计或提问只返回发现，不修改代码；移除请求则通过项目的 TDD 和交付检查实施。
加载本技能不授予更广泛的权限。

## 移除循环 [#removal-loop]

1. 梳理请求范围内的动效：组件、触发方式、驱动机制、属性、token、目的，以及观察到或预期的频率。
   尊重已记录的设计决定。频率只是启发式判断，不要编造每日使用统计。
2. 保留传达反馈、空间连续性、状态或解释的动效。结合情境考虑偶尔带来愉悦的效果。
   优先移除重复滚动显现、装饰性循环、每次挂载都重绘或从零计数的图表、列表交错入场，
   以及键盘操作或频繁导航的等待时间。保留等效的键盘反馈、加载指示和重要状态含义；
   即时状态变化也是有效选择。
3. 选择删除、减少或保留，并给出 `file:line` 和决定理由。仅缩减现有效果：去掉空间移动或交错，
   缩短过度延迟，或停止装饰性循环。复用现有 token，不添加新动画或缓动曲线。
   指针在同一组提示之间移动时，不应重复最初的延迟。
4. 编辑前，追踪隐藏的初始状态、填充模式、观察器、动画结束回调、按时长设置的定时器、
   退出/卸载生命周期和延后移动的焦点。删除显现动画时也删除隐藏的起始状态。
   将完成和焦点操作移到实际状态变化处，且只执行一次，不要继续等待已删除的事件。
   如果布局动效掩盖了跳动，保留它，并报告底层布局问题。
5. 只删除确认无引用的关键帧、变体、动效导入、包装层和 token。
   保留带有其他行为的包装层。删除依赖不属于本次纯动效清理；
   报告未使用的库，不修改清单或锁文件。
6. 在真实入口验证内容可见、立即关闭/卸载、焦点恢复、键盘/触摸、快速反向操作和减少动态效果。
   运行针对性测试及仓库检查，确认删除的名称不再被引用。

## 交接 [#handoff]

报告修改位置，按“之前 -> 结论 -> 理由”说明，并列出刻意保留的动效及其目的、无用代码清理和验证限制。
不要为了凑数量编造保留示例，也不要仅凭代码检查声称感知速度或帧率有所提升。

保留的动效需要实现质量修复时，加载 [animate](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/SKILL.md)；
需要优先级审计或路线图时，加载 [improve-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/improve-animations/SKILL.md)。
处理已测得的卡顿时，加载 [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-performance/SKILL.md)。
遵循[依赖加载约定](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。
