---
title: /what-did-i-get-done
description: 將一段期間內由自己提交的 git commit 彙整成簡潔的進度更新。適用於準備每週回顧、復盤、已交付工作摘要，或使用者要求的任何日期範圍。
type: skill
sidebar:
  label: /what-did-i-get-done
---
![「/what-did-i-get-done」技能示意圖](/diagrams/skills/what-did-i-get-done.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/what-did-i-get-done.excalidraw)

## 工作流程

1. 將要求的時間區間解析為具體日期。
2. 讀取該日期範圍內，由目前 git 使用者電子郵件所提交的 commit。
3. 排除合併 commit 與未提交的變更。
4. 將最重要的已交付變更整合成簡潔的進度更新。
5. 在最終摘要中包含實際使用的日期範圍。

## 準則

- 極度精簡，並保持高資訊密度。
- 優先呈現重大的行為或架構變更。
- 省略僅涉及外觀的變更（格式調整、import、細微重新命名）。
- 不要推斷意圖或動機。以功能角度描述變更。

## 輸出

- 一段適合作為進度更新的簡短摘要
- 實際日期範圍
- 可選擇僅針對重大變更列出 2 至 5 個項目
- 針對每週回顧／復盤：新增一段簡短的分類說明（可能屬於錯誤修正／技術債／全新功能）
