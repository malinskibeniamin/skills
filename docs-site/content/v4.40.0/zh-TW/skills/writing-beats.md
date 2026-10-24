---
title: /writing-beats
description: 依照使用者選擇的轉折，從原始素材逐段建構文章。
type: skill
sidebar:
  label: /writing-beats
---
![/writing-beats 技能的流程圖](/diagrams/skills/writing-beats.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/writing-beats.excalidraw)

輸入：Markdown 原始素材。如果缺少輸出路徑，詢問一次。

## 循環

1. 從原始素材中提供 2 至 3 個候選起始段落。由使用者選擇。
2. 僅將該段落寫入文章檔案。
3. 從磁碟重新讀取文章。
4. 提供 2 至 3 個後續候選段落。
5. 重複進行，直到自然結束。

## 段落

文章脈絡中的一個推進：場景、觀點、問題、題外話或轉折。篇幅視需要而定。如果需要許多小節，請將其拆分。

## 規則

- 每次附加一個段落。絕不預先撰寫後續內容。
- 保留使用者的編輯：每次寫入前都要重新讀取。
- 可以留下未使用的原始素材。
- 如果使用者要求重寫、返回或刪減，請編輯指定段落，其餘內容保持不變。
