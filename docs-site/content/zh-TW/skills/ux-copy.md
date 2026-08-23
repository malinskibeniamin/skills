---
title: /ux-copy
description: 撰寫清楚、精簡且具包容性的介面文案。適用於變更 UI 字串、標籤、按鈕、空白狀態、錯誤訊息、通知、說明文字或產品術語時。
type: skill
sidebar:
  label: /ux-copy
---
![「/ux-copy」技能圖解](/diagrams/skills/ux-copy.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/ux-copy.excalidraw)


<!-- allow: prose-style this file documents the rules and shows example violations -->

# UX 文案

請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/ux-copy/REFERENCE.md)，了解大小寫、控制項、訊息、連結、
預留位置文字及包容性語言。

## 介面文案

- 使用句首字母大寫格式，並將物件或結果置於句首。
- 讓每個標籤、輔助文字、預留位置文字、工具提示和錯誤訊息各有明確用途。
- 按鈕應明確指出操作及其物件；避免使用「是」、「否」、「送出」、「確定」或「完成」。
- 錯誤訊息應說明原因、限制條件及復原方式。
- 空白狀態應解釋原因，並提供一個後續步驟。
- 標籤應持續顯示；預留位置文字僅用於提供範例。
- 完成通知使用主詞與過去式動詞。
- 只有在確實造成不便時才使用「請」、「抱歉」和「謝謝」。
- 涉及破壞性操作時，應直接說明資料將永久遺失。
- 將規則運算式與驗證訊息放在相鄰位置。
- 針對較長的在地化文字、大數字、離線與錯誤狀態、文字截斷及復原流程進行壓力測試。

若專案有定義標準產品名稱與詞彙表，請依其規範使用。
程式碼字串豁免註解：`// allow: ux-copy [reason]`。

## Markdown lint

`prose-style-check.sh` 只為儲存庫內 Markdown 提供窄範圍檢查，包括贅詞、連結、
包容性用語及標題大小寫。專案的文件標準才是事實來源。

行文豁免註解：`<!-- allow: prose-style [reason] -->`。

## Hook 設定

複製並註冊以下 PostToolUse `Edit|Write` hook：

- `scripts/ux-copy-check.sh`
- `scripts/prose-style-check.sh`
- `scripts/_hook-lib.sh`

將它們設為可執行。共用的產品術語應記錄在專案文件中。

## 完成條件

確認 `ux-copy-check.sh` 能偵測驚嘆號、`successfully`、歸咎使用者的措辭、
含糊的操作名稱、不明確的錯誤訊息、冗長的完成通知及錯誤的預留位置文字。確認
`prose-style-check.sh` 能偵測制式 AI 文案、破折號、無描述性的連結、非包容性用語及標題大小寫。若專案已定義產品名稱的標準大小寫，請確認其使用方式正確。
