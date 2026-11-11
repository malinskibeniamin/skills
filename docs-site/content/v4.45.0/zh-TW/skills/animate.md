---
description: >-
  建立、審查或規劃有明確目的的網頁 UI 動效：轉場、緩動、彈簧、編排、錯開時序、檢視切換與動效稽核。直接操作使用
  gestures；不適用於影片或原生應用程式。
related:
  - /skills/development-lifecycle
  - /skills/tdd
  - /skills/review
search:
  boost: 1
  keywords:
    - animate
sidebar:
  label: /animate
title: /animate
type: skill
---
![「/animate」技能示意圖](/diagrams/skills/animate.svg)

[開啟可編輯的 Excalidraw 原始檔](/diagrams/skills/animate.excalidraw)

需要介面表面或圖示的動態效果方案時，先閱讀[介面相容規則](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/INTERFACES.md#better-ui)，再載入 [better-ui](https://github.com/malinskibeniamin/skills/blob/v4.45.0/jakubkrehel-skills/better-ui/SKILL.md)。上游固定數值不得覆寫專案設計 token或即時回饋。

選擇能解釋狀態變化、又不拖慢使用者任務的動效。
改編自 Emil Kowalski；參見[來源與選取說明](https://github.com/malinskibeniamin/skills/blob/v4.45.0/shared/EMIL-SKILLS-CREDITS.md)。
錄製產品示範時使用[示範錄製工具組](https://github.com/malinskibeniamin/skills/blob/v4.45.0/demo/RECORDING.md)，而不是 UI 動畫。
`/demo` 仍須由使用者呼叫；此連結不授予發布權限。

## 執行邊界 [#endpoint]

- 建置/修復：透過專案的 TDD 和交付檢查實現所需動效。
- 審查：報告有證據的缺陷；不改動原始碼。
- 稽核/規劃/機會探索：按優先順序列出改進或有理由的新增動效；不改動原始碼。
  僅在明確要求時儲存計劃。不要將稽核變成一輪實現工作。

## 選擇動效處理方向 [#choose-the-motion-lane]

根據症狀，而不是「慢」這個詞，選擇下一步。先檢查互動，再建議移除動效、
縮短時間或修正效能問題。

| 請求 / 觀察到的症狀 | 本地負責技能 |
|---|---|
| 「應用程式感覺很慢」，因為動效讓人等待 | [remove-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/remove-animations/SKILL.md) 負責移除；本技能負責保留動效的時序 |
| 「側邊欄卡頓」 / 畫面明顯不連貫 | [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-performance/SKILL.md)：最佳化前先記錄效能軌跡 |
| 「抽屜鬆手時跳動」 / 輕甩不遵循方向 | [gestures](https://github.com/malinskibeniamin/skills/blob/v4.45.0/gestures/SKILL.md)：追蹤、釋放和打斷 |
| 「卡片調整大小時，兩個檢視互相干擾」 | 本技能的[編排](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/REFERENCE.md#choreography)，不是另一個指令 |
| 「檢查整個應用程式並規劃動效修正」 | [improve-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/improve-animations/SKILL.md)；稽核/規劃保持唯讀 |
| 「這裡什麼該動、什麼不該動？」 / 「審查這個彈出層」 | 本技能下方的審查/機會探索模式；輸出發現，不實作修改 |
| 「彈出層從按鈕展開的效果叫什麼？」 | [animation-vocabulary](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-vocabulary/SKILL.md)；僅詢問名稱不授權實作 |

## 決策順序 [#decision-sequence]

1. 檢查元件、現有動效token、已安裝的函式庫及版本、輸入方式和產品背景。
   先使用專案現有的 UI 基礎元件，不要另造元件。
2. 說明目的：反饋、空間連續性、狀態提示、解釋或偶爾的愉悅。
   重複導航、命令面板和資料閱讀介面更適合即時變化。頻率只是啟發式判斷，
   不是憑空編造的每日使用指標。鍵盤使用者應獲得等效反饋，無需等待。
3. 選擇能忠實表達含義且成本最低的機制：狀態變化用 CSS 過渡；
   支援的入場過渡用 `@starting-style`；命令式控制用 WAAPI；
   手勢、版面配置或退場生命週期用已安裝的彈簧/動效函式庫。
   使用函式庫專有 API 前，先閱讀已安裝的型別和最新官方文件。
   拖曳、滑動與抽屜物理效果請載入 [gestures](https://github.com/malinskibeniamin/skills/blob/v4.45.0/gestures/SKILL.md)；它負責追蹤、
   放開速度、阻力、捲動協調與重新抓取的連續性。
4. 優先顯式指定 `transform`/`opacity` 過渡。從當前值重新設定目標；
   退場完成前保留狀態，並處理打斷和解除安裝清理。錨定介面從觸發點縮放；居中對話方塊保持居中。
5. 複用token。新增token及元件起始值參見 [REFERENCE.md](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/REFERENCE.md)；
   應進行效能分析，而不是假定存在硬體加速。
6. 從一開始就考慮減少動態效果、懸停能力、焦點和取消。
   移除非必要運動；即時狀態變化也是有效方案。沒有動畫時也要保留關鍵含義。
   用 `(hover: hover) and (pointer: fine)` 限定懸停效果。
7. 在真實入口測試進入/退出、快速反轉、重複觸發、鍵盤、減少動態效果和觸控路徑。
   記錄實際觀察，以及仍需裝置驗證的部分。

多個元素回應同一事件時，閱讀[編排](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animate/REFERENCE.md#choreography)：
決定哪些保持靜止，讓關聯部分一起執行，只為有意義的相依關係排序。保持互動立即可用；
防止過期的非同步接續重新啟動已取消的序列。

## 審查與規劃 [#review-and-planning]

僅做動效減法時，載入 [remove-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/remove-animations/SKILL.md)。
需要整個程式碼庫的稽核或按優先順序排列的路線圖時，載入
[improve-animations](https://github.com/malinskibeniamin/skills/blob/v4.45.0/improve-animations/SKILL.md)；本技能仍負責動效實作品質。

審查目的/頻率、緩動/時長、起點、打斷、每影格成本、無障礙和一致性。
引用 `檔案:行號` 以及可見證據或效能軌跡；區分品質建議與可復現缺陷。
現有的有意權衡是背景，不自動構成問題。
將發現描述為觀察到的行為 -> 建議的行為 -> 為什麼有幫助。以正常速度比較相同的
狀態/輸入；來源示範是參考，不是本應用程式結果的證明。

探索機會時，列出合適位置、目的、預期頻率、方案和被排除的候選項。
沒有值得增加的動效也是有效結果。制定路線圖時，按使用者影響和工作量排序已確認的問題；
每份要求的計劃都要包含精確目標值、現有token、範圍、回退方式和實際體驗檢查。

簡要報告決策、組成、驗證和限制。只看程式碼無法批准主觀感受，也不能聲稱已測得流暢度。
對於已測得的影格問題，按[依賴載入約定](https://github.com/malinskibeniamin/skills/blob/v4.45.0/writing-for-agents/SKILL-MECHANICS.md#loading-dependencies)
載入 [animation-performance](https://github.com/malinskibeniamin/skills/blob/v4.45.0/animation-performance/SKILL.md)；
對於一般視覺評議，載入 [visual-review](https://github.com/malinskibeniamin/skills/blob/v4.45.0/visual-review/SKILL.md)。
