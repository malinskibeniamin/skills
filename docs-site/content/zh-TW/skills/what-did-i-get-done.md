---
description: 將一段期間內由自己提交的 git commit 彙整成簡潔的進度更新。適用於準備每週回顧、復盤、已交付工作摘要，或使用者要求的任何日期範圍。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - what did i get done
sidebar:
  label: /what-did-i-get-done
title: /what-did-i-get-done
type: skill
---
![「/what-did-i-get-done」技能示意圖](/diagrams/skills/what-did-i-get-done.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/what-did-i-get-done.excalidraw)

讀取指定日期範圍內，由目前 Git 使用者電子郵件所提交的 commit；若知道上次更新的時間，以此作為起點。
排除合併 commit 與未提交的變更。優先呈現已交付的行為或架構變更，省略格式調整、import 與細微重新命名。
描述功能，不推斷動機。

## 輸出 [#output]

一律只使用以下兩個原樣標題：

- `What did you work on since the last update?`
- `What are you going to work on next?`

每個部分最多五個精簡項目。第一部分需包含實際日期範圍；每週回顧或復盤時，簡短標註可能的分類（錯誤修正／技術債／全新功能）。
接下來的工作只根據已陳述的計畫或承諾；否則寫出 "Next work not specified."。
