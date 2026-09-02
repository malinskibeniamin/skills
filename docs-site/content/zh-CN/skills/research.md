---
title: /research
description: 研究一手资料并保存附有引用的研究结果。适用于长期保存的报告、文档调研、API 事实集、资料通读或设计依据考证。
type: skill
sidebar:
  label: /research
---
![/research 技能示意图](/diagrams/skills/research.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/research.excalidraw)

默认以内联方式开展研究。使用后台智能体需要显式委派或使用 `/swarm`。

它的任务：

1. 根据**一手资料**调查问题，包括官方文档、源代码、规范和第一方 API，而不是依赖对这些资料的二手解读。每项论断都要追溯到其权威来源。
2. 将研究结果写入单个 Markdown 文件，并为每项论断引用来源。
3. 将文件保存在仓库现有的此类笔记存放位置；遵循已有约定，如果没有约定，则放在合理的位置并说明具体位置。在此技能仓库中，探索性调研应保留在暂存区或记忆中，只有可供决策的研究结果才会进入 `docs/`。

## 路由

- 需要**立即**获取事实以继续编码（API 结构、当前标志、版本行为）-> 改为以内联方式使用 `/read-the-damn-docs`；不使用后台智能体，也不生成产物。
- 需要了解代码或设计为何存在 -> 阅读 [DESIGN-RATIONALE.md](https://github.com/malinskibeniamin/skills/blob/main/research/DESIGN-RATIONALE.md)；追溯源代码历史和决策证据，不臆测意图。
- 视频 URL 或附件 -> 先使用 `/video-research`；将其带时间戳的转录文本、OCR 结果和帧画面视为来源证据。
- 需要经过对抗性验证的多来源事实核查**报告** -> 使用深度研究框架。
- 此技能处于两者之间：开展聚焦的资料阅读工作，并生成附有引用的 Markdown 产物。
