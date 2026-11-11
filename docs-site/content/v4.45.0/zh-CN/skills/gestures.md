---
description: >-
  构建或修复网页拖拽、滑动、抽屉、排序和长按交互：直接跟踪、弹性阻力、松手速度、惯性、吸附点与可中断行为。不适用于 React Native 或 Swift
  原生开发。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - gestures
sidebar:
  label: /gestures
title: /gestures
type: skill
---
![技能 /gestures 的示意图](/diagrams/skills/gestures.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/gestures.excalidraw)

让直接操控跟随指针，并在松手后以可预测的方式停稳。
改编自 Emil Kowalski；[来源与兼容性](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/EMIL-SKILLS-CREDITS.md)。
问题与审查只返回指导或发现，不修改代码；构建与修复遵循项目的 TDD、验证和交付要求。
加载本技能不授予安装工具或访问设备的权限。

## 选择负责方 [#choose-the-owner]

检查组件、输入路径、已安装的库及版本和现有 UI 封装。
自行实现物理效果前，先复用抽屉、对话框、通知或排序基础组件。
仅在适合现有技术栈和请求范围时考虑 Vaul；保留焦点约束、Escape 关闭、焦点恢复、
滚动锁定和关闭行为。手势不是替换可用库的理由。使用 API 前检查已安装的类型与当前官方文档。

## 手势循环 [#gesture-loop]

1. **定义意图。** 确定轴向、拖动把手、边界与吸附点、提交动作、取消路径及非拖拽替代方式。
   合适时优先使用原生滚动或吸附。区分按下反馈与激活；保留无障碍 click/submit 控件。
2. **协调输入。** 让滚动、文字选择与可交互子元素保留原生行为。
   自定义指针处理要跟踪活动指针 ID，只捕获负责的拖拽，并处理 `pointercancel`、
   `lostpointercapture`、额外指针与卸载。取消不得提交关闭、删除或排序结果。
   在手势开始前设置局部 `touch-action`，保留双指缩放。
   对于手机或浏览器症状，加载 [mobile-native](https://github.com/malinskibeniamin/skills/blob/v4.45.0/mobile-native/SKILL.md)。
3. **直接跟踪。** 在边界内，以元素当前可见位置为基准，按 1:1 映射指针位移。
   使用库的运动值或直接写入 transform；跟踪时不加弹簧或过渡，不在每次移动时触发 React 渲染。
   只在越过允许边界时施加阻力。避免用每帧更新的继承式 CSS 变量驱动大型后代树；
   分析实际更新路径的性能。
4. **处理松手。** 读取负责轴上的当前位移与近期带符号速度。根据距离或允许方向上的有意快速甩动
   选择吸附或关闭目标；保持单位一致。仅用于重新定位的拖拽可以松手即停。
   甩动可以使用惯性；弹簧收尾可以继承松手速度。只保留一个松手驱动机制：
   库的惯性与自定义弹簧不能竞争。
5. **允许重新抓取。** 再次抓取时，停止松手驱动机制，读取当前位置，并以此重设拖拽起点。
   在支持时从当前值与速度重新定向。弹簧和 CSS 都不会自动保证交接连续。
   遮罩与缩放等关联值应派生自同一个拖拽进度；防止过期的完成回调在中断后卸载元素或提交动作。
6. **以无障碍方式停稳。** 减少动态效果模式下保留必要的直接跟踪，但移除装饰性弹跳和长距离惯性；
   迅速或立即停稳。按钮、键盘和无需拖拽的指针路径也能达成同样结果。
   长按以线性进度表示经过时间，提前松开、Escape 或失去捕获时取消，并且只提交一次。
   长按不是执行动作的唯一方式，也不能代替确认。

阈值单位、阻力、抽屉及长按专属检查见 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/gestures/REFERENCE.md)。
其中数字只是调校起点，不是固定规则。多元素时序与过渡设计加载 [animate](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/SKILL.md)；
已测得的拖拽卡顿加载 [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-performance/SKILL.md)。
遵循[依赖加载约定](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。

## 验证与交接 [#verify-and-hand-off]

测试慢拖、短距离快速甩动、反向、边界阻力、回弹、收尾中重新抓取、嵌套滚动、子元素激活、
取消、多指、尺寸变化、卸载和减少动态效果。检查键盘及非拖拽方式是否等效，并保留焦点。
使用真实组件；仅在需要判断连续性时，以正常速度录制并逐帧检查。
代码检查不能证明手感、帧率或手机行为。
真机验证需要可用且获授权的硬件；报告缺失覆盖，不要只为满足本技能而对外开放开发服务器或安装工具。

简要报告跟踪与松手方案、阈值和单位、取消与替代行为、实际验证及尚未覆盖的设备路径。
将审查发现与审美偏好分开。
