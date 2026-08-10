---
title: /ux-copy
description: 撰寫清楚且具包容性的 UX 文案。適用於變更 UI 字串、標籤、操作、空白狀態、錯誤訊息、文件文字或產品術語時。
type: skill
sidebar:
  label: /ux-copy
---
![「/ux-copy」技能圖解](/diagrams/skills/ux-copy.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/ux-copy.excalidraw)


<!-- allow: prose-style this file documents the rules and shows example violations -->

# UX 文案

請閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/main/ux-copy/REFERENCE.md)，了解大小寫、控制項、錯誤訊息、空白狀態、
包容性語言及行文規則。

## 產品文案

- 使用句首字母大寫格式，並將物件或結果置於句首。
- 按鈕應明確指出操作及其物件；避免使用「是」、「否」、「送出」、「確定」或「完成」。
- 錯誤訊息應說明原因、限制條件及復原方式。
- 空白狀態應解釋原因，並提供一個後續步驟。
- 標籤應持續顯示；預留位置文字僅用於提供範例。
- 涉及破壞性操作時，應直接說明資料將永久遺失。
- 將規則運算式與驗證訊息放在相鄰位置。
- 針對較長的在地化文字、大數字、離線與錯誤狀態、文字截斷及復原流程進行壓力測試。

若專案有定義標準產品名稱與詞彙表，請依其規範使用。
程式碼字串豁免註解：`// allow: ux-copy [reason]`。

## 行文

- 優先使用直接的句子與具體的動詞。
- 移除制式開場白、帶有 AI 痕跡的用詞、冗長的轉折語、拉丁文縮寫、三段式讚美
  以及破折號。
- 連結文字應具描述性，並放在需要做決定的位置。

行文豁免註解：`<!-- allow: prose-style [reason] -->`。

## Hook 設定

複製並註冊以下 PostToolUse `Edit|Write` hook：

- `scripts/ux-copy-check.sh`
- `scripts/prose-style-check.sh`
- `scripts/_hook-lib.sh`

將它們設為可執行。共用的產品術語應記錄在專案文件中。

## 完成條件

確認 `ux-copy-check.sh` 能偵測驚嘆號、`successfully`、歸咎使用者的措辭、
含糊的操作名稱及不明確的錯誤訊息。確認 `prose-style-check.sh` 能偵測制式 AI 文案、
破折號及明確禁用的詞彙。若專案已定義產品名稱的標準大小寫，請確認其使用方式正確。
