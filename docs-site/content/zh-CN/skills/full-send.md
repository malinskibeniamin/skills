---
description: 兼容预设：将作者交付推进到已授权的合并；full stop 或 --no-merge 保留合并决定。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - full send
sidebar:
  label: /full-send
title: /full-send
type: skill
---
![技能 /full-send 的图表](/diagrams/skills/full-send.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/full-send.excalidraw)

明确的 `full send <task or PR>` 选择[作者交付工作流](https://github.com/malinskibeniamin/skills/blob/main/shared/delivery-workflow.md)，授权对这一明确目标进行修复、提交、推送、创建 PR 并按仓库策略合并。不授权等待 CI、审查或进行监控；报告当前阻碍。讨论此技能不等于调用。

先前的停止条件优先：仅本地、不推送、仅草稿、PR 就绪、full stop 或 `--no-merge` 会收窄终点。仅要求跟进不授权合并。确认目标和所属工作树，复用现有 PR，并在 Conductor 中保持检出其分支。仅当目标不明确或所有者保留的决定阻塞工作时询问。

阅读并运行共享工作流，而非另一套 full-send 实现。代码未完成时加载 [development-lifecycle](https://github.com/malinskibeniamin/skills/blob/main/development-lifecycle/SKILL.md)；现有 PR 从当前证据开始。仅为请求的检查点、通知、恢复或明确委派的审查读取 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/REFERENCE.md)。不自动切换模型或创建代理。

阅读 [tstack 整合说明](https://github.com/malinskibeniamin/skills/blob/main/shared/TSTACK.md#full-send)及其上游验证指引，不改变此工作流的负责方，不隐式添加审查者，也不扩大权限。

共享工作流为获准的监控选择[原生上下文](https://github.com/malinskibeniamin/skills/blob/main/shared/T3CODE-NATIVE.md#resolve-context)；保持单一交付循环，不另建 T3 工作流。

灵感及研究限制：[SOURCES.md](https://github.com/malinskibeniamin/skills/blob/main/full-send/SOURCES.md)。本地交付整合了获得许可的 tstack 快照；这不代表上游背书。
