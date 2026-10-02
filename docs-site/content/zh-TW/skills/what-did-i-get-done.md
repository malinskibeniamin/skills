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

## 工作流程 [#workflow]

1. 確認具體日期範圍；若知道上次更新的時間，以此作為起點。
2. 讀取該日期範圍內，由目前 git 使用者電子郵件所提交的 commit。
3. 排除合併 commit 與未提交的變更。
4. 將最重要的已交付變更整合成簡潔的進度更新。
5. 根據已陳述的計畫或明確承諾說明接下來的工作；若沒有已知資訊，寫出「Next work not specified.」。

- 極度精簡，並保持高資訊密度。
- 優先呈現重大的行為或架構變更。
- 省略僅涉及外觀的變更（格式調整、import、細微重新命名）。
- 不要推斷意圖或動機。以功能角度描述變更。

## 輸出 [#output]

一律分成兩個部分回答，並使用以下原樣標題：

- `What did you work on since the last update?`
- `What are you going to work on next?`

每個部分最多五個精簡項目。所有內容都放在這兩個部分內；優先挑選重要內容，不必湊滿五項。第一部分需包含實際日期範圍。每週回顧／復盤時，在已完成工作的項目內簡短標註可能的分類（錯誤修正／技術債／全新功能）。
