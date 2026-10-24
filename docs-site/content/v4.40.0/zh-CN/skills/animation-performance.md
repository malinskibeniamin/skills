---
description: "诊断已测得的网页动画卡顿、掉帧、繁忙线程上的动效、逐帧 React 工作、CSS 变量失效和 GPU 图层成本。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["animation performance"]}
sidebar: {"label":"/animation-performance"}
title: "/animation-performance"
type: "skill"
---
![“/animation-performance”技能示意图](/diagrams/skills/animation-performance.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/animation-performance.excalidraw)

先定位帧瓶颈，再修改动效。改编自 Emil Kowalski；
参见[来源](https://github.com/malinskibeniamin/skills/blob/v4.40.0/shared/EMIL-SKILLS-CREDITS.md)。审计意味着报告；明确的修复请求
则继续通过验证及项目交付检查。

## 循环

1. 记录故障交互：路由、数据规模、动画驱动方式/属性、浏览器/设备、刷新率，
   以及重叠的导航/加载。将基线 Performance 轨迹保存到 `.context/`；静态代码疑点不等于测得的卡顿。
2. 定位拖延帧的工作：JavaScript/React、样式失效、布局、绘制、合成或过量图层内存。
   60 Hz 时每帧约 16.7 ms，120 Hz 时约 8.3 ms；桌面流畅不能证明手机表现。
3. 用最小的等价改动检验一个原因：

   | 证据 | 候选改动 |
   |---|---|
   | 每帧都触发布局 | 改为变换装饰元素；保留所需文档流几何关系 |
   | 阴影/模糊绘制昂贵 | 缩小绘制区域或简化效果；比较视觉含义 |
   | 动效期间 JS 繁忙 | 使用适用的 CSS/WAAPI 路径；确认实际在合成器执行 |
   | React 每帧渲染 | 使用动效值或有界的 ref 更新；保留有语义的 React 状态 |
   | 成本随后代增加 | 将继承的 CSS 变量写入局限到运动元素 |
   | Motion 单独变换属性未获加速 | 检查已安装版本后尝试完整 `transform` |
   | 建立图层造成可见停顿 | 局部、临时使用 `will-change`；收益未证实就移除 |

4. 在相同的基线/候选条件下重放，比较延迟帧、布局/绘制和内存。
   重新检查快速反转、取消、减少动态效果、焦点和视觉等价性。
   拒绝仅转移成本的改动，以及小于运行间波动的变化。
5. 报告原因、`文件:行号`、轨迹路径、前后测量值和设备限制。
   无法使用设备时，针对该硬件的结果仍是未验证，而不是可以编造。

## 约束

- 指明过渡属性，不用 `all`；默认选择 `transform`/`opacity`。
- 硬件加速是渐进增强。CSS、WAAPI 和 Motion 都不作全面保证；检查
  [当前 Motion 指南](https://motion.dev/docs/performance)及已安装库的执行路径。
  CPU 限速并不能模拟 GPU 或手机内存。
- 缩放不是高度/padding 的通用替代：它会缩放文字，却不改变文档流。
  先保证正确性，再选择更廉价的渲染路径。
- 在受支持浏览器分析 blur/filter/clip-path；固定的像素阈值证明不了什么。
- 卸载时取消逐帧循环、观察器和动画，移除临时图层提示。
  记忆化由 React Compiler 负责；不要用 memo 包装代替诊断。

如果主要成本来自路由加载、包体积或后端，而非帧，按
[依赖加载约定](https://github.com/malinskibeniamin/skills/blob/v4.40.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)
加载 [ux-performance](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-performance/SKILL.md)。
