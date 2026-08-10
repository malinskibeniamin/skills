---
title: /ux-copy
description: 编写清晰、包容的用户体验文案。适用于修改界面字符串、标签、操作、空状态、错误消息、文档正文或产品术语。
type: skill
sidebar:
  label: /ux-copy
---
![“/ux-copy”技能示意图](/diagrams/skills/ux-copy.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/ux-copy.excalidraw)


<!-- allow: prose-style this file documents the rules and shows example violations -->

# 用户体验文案

阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/ux-copy/REFERENCE.md)，了解大小写、控件、错误、空状态、
包容性语言和正文规则。

## 产品文案

- 使用句首字母大写，并将对象或结果放在句首。
- 按钮应明确操作及其对象；避免使用“是”“否”“提交”“确定”或“完成”。
- 错误消息应说明原因、限制条件和恢复方法。
- 空状态应解释原因，并提供一个后续步骤。
- 标签应始终显示；占位符仅用于提供示例。
- 描述破坏性操作时，应直接说明永久性损失。
- 将正则表达式与验证消息相邻放置。
- 重点测试较长的本地化文本、大数值、离线和错误状态、文本截断以及恢复流程。

如有可用的项目规范产品名称和术语表，请遵循它们。
代码字符串豁免：`// allow: ux-copy [reason]`。

## 正文

- 优先使用直接的句子和具体的动词。
- 删除套话式开场、暴露人工智能痕迹的词语、过度的过渡语、拉丁语缩写、三段式赞美
  以及长破折号。
- 链接文本应具有描述性，并放在需要做出决定的位置。

正文豁免：`<!-- allow: prose-style [reason] -->`。

## 钩子设置

复制并注册以下 PostToolUse `Edit|Write` 钩子：

- `scripts/ux-copy-check.sh`
- `scripts/prose-style-check.sh`
- `scripts/_hook-lib.sh`

为它们添加可执行权限。将共用的产品术语保存在项目文档中。

## 完成

验证 `ux-copy-check.sh` 能检测感叹号、`successfully`、归咎性措辞、
宽泛的操作名称和含糊的错误消息。验证 `prose-style-check.sh` 能检测人工智能常用套话、
长破折号和明确禁用的词语。当项目已定义产品名称的规范大小写时，验证其是否得到遵循。
