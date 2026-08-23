---
title: /accessibility
description: "当 React 需要 ARIA、键盘、焦点、表单或嵌套控件无障碍支持时使用。"
type: skill
sidebar:
  label: /accessibility
---
![“/accessibility”技能示意图](/diagrams/skills/accessibility.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/accessibility.excalidraw)

每条规则只设一个执行方：

- **Biome** 负责元素语义：图片 `alt`、自定义控件键盘操作、组合框 ARIA 和标签关联。
- **React Doctor** 负责结构与命名：对话框、嵌套控件、无障碍名称、持久标签和带说明的无效字段。
- **本地钩子** 只检查 `tablist` 与子级 `tab` 角色，以及 `data-invalid` 与 `aria-invalid` 的配对。

不要重复检查。豁免格式：`// allow: a11y-skip [reason]`。

## 交互约定

- 优先使用原生控件和可见文本。自定义可点击元素需要角色、`tabIndex` 和等效键盘行为。
- 二选一：可点击容器不得包含交互子元素；被动容器可包含交互子元素。不要嵌套可按压控件。
- 组合框公开 `aria-expanded` 和 `aria-controls`；选项卡列表包含选项卡。
- 仅在没有可见名称时使用 `aria-label`；它或 `aria-labelledby` 可能替换后代文本。省略 `icon`、`button` 等冗余词。
- 表单控件具有持久标签。用 `aria-invalid` 和当前的 `aria-describedby` 关联可见错误；验证通过后移除陈旧错误 ID。
- 命名不明确时检查计算后的无障碍树，并遵循 [WAI-ARIA 命名指南](https://www.w3.org/WAI/ARIA/apg/practices/names-and-descriptions/)。

## 视觉与焦点检查

- 保留对比明显的 2px 焦点指示器；悬停操作也必须可由键盘和触摸完成。
- DOM 顺序与阅读和 Tab 顺序一致。重新排序的布局需要键盘和屏幕阅读器证据。
- 模态界面捕获并恢复焦点，同时使背景不可交互。
- 不要仅用颜色表达状态；同时使用文本、图标或形状，并用 `currentcolor` 支持强制颜色。
- 触摸目标至少为 44×44 CSS 像素。用 `@media (hover: hover) and (pointer: fine)` 限制仅悬停效果。
- 减少动态效果时，通过透明度、颜色、文本或即时状态变化保留反馈。
- 支持 200% 文本缩放且不丢失内容。
- 在真机或模拟器上验证高风险移动端浮层，包括 `visualViewport`、安全区域、焦点和背景禁用。

初始配置见 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/accessibility/SETUP.md)。
