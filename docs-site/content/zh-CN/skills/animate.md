---
description: "构建、审查或规划有明确目的的网页 UI 动效。适用于过渡、缓动、弹簧、手势、动效审计及动画机会；不用于视频制作或原生应用。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["animate"]}
sidebar: {"label":"/animate"}
title: "/animate"
type: "skill"
---
![“/animate”技能示意图](/diagrams/skills/animate.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/animate.excalidraw)

选择能解释状态变化、又不拖慢用户任务的动效。
改编自 Emil Kowalski；参见[来源与选取说明](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md)。

## 执行边界

- 构建/修复：通过项目的 TDD 和交付检查实现所需动效。
- 审查：报告有证据的缺陷；不改动源代码。
- 审计/规划/机会探索：按优先级列出改进或有理由的新增动效；不改动源代码。
  仅在明确要求时保存计划。不要将审计变成一轮实现工作。

## 决策顺序

1. 检查组件、现有动效令牌、已安装的库及版本、输入方式和产品背景。
   先使用项目现有的 UI 基础组件，不要另造组件。
2. 说明目的：反馈、空间连续性、状态提示、解释或偶尔的愉悦。
   重复导航、命令面板和数据阅读界面更适合即时变化。频率只是启发式判断，
   不是凭空编造的每日使用指标。键盘用户应获得等效反馈，无需等待。
3. 选择能忠实表达含义且成本最低的机制：状态变化用 CSS 过渡；
   支持的入场过渡用 `@starting-style`；命令式控制用 WAAPI；
   手势、布局或退场生命周期用已安装的弹簧/动效库。
   使用库专有 API 前，先阅读已安装的类型和最新官方文档。
4. 优先显式指定 `transform`/`opacity` 过渡。从当前值重新设定目标；
   退场完成前保留状态，并处理打断和卸载清理。锚定界面从触发点缩放；居中对话框保持居中。
5. 复用令牌。新增令牌及组件起始值参见 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/animate/REFERENCE.md)；
   应进行性能分析，而不是假定存在硬件加速。
6. 从一开始就考虑减少动态效果、悬停能力、焦点和取消。
   移除非必要运动；即时状态变化也是有效方案。没有动画时也要保留关键含义。
   用 `(hover: hover) and (pointer: fine)` 限定悬停效果。
7. 在真实入口测试进入/退出、快速反转、重复触发、键盘、减少动态效果和触摸路径。
   记录实际观察，以及仍需设备验证的部分。

## 审查与规划

审查目的/频率、缓动/时长、起点、打断、每帧成本、无障碍和一致性。
引用 `文件:行号` 以及可见证据或性能轨迹；区分品质建议与可复现缺陷。
现有的有意权衡是背景，不自动构成问题。

探索机会时，列出合适位置、目的、预期频率、方案和被排除的候选项。
没有值得增加的动效也是有效结果。制定路线图时，按用户影响和工作量排序已确认的问题；
每份要求的计划都要包含精确目标值、现有令牌、范围、回退方式和实际体验检查。

简要报告决策、组成、验证和限制。只看代码无法批准主观感受，也不能声称已测得流畅度。
对于已测得的帧问题，按[依赖加载约定](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)
加载 [animation-performance](https://github.com/malinskibeniamin/skills/blob/main/animation-performance/SKILL.md)；
对于一般视觉评议，加载 [visual-review](https://github.com/malinskibeniamin/skills/blob/main/visual-review/SKILL.md)。
