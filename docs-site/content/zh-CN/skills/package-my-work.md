---
description: "为每次编写的 UI 变更制作精致录屏，合理设置分辨率、输入提示、细节放大和节奏。也用于请求的演示或分享片段；不用于 npm 打包。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["package my work"]}
sidebar: {"label":"/package-my-work"}
title: "/package-my-work"
type: "skill"
---
![Diagram of the /package-my-work skill](/diagrams/skills/package-my-work.svg)

[Open the editable Excalidraw source](/diagrams/skills/package-my-work.excalidraw)

每个使用本机制的仓库中，面向消费者或最终用户的 UI 变更都必须按 PR 制作录屏，包括混合变更和后续更新；复用仍有效的素材。参见[范围与完成门槛](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md#per-pr-delivery)。


交付每次编写的 UI 变更时，都要制作精致录屏，并在迭代间复用仍有效的素材。让工作易于看清，而不是夸大效果。阅读 [PACKAGING.md](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md)。
这是根据 [Emil Kowalski 发布的简介](https://x.com/emilkowalski/status/2122704498334339368) 编写的本地适配，不是其未公开课程技能的副本；参见[来源说明](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PROVENANCE.md)。

## 结果约定 [#outcome-contract]

确定功能与修订版本、真实入口、观众和渠道、画面比例及请求终点。先查看已有演示源文件。只询问影响结果的重要缺失决策；其余采用明确、可逆的默认设置。制作片段本身不授权上传、创建 PR、安装渲染器、使用付费服务或修改产品 UI。遵守 local/no-commit/no-push 限制；源文件变更仍遵循仓库交付政策。

## 录制 -> 聚焦 -> 包装 -> 检查 [#capture-focus-package-inspect]

1. 选择一条初始状态 -> 操作 -> 收益的故事线。使用脱敏数据和隔离浏览器；必要时保留真实的错误与恢复过程。
2. 明确匹配 CSS 视口、录制像素和导出尺寸。在实际观看大小下检查文字；放大导出不能修复模糊源素材。
3. 提示应匹配输入：鼠标箭头位于真实指针处，触摸或笔显示接触点，键盘显示焦点。激活前展示有意的移动，拖动时直接跟随，不遮挡控件。键盘操作不能伪装成鼠标点击。
4. 先建立上下文，仅对难以读清的细节放大或裁剪。操作和结果应同时可见；使用现有合成器，不改变应用或浏览器缩放。
5. 复用[录制与旁白配方](https://github.com/malinskibeniamin/skills/blob/main/demo/RECORDING.md)和 [PR 视频流程](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/VIDEO.md)。剪掉准备和空等，重新对齐字幕和音频，留出阅读结果的时间；克制构图优于装饰性转场。
6. 在交付尺寸下检查代表性帧并完整播放，包括静音观看。验证尺寸、时长、帧率、编码、文件大小、输入对齐、放大清晰度、字幕、脱敏和音频。修复后重播；如实报告无法执行的检查。

## 职责交接 [#handoffs]

- `/demo` 负责客户故事、`demos/<slug>/` 中的源文件和输出、旁白与导览、图表回退及请求的发布。该技能仍仅由用户显式调用；无需调用它也能使用共享录制配方。
- 每个 UI PR（包括混合变更和后续更新）都必须提供已发布的录屏，并按[逐 PR 交付规则](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md#per-pr-delivery)明确声明包装情况。
- PR 交互证据遵循 `commit-push-pr/VIDEO.md`，复用同一段真实录像。每次编写的 UI 变更都需精致片段；纯审查保持只读。
- 产品动效仍由 `/animate` 或 `/gestures` 负责。包装改变呈现，不改变交付行为。终端回放沿用 `/demo` 的 asciinema 配方。

## 完成 [#done]

返回产物绝对路径、故事、录制与导出设置、播放检查以及重要编辑和限制。直接链接 MP4/PNG 文件；仅通过已授权的交付流程发布。无法访问源界面会阻止真实录制，而不是允许重构一个看似成功的演示。必需的 UI 片段在录制完成或获得明确豁免前保持阻塞；可选润色缺口不阻塞无关的非 UI 工作。保留必需的最终片段，仅保留请求或可复用的辅助素材。
