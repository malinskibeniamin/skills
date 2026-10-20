---
description: 使用綁定 SHA 的狀態與安全的目前工作區修復來管理有變更的提取要求。
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
![/pr-shepherd 技能的圖表](/diagrams/skills/pr-shepherd.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/pr-shepherd.excalidraw)

相容入口：對目前儲存庫中你的開啟 PR 執行一次掃描。閱讀並執行[批次流程](https://github.com/malinskibeniamin/skills/blob/main/pr-shepherd/REFERENCE.md)；它負責快照、綁定 SHA 的證據、工作區歸屬路由、修復和報告。不進行背景輪詢或合併。

作者的主要入口是 `/work`；明確要求維護所有開啟 PR 時使用同一流程，不需要另一條命令。
