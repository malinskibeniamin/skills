---
description: "稽核現有網頁 UI 動效，為具體改善或可獨立執行的實作計畫排定優先順序。用於動效路線圖；實作和差異審查由 animate 負責。"
related: ["/skills/development-lifecycle","/skills/tdd","/skills/review"]
search: {"boost":1,"keywords":["improve animations"]}
sidebar: {"label":"/improve-animations"}
title: "/improve-animations"
type: "skill"
---
![技能圖表 /improve-animations](/diagrams/skills/improve-animations.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/improve-animations.excalidraw)

找出應當保留的動效中最有價值的修正。改編自 Emil Kowalski；
參見[來源與相容規則](https://github.com/malinskibeniamin/skills/blob/main/shared/EMIL-SKILLS-CREDITS.md)。
稽核/規劃請求只回傳發現，不編輯原始碼。僅在明確要求時儲存計畫。
明確的實作請求透過 [animate](https://github.com/malinskibeniamin/skills/blob/main/animate/SKILL.md) 和專案交付檢查繼續執行，
留在目前的上下文中；不自動啟動執行器、代理或工作樹。

## 稽核 [#audit]

1. 梳理請求涉及的介面、已安裝的動效函式庫及版本、元件基礎構件、現有 token、輸入路徑和產品情境。
   判斷預期頻率，不編造使用次數。尊重已記錄的取捨，確認每個引用位置。
2. 載入 [animate](https://github.com/malinskibeniamin/skills/blob/main/animate/SKILL.md) 及其
   [實作參考](https://github.com/malinskibeniamin/skills/blob/main/animate/REFERENCE.md)。
   稽核目的/頻率、緩動/時長、物理感/原點、可中斷性、繪製成本、無障礙、token 一致性及真正錯失的機會。
   在目前的上下文中完成這些面向。不必要的動效交給
   [remove-animations](https://github.com/malinskibeniamin/skills/blob/main/remove-animations/SKILL.md)，不要繼續潤飾。
3. 對照實際狀態變化和既有決定核實發現。區分可重現缺陷、實作建議和未經測量的效能懷疑。
   按使用者影響和投入排序，呈現嚴重程度、類別、`file:line`、證據及修正方案。
   空結果也有效，不強行新增動效或湊固定數量的發現。
4. 使用者要求計畫時，使每份計畫可獨立執行：目前修訂、問題/目前程式碼片段、精確目標和 token 值、
   儲存庫範例、有序編輯步驟、範圍/相依項、回復及針對性的驗證命令。
   包含快速反向操作、鍵盤/觸控、減少動態效果和實際體驗檢查；說明仍需哪些裝置證據。
   對照目前程式碼重新核實過時計畫。

對於 `remove-animations -> improve-animations -> animation-performance`，
先做減法，再評估保留的動效，最後分析剩餘的影格效能問題。
這條順序保留使用者要求的終點；稽核不授權修正。

影格瓶頸由 [animation-performance](https://github.com/malinskibeniamin/skills/blob/main/animation-performance/SKILL.md) 負責；
靜態程式碼檢查無法證明流暢度。依照
[相依項載入約定](https://github.com/malinskibeniamin/skills/blob/main/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)載入相依項。
