---
description: 撰写或审查基于事实的技术文档：README、设计规范、研究笔记和操作手册。用于文档编写或审查，不用于普通聊天、界面文案或智能体指令。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - docs
sidebar:
  label: /docs
title: /docs
type: skill
---
![技能 /docs 的示意图](/diagrams/skills/docs.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/docs.excalidraw)

撰写读者能够理解、验证和使用的文档。

## 加载指导 [#load-guidance]

1. 首先阅读[框架兼容性规则](https://github.com/malinskibeniamin/skills/blob/main/shared/FLIGHTRULES-COMPATIBILITY.md)。
2. 完整阅读[固定版本的上游 docs 技能](https://github.com/malinskibeniamin/skills/blob/main/vendor/flightrules/skills/docs/SKILL.md)。
3. 上游指导与兼容性规则不一致时，采用兼容性规则。阅读
   [沟通规则](https://github.com/malinskibeniamin/skills/blob/main/shared/communication.md)，了解首次阅读的结构和作者意图。

## 撰写或审查 [#write-or-review]

1. 明确读者、所需文档、来源证据和最终目标。沿用
   现有路径、模板和术语。仅要求审查时，输出发现，不进行编辑。
2. 先说明读者需要的结果。区分当前行为、提案、估算
   和未知事项。为数字断言提供来源，并为所述结果提供可复现的命令。
3. 保留作者意图，以及原样的代码、命令、标识符、引用的错误和事实。
   简化文字，但不删除重要限定条件。用仓库支持的格式为有意义的结构绘制示意图；
   将提议的路径标记为提案。
4. 对照来源验证每项修改后的断言。运行仓库的文档和链接检查；
   如果没有检查工具，使用工具检查修改后的内部文件链接和相关交叉引用。
   支持时验证片段锚点。绝不声称未运行的命令已成功执行。
5. 报告结果、观察到的验证情况和未解决的证据缺口。遵守
   请求的最终目标；此技能不授权无关的发布或配置操作。
