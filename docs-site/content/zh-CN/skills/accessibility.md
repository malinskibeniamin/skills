---
title: /accessibility
description: 面向 ARIA、键盘行为、焦点、表单和嵌套控件的 React 无障碍指南。适用于构建交互式组件或修复无障碍问题。
type: skill
sidebar:
  label: /accessibility
---
![“/accessibility”技能示意图](/diagrams/skills/accessibility.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/accessibility.excalidraw)

## 此规则可发现的问题

检查由三个负责方分别执行——每条规则仅由一个负责方处理：

- **Biome（ultracite 预设）**——单元素规则：`<img>` 替代文本（`a11y/useAltText`）、可点击 `<div>`/`<span>` 的键盘支持（`a11y/useKeyWithClickEvents` 及相关规则）、组合框必需的 ARIA 属性（`a11y/useAriaPropsForRole`）、标签关联（`a11y/noLabelWithoutControl`）
- **React Doctor（Stop 钩子）**——结构规则：对话框的无障碍名称（`react-doctor/dialog-has-accessible-name`）、嵌套交互元素（`react-doctor/html-no-nested-interactive`）、类似 `Search icon` 的冗余名称措辞（`react-doctor/img-redundant-alt`）、使用占位符代替标签（`react-doctor/label-has-associated-control`），以及缺少错误描述的无效控件（`react-doctor/no-aria-invalid-without-description`）
- **此钩子**——仅检查两个引擎均无法表达的跨属性配对：`role="tablist"` 需要包含具有 `role="tab"` 的子元素；`data-invalid`（仅用于 CSS）需要搭配 `aria-invalid`

豁免方式：`// allow: a11y-skip [reason]`

## 禁止嵌套可按压元素

交互式组件只能采用一种模式——绝不能同时采用两种：

**模式 A：容器可点击**——不能包含交互式子元素。
```tsx
<ListCard onClick={handleSelect}>
  <Avatar src={user.avatar} />
  <Text>{user.name}</Text>
  <ChevronRightIcon /> {/* visual indicator only, not a button */}
</ListCard>
```

**模式 B：子元素可交互**——容器不可点击。
```tsx
<ListCard>
  <Avatar src={user.avatar} />
  <Text>{user.name}</Text>
  <DropdownMenu>
    <DropdownMenuTrigger asChild>
      <Button variant="ghost" size="icon"><MoreVerticalIcon /></Button>
    </DropdownMenuTrigger>
  </DropdownMenu>
</ListCard>
```

原因：点击目标含糊不清、事件冒泡缺陷、屏幕阅读器无法传达交互模型，以及移动设备上的触控目标相互重叠。

## 视觉检查清单

- [ ] 所有交互式元素上的焦点环均清晰可见（至少 2px，并使用对比色）
- [ ] 悬停与焦点样式一致（不能仅为鼠标提供交互提示）
- [ ] 不能仅通过颜色传达信息
- [ ] DOM 顺序与阅读和 Tab 键导航顺序一致；通过 CSS 调整视觉顺序时，应提供键盘和屏幕阅读器的验证依据
- [ ] 无障碍名称与可见意图和操作一致；名称中不得使用“图标”“按钮”或“图片”
- [ ] 表单字段具有持续可见的标签；占位符仅用于提供示例或格式提示
- [ ] 对话框、侧边面板和弹出框会限制焦点范围，在关闭时将焦点返回原处，并在以模态方式显示时使背景不可交互
- [ ] 错误、选中、警告和成功状态绝不能只依赖颜色；应将颜色与文本、图标或形状搭配使用
- [ ] 触控目标至少为 44x44 CSS 像素
- [ ] 动画遵循 `prefers-reduced-motion`
- [ ] 减少动态效果时，应通过不透明度、颜色、文本或即时状态变化保留必要反馈，而不是使用大幅移动
- [ ] 仅悬停时生效的效果应使用 `@media (hover: hover) and (pointer: fine)`，仅在适用的触控设备条件下启用
- [ ] 移动端抽屉式面板和侧边面板使用 `visualViewport`、安全区域间距、焦点限制、焦点返回和背景不可交互机制来处理虚拟键盘
- [ ] 高风险移动端交互应提供实体设备或模拟器上的验证依据，尤其是抽屉式面板、侧边面板、滑动手势和长按破坏性操作
- [ ] `forced-colors` / 高对比度模式：SVG 填充使用 `currentcolor`
- [ ] 文本可放大至 200%，且不会丢失内容

初始设置（安装、AXE 固定测试数据、钩子配置）：请参阅 [SETUP.md](https://github.com/malinskibeniamin/skills/blob/main/accessibility/SETUP.md)。
