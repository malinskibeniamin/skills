---
description: "移除或減少多餘的網頁 UI 動效：重複顯現、裝飾性循環、延遲的鍵盤操作和反覆播放的資料動畫。僅做減法；保留的動效由 animate 負責。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["remove animations"]}
sidebar: {"label":"/remove-animations"}
title: "/remove-animations"
type: "skill"
---
![技能圖表 /remove-animations](/diagrams/skills/remove-animations.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/remove-animations.excalidraw)

移除拖慢任務、卻無法解釋有意義變化的動效。
改編自 Emil Kowalski；參見[來源與相容規則](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md)。
稽核或提問只回傳發現，不修改程式碼；移除請求則透過專案的 TDD 和交付檢查實作。
載入本技能不授予更廣泛的權限。

## 移除循環 [#removal-loop]

1. 梳理請求範圍內的動效：元件、觸發方式、驅動機制、屬性、token、目的，以及觀察到或預期的頻率。
   尊重已記錄的設計決定。頻率只是啟發式判斷，不要編造每日使用統計。
2. 保留傳達回饋、空間連續性、狀態或解釋的動效。結合情境考量偶爾帶來愉悅的效果。
   優先移除重複捲動顯現、裝飾性循環、每次掛載都重繪或從零計數的圖表、清單交錯進場，
   以及鍵盤操作或頻繁導覽的等待時間。保留等效的鍵盤回饋、載入指示和重要狀態意義；
   即時狀態變化也是有效選擇。
3. 選擇刪除、減少或保留，並提供 `file:line` 和決定理由。僅縮減現有效果：去掉空間移動或交錯，
   縮短過度延遲，或停止裝飾性循環。重用現有 token，不新增動畫或緩動曲線。
   指標在同一組提示之間移動時，不應重複最初的延遲。
4. 編輯前，追蹤隱藏的初始狀態、填充模式、觀察器、動畫結束回呼、按時長設定的計時器、
   退場/卸載生命週期和延後移動的焦點。刪除顯現動畫時也刪除隱藏的起始狀態。
   將完成和焦點操作移到實際狀態變化處，而且只執行一次，不要繼續等待已刪除的事件。
   如果版面配置動效掩蓋了跳動，保留它，並回報底層版面配置問題。
5. 只刪除確認無引用的關鍵影格、變體、動效匯入、包裝層和 token。
   保留帶有其他行為的包裝層。移除相依套件不屬於本次純動效清理；
   回報未使用的函式庫，不修改清單或鎖定檔。
6. 在實際入口驗證內容可見、立即關閉/卸載、焦點恢復、鍵盤/觸控、快速反向操作和減少動態效果。
   執行針對性測試及儲存庫檢查，確認刪除的名稱不再被引用。

## 交接 [#handoff]

回報修改位置，按「之前 -> 結論 -> 理由」說明，並列出刻意保留的動效及其目的、無用程式碼清理和驗證限制。
不要為了湊數編造保留範例，也不要僅憑程式碼檢查聲稱感知速度或影格率有所提升。

保留的動效需要實作品質修正時，載入 [animate](https://github.com/malinskibeniamin/skills/blob/main/animate/SKILL.md)；
需要優先順序稽核或路線圖時，載入 [improve-animations](https://github.com/malinskibeniamin/skills/blob/main/improve-animations/SKILL.md)。
處理已測得的卡頓時，載入 [animation-performance](https://github.com/malinskibeniamin/skills/blob/main/animation-performance/SKILL.md)。
遵循[相依項載入約定](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)。
