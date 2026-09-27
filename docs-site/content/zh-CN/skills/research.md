---
title: /research
description: 研究一手资料并保存附有引用的研究结果。适用于长期保存的报告、文档调研、API 事实集、资料通读或设计依据考证。
type: skill
sidebar:
  label: /research
---
![/research 技能示意图](/diagrams/skills/research.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/research.excalidraw)


默认以内联方式开展研究；后台工作需要显式委派或使用 `/swarm`。

1. 将每项论断追溯到**一手资料**：官方文档、源代码、规范和第一方 API。
2. 写入单个 Markdown 产物，并为每项论断引用来源；标出所有无法确认的内容，并说明查找过的位置。
3. 遵循仓库的笔记约定：探索性调研保留在暂存区或记忆中；只有可供决策的研究结果才会进入 `docs/`。

## 路由 [#routing]

- 需要立即获取 API 或版本事实 -> 以内联方式使用 `/read-the-damn-docs`，不生成产物。
- 需要了解代码或设计为何存在 -> 阅读 [DESIGN-RATIONALE.md](https://github.com/malinskibeniamin/skills/blob/main/research/DESIGN-RATIONALE.md)；追溯
  源代码历史和决策证据，不臆测意图。
- 视频 -> `/video-research`；将带时间戳的转录文本、OCR 结果和帧画面视为证据。
- 需要经过对抗性验证的多来源报告 -> 使用深度研究框架。
- 此技能 -> 开展聚焦的资料阅读工作，并生成附有引用的 Markdown 产物。
