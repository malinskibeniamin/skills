---
description: 使用绑定 SHA 的状态和安全的当前工作区修复来管理有变更的拉取请求。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - pr shepherd
sidebar:
  label: /pr-shepherd
title: /pr-shepherd
type: skill
---
![‌/pr-shepherd 技能示意图](/diagrams/skills/pr-shepherd.svg)

[打开可编辑的 Excalidraw 源文件](/diagrams/skills/pr-shepherd.excalidraw)

兼容入口：对当前仓库中你的开放 PR 执行一次扫描。阅读并执行[批量流程](https://github.com/malinskibeniamin/skills/blob/main/pr-shepherd/REFERENCE.md)；它负责快照、绑定 SHA 的证据、工作区归属路由、修复和报告。不进行后台轮询或合并。

作者的主要入口是 `/work`；明确要求维护所有开放 PR 时使用同一流程，不需要另一条命令。
