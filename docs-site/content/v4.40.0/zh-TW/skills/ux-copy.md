---
title: /ux-copy
description: 撰寫或審查產品介面文案。適用於變更標題、標籤、按鈕、說明、訊息、導覽、i18n 字串或產品術語。
type: skill
sidebar:
  label: /ux-copy
---
![「/ux-copy」技能圖解](/diagrams/skills/ux-copy.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/ux-copy.excalidraw)


閱讀 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-copy/REFERENCE.md)，了解問題模式、大小寫、元素長度預算與範例。
每句話直接表達一個有用的重點。刪去贅詞和重複內容。
保留安全資訊、限制、不確定性與無障礙標籤。
使用專案術語表與標準產品名稱；[GLOSSARY.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-copy/GLOSSARY.md) 僅適用於特定產品。

## 撰寫

為每個元素擬出最短且準確的文案。檢查整個畫面，包括相鄰元素。
僅傳回或套用要求的修改。指出未經確認的事實；不得編造行為、權限、原因或復原方法。
不得暗示已獲得人工核准。

## 審查

結合上下文閱讀變更的文案。提供位置、原文引用、問題模式名稱，以及改寫或刪除建議。
將有用事實移至合適位置。無問題的審查須列出讀過的檔案與檢查過的不同 UI 字串數量。
說明缺少的上下文；不能依據原始碼聲稱已進行視覺檢查。審查不修改檔案。

## 範圍與檢查

涵蓋 TSX/JSX、導覽、i18n 與聊天周邊 UI。不涵蓋說明文件、產生的參考描述或對話回覆。
專案的明確規則優先。

從 `scripts/` 安裝可執行的 PostToolUse `Edit|Write` 鉤子：`ux-copy-check.sh`、
`prose-style-check.sh` 與 `_hook-lib.sh`。保留宿主設定。UX 檢查僅對選定的 TS/TSX 模式發出警告；
JSX/i18n 仍需審查。須確認宿主中的啟用設定。
例外須註明理由：`// allow: ux-copy [reason]`、`<!-- allow: prose-style [reason] -->`。

評估此技能的語氣時，使用 [evals/RUBRIC.md](https://github.com/malinskibeniamin/skills/blob/v4.40.0/ux-copy/evals/RUBRIC.md)。鉤子通過不代表語氣合格。
