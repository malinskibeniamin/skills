---
description: "修复手机网页的视口、触摸、安全区域、键盘、滚动和 PWA 浏览器界面问题。用于手机特有的网页行为，不用于 React Native 或 Swift。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["mobile native"]}
sidebar: {"label":"/mobile-native"}
title: "/mobile-native"
type: "skill"
---
![“/mobile-native”技能示意图](/diagrams/skills/mobile-native.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/mobile-native.excalidraw)

消除浏览器/平台使用障碍，但不关闭无障碍功能。
改编自 Emil Kowalski；参见[来源](https://github.com/malinskibeniamin/skills/blob/v4.41.0/shared/EMIL-SKILLS-CREDITS.md)。
审查请求保持只读；修复遵循项目 TDD 和交付检查。

## 诊断与范围

确认报告中的手机/浏览器、布局、输入路径、键盘/PWA 模式和受支持设备。
先复现，再修改默认值。使用能力查询而不是 user-agent 嗅探；触摸和鼠标可同时存在。
现有 UI 基础组件和令牌仍负责各自范围。

| 症状 | 局部修正 |
|---|---|
| 点击后 hover 残留 | 用 `(hover: hover) and (pointer: fine)` 限制装饰性 hover；保留焦点/按压反馈 |
| 点击高亮与设计反馈冲突 | 仅在已提供等效反馈后，对控件局部设置透明点击高亮 |
| 底部操作被浏览器界面遮挡 | 应用外壳用 `100dvh`；稳定的首屏展示区用 `100svh` |
| 输入框获焦时自动缩放 | 计算后的输入文字至少 16 CSS px；保留用户缩放 |
| 按压反馈迟缓 | CSS `:active`/pointer-down 反馈；激活仍使用可访问的 click/submit |
| 滚动链传到面板后方 | 在实际滚动容器设置 `overscroll-behavior: contain` |
| 刘海/主屏指示条遮挡内容 | `viewport-fit=cover`，再用 `env(safe-area-inset-*, 0px)` 设置 padding |
| 拖动时选中控件标签 | 仅对该控件设置 `user-select: none`；可读内容仍可选择 |
| 自定义横向手势与滚动冲突 | 局部设置 `touch-action: pan-y pinch-zoom`；保留纵向滚动和双指缩放 |
| 浏览器界面主题不匹配 | 主题元数据与应用实际解析的主题一致 |

键盘、手势、过度滚动和 PWA 细节参见 [PLATFORM.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/mobile-native/PLATFORM.md)。
使用可选 viewport/meta 功能前，先检查当前浏览器支持情况。

## 保留功能

- 保留 `width=device-width, initial-scale=1`、双指缩放和大字号。
  不要设置 `user-scalable=no`，也不要用 `maximum-scale=1` 限制缩放。
- 将手势归属限定在相应把手/界面。设置 `touch-action` 时保留双指缩放；
  `none` 不是通用拖动修复。如果原生滚动/吸附已满足需要，优先使用它们。
- 不要以 `pointerdown` 激活取代 `click`：按压反馈不同于提交操作。
  键盘激活、滑动离开和 `pointercancel` 都必须正常工作。
- 根节点的过度滚动变更取决于产品。文档保留浏览器刷新/滚动行为；
  只限制拥有该手势的应用区域。
- 保留复制/选择、链接上下文菜单、焦点环和语义控件角色。
  监听器保持被动，除非有范围明确的取消需求。

## 验证

重放触摸与键盘路径、双指缩放/200% 文字、竖屏/横屏、打开键盘、地址栏展开/收起、
嵌套滚动及支持的亮色/暗色/PWA 模式。浏览器模拟只验证布局；记录哪些行为已在真机确认。
若没有硬件，报告代码/模拟证据及剩余手机检查。不要仅为满足此技能而将开发服务器暴露到网络。

报告症状 -> 修改的声明 -> 观察到的行为，以及未验证的设备路径。
