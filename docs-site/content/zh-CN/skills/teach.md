---
title: /teach
description: 在此工作区中向用户教授一项新技能或概念。
type: skill
sidebar:
  label: /teach
---
![“/teach”技能示意图](/diagrams/skills/teach.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/teach.excalidraw)

有状态的教学工作区。当前目录用于存储学习状态。

## 工作区文件

- `MISSION.md` —— 用户学习该主题的原因。格式：[MISSION-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/MISSION-FORMAT.md)。
- `RESOURCES.md` —— 为教学提供依据的可信来源。格式：[RESOURCES-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/RESOURCES-FORMAT.md)。
- `reference/*.html` —— 可打印的速查表、术语表、算法、语法和流程。
- `learning-records/*.md` —— 已展现的学习成果和已有知识。格式：[LEARNING-RECORD-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/LEARNING-RECORD-FORMAT.md)。
- `lessons/*.html` —— 每个文件包含一节独立完整的课程。
- `assets/*` —— 可复用组件：样式表、测验小组件、模拟器和图表辅助工具。
- `NOTES.md` —— 用户偏好和工作笔记。

## 任务优先

如果缺少 `MISSION.md` 或其内容含糊，请在教学前访谈用户。推动用户将抽象目标转化为具体成果。每个工作区只设一个任务。
如果任务发生变化，请先确认，再更新 `MISSION.md`，并写入学习记录。

## 来源规范

在 `RESOURCES.md` 足够完善之前，先寻找高度可信的资源。绝不能仅依赖参数记忆。课程需要包含引用以及可供深入学习的路径。

## 课程规则

一节课程应：

- 只教授一项内容
- 与任务直接相关
- 符合用户的最近发展区
- 能够快速完成
- 带来切实成果
- 使用互动任务、测验或现实场景中的步骤清单
- 包含紧密的反馈循环，最好能自动或即时反馈
- 优先增强记忆强度，而非流畅感：提取练习、间隔学习、交错学习
- 避免测验选项泄露答案：尽可能保持字数相同，不使用格式提示
- 使用 HTML 锚点链接相关课程和参考文档
- 推荐一个用于深入学习的主要来源
- 提醒用户提出后续问题
- 保存为 `lessons/NNNN-dash-case.html`
- 外观简洁、易读且便于打印

让课程易于打开，最好只需一条 CLI 命令。

## 资源

默认复用。编写课程前，先查看 `./assets/`，并基于现有组件构建。如果课程需要可复用的代码或样式，请将其提取到 `./assets/` 并通过链接引用；绝不要内联将来会重复使用的内容。第一个组件通常应是共享样式表。

## 最近发展区

选择下一节课程前：

1. 阅读 `learning-records/`
2. 阅读 `NOTES.md`
3. 检查任务
4. 选择最接近且有用的挑战

如果用户表示已经掌握某项内容，请在学习记录中记录其掌握深度。

## 学习记录

只有当用户展现出理解、透露已有知识、纠正错误认知或任务发生变化时，才写入记录。讲过不等于学会。

## 参考文档

当主题适合使用精简语法、流程、算法、
姿势、练习或术语表时，请创建参考文档。使用 [GLOSSARY-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/GLOSSARY-FORMAT.md)；仅在用户理解术语
之后再添加。

## 实践智慧与社区

如果问题需要现实经验判断，请先给出暂定回答，然后建议高声誉的社区、课程、论坛或从业者来源。如果用户拒绝，请尊重其选择。

## 笔记

使用 `NOTES.md` 记录偏好：节奏、示例、语气、无障碍需求、不希望使用的形式和练习限制。以后编写课程前请先阅读。
