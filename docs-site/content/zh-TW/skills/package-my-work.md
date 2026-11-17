---
description: "為每次撰寫的 UI 變更製作精緻錄影，妥善設定解析度、輸入提示、細節放大與節奏。亦用於要求的示範或分享片段；不用於 npm 打包。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["package my work"]}
sidebar: {"label":"/package-my-work"}
title: "/package-my-work"
type: "skill"
---
![Diagram of the /package-my-work skill](/diagrams/skills/package-my-work.svg)

[Open the editable Excalidraw source](/diagrams/skills/package-my-work.excalidraw)

每個使用本機制的儲存庫中，面向消費者或終端使用者的 UI 變更都必須按 PR 製作錄影，包括混合變更與後續更新；重用仍有效的素材。參見[範圍與完成閘門](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md#per-pr-delivery)。


交付每次撰寫的 UI 變更時，都要製作精緻錄影，並在迭代間重用仍有效的素材。讓工作容易看清，而不是誇大成果。閱讀 [PACKAGING.md](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md)。
這是依據 [Emil Kowalski 發布的簡介](https://x.com/emilkowalski/status/2122704498334339368) 撰寫的本機適配，不是其未公開課程技能的副本；參見[來源說明](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PROVENANCE.md)。

## 結果契約 [#outcome-contract]

確認功能與修訂版本、真實入口、觀眾與管道、畫面比例及要求的終點。先查看既有示範原始檔。只詢問會影響結果的重要缺漏決策；其餘採用明確、可逆的預設設定。製作片段本身不授權上傳、建立 PR、安裝繪製器、使用付費服務或修改產品 UI。遵守 local/no-commit/no-push 限制；原始檔變更仍遵循儲存庫交付政策。

## 錄影 -> 聚焦 -> 包裝 -> 檢查 [#capture-focus-package-inspect]

1. 選擇一條初始狀態 -> 操作 -> 價值的故事線。使用去識別化資料與隔離瀏覽器；必要時保留真實的錯誤與復原過程。
2. 明確搭配 CSS 檢視區、錄影像素及匯出尺寸。在實際觀看大小下檢查文字；放大匯出無法修復模糊的原始素材。
3. 提示應對應輸入：滑鼠箭頭位於真實指標處，觸控或筆顯示接觸點，鍵盤顯示焦點。啟用前展示有意識的移動，拖曳時直接跟隨，不遮擋控制項。鍵盤操作不能假裝成滑鼠點擊。
4. 先建立脈絡，僅對難以讀清的細節放大或裁切。操作與結果應同時可見；使用既有合成器，不改變應用程式或瀏覽器縮放。
5. 重用[錄影與旁白配方](https://github.com/malinskibeniamin/skills/blob/main/demo/RECORDING.md)及 [PR 影片流程](https://github.com/malinskibeniamin/skills/blob/main/commit-push-pr/VIDEO.md)。剪掉準備與空等，重新對齊字幕及音訊，留出閱讀結果的時間；克制構圖優於裝飾性轉場。
6. 在交付尺寸下檢查代表性影格並完整播放，包括靜音觀看。驗證尺寸、時長、影格率、編碼、檔案大小、輸入對齊、放大清晰度、字幕、去識別化及音訊。修復後重播；誠實回報無法執行的檢查。

## 職責交接 [#handoffs]

- `/demo` 負責客戶故事、`demos/<slug>/` 中的原始檔與輸出、旁白與導覽、圖表替代方案及要求的發布。該技能仍僅由使用者明確叫用；不叫用它也能使用共用錄影配方。
- 每個 UI PR（包括混合變更及後續更新）都必須提供已發布錄影，並依[逐 PR 交付規則](https://github.com/malinskibeniamin/skills/blob/main/package-my-work/PACKAGING.md#per-pr-delivery)明確宣告包裝狀態。
- PR 互動證據遵循 `commit-push-pr/VIDEO.md`，重用同一段真實錄影。每次撰寫的 UI 變更都需精緻片段；純審查維持唯讀。
- 產品動態效果仍由 `/animate` 或 `/gestures` 負責。包裝改變呈現，不改變交付行為。終端機重播沿用 `/demo` 的 asciinema 配方。

## 完成 [#done]

回傳產物絕對路徑、故事、錄影與匯出設定、播放檢查，以及重要編輯與限制。直接連結 MP4/PNG 檔案；僅透過已授權的交付流程發布。無法存取來源介面會阻止真實錄影，而非允許重建看似成功的示範。必要 UI 片段在錄製完成或獲得明確豁免前維持阻塞；選用潤飾缺口不阻塞無關的非 UI 工作。保留必要的最終片段，僅保留要求或可重用的輔助素材。
