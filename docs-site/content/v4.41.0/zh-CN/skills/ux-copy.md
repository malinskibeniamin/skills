---
title: /ux-copy
description: 编写或审查产品界面文案。适用于修改标题、标签、按钮、帮助、消息、导航、i18n 字符串或产品术语。
type: skill
sidebar:
  label: /ux-copy
---
![“/ux-copy”技能示意图](/diagrams/skills/ux-copy.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/ux-copy.excalidraw)


阅读 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/ux-copy/REFERENCE.md)，了解问题模式、大小写、元素长度预算和示例。
每句话直接表达一个有用的要点。删去赘词和重复内容。
保留安全信息、限制、不确定性和无障碍标签。
使用项目术语表和规范产品名称；[GLOSSARY.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/ux-copy/GLOSSARY.md) 仅适用于特定产品。

## 编写

为每个元素拟出最短且准确的文案。检查整个视图，包括相邻元素。
仅返回或应用请求的修改。指出未经核实的事实；不得编造行为、权限、原因或恢复方法。
不得暗示已经获得人工批准。

## 审查

结合上下文阅读变更的文案。提供位置、原文引用、问题模式名称以及改写或删除建议。
将有用事实移至合适位置。无问题的审查须列出读过的文件和检查过的不同 UI 字符串数量。
说明缺失的上下文；不能依据源码声称已进行视觉检查。审查不修改文件。

## 范围和检查

涵盖 TSX/JSX、导航、i18n 和聊天周边 UI。不涵盖说明性文档、生成的参考描述或对话回复。
项目的明确规则优先。

从 `scripts/` 安装可执行的 PostToolUse `Edit|Write` 钩子：`ux-copy-check.sh`、
`prose-style-check.sh` 和 `_hook-lib.sh`。保留宿主配置。UX 检查仅对选定的 TS/TSX 模式发出警告；
JSX/i18n 仍需审查。须确认宿主中的激活配置。
例外须注明理由：`// allow: ux-copy [reason]`、`<!-- allow: prose-style [reason] -->`。

评估此技能的语气时，使用 [evals/RUBRIC.md](https://github.com/malinskibeniamin/skills/blob/v4.41.0/ux-copy/evals/RUBRIC.md)。钩子通过不代表语气合格。
