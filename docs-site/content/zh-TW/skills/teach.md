---
title: /teach
description: 在此工作區中教導使用者一項新技能或概念。
type: skill
sidebar:
  label: /teach
---
![「/teach」技能示意圖](/diagrams/skills/teach.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/teach.excalidraw)

具狀態的教學工作區。目前的目錄會儲存學習狀態。

## 工作區檔案

- `MISSION.md` -- 使用者學習此主題的原因。格式：[MISSION-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/MISSION-FORMAT.md)。
- `RESOURCES.md` -- 作為教學依據的可信來源。格式：[RESOURCES-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/RESOURCES-FORMAT.md)。
- `reference/*.html` -- 可列印的速查表、詞彙表、演算法、語法與例行流程。
- `learning-records/*.md` -- 已展現的學習成果與先備知識。格式：[LEARNING-RECORD-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/LEARNING-RECORD-FORMAT.md)。
- `lessons/*.html` -- 每個檔案包含一堂獨立完整的課程。
- `assets/*` -- 可重複使用的元件：樣式表、測驗小工具、模擬器、圖表輔助工具。
- `NOTES.md` -- 使用者偏好與工作筆記。

## 以任務為先

如果 `MISSION.md` 不存在或內容不明確，請先訪談使用者再開始教學。將抽象目標推進為具體成果。每個工作區只設定一項任務。
如果任務有所變更，請先確認、更新 `MISSION.md`，並寫入學習紀錄。

## 來源規範

在 `RESOURCES.md` 足夠完善之前，先尋找高度可信的資源。絕不可只依賴參數記憶。課程需要附上引用來源及深入學習的路徑。

## 課程規則

一堂課應：

- 只教一件事
- 與任務直接相關
- 符合使用者的近側發展區
- 能快速完成
- 帶來具體成果
- 採用互動任務、測驗或實際情境的步驟清單
- 包含緊密的回饋循環，最好能自動且即時提供回饋
- 優先強化記憶儲存強度，而非熟練流暢感：提取、間隔與交錯練習
- 避免洩漏測驗答案的線索：盡可能讓選項字數相同，且不使用格式提示
- 使用 HTML 錨點連結相關課程與參考文件
- 推薦一項主要來源供深入學習
- 提醒使用者提出後續問題
- 儲存為 `lessons/NNNN-dash-case.html`
- 外觀簡潔、易讀且適合列印

讓課程容易開啟，最好只需一個 CLI 指令。

## 素材

預設應重複使用既有素材。在編寫課程前，先閱讀 `./assets/`，並使用現有元件建置。如果課程需要可重複使用的程式碼或樣式，請將其抽出至 `./assets/` 並加以連結；絕不可將未來會重複使用的內容寫在行內。第一個元件通常應是共用樣式表。

## 近側發展區

選擇下一堂課之前：

1. 閱讀 `learning-records/`
2. 閱讀 `NOTES.md`
3. 確認任務
4. 選擇最接近使用者目前程度且實用的挑戰

如果使用者表示已經了解某項內容，請在學習紀錄中記錄其理解深度。

## 學習紀錄

只有在使用者展現理解、說明先備知識、修正錯誤觀念或任務改變時，才寫入紀錄。涵蓋過內容不等於已學會。

## 參考文件

當主題適合以精簡形式呈現語法、例行流程、演算法、
姿勢、練習或詞彙表時，請建立參考文件。使用 [GLOSSARY-FORMAT.md](https://github.com/malinskibeniamin/skills/blob/main/teach/GLOSSARY-FORMAT.md)；只有在使用者理解術語
之後才新增該術語。

## 實務智慧／社群

如果問題需要實際情境的判斷，請先提供暫定回答，再建議信譽良好的社群、課程、論壇或實務工作者來源。如果使用者婉拒，請尊重其決定。

## 筆記

使用 `NOTES.md` 記錄偏好：步調、範例、語氣、無障礙需求、要避免的格式與練習限制。進行後續課程前請先閱讀。
